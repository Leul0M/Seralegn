import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_role.dart';
import 'hive_service.dart';

class AuthService {
  static final AuthService instance = AuthService._();
  AuthService._();

  SupabaseClient get _client => Supabase.instance.client;

  String _phoneToEmail(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');
    return 'user_$cleaned@seralegn.app';
  }

  /// Sign Up a Client in Hive local storage and Supabase Auth
  Future<UserRole> signUpClient({
    required String fullName,
    required String phone,
    required String password,
    String neighborhood = '',
  }) async {
    // 1. Always save session locally in Hive immediately
    await HiveService.instance.saveSession(
      role: UserRole.client,
      fullName: fullName,
      phoneNumber: phone,
      neighborhood: neighborhood,
      password: password,
    );

    // 2. Sync with Supabase Auth & DB if network is available
    try {
      final email = _phoneToEmail(phone);
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'phone_number': phone,
          'role': 'client',
        },
      );

      final user = response.user;
      if (user != null) {
        await _client.from('clients').upsert({
          'id': user.id,
          'full_name': fullName,
          'phone_number': phone,
          'password_hash': password,
        });
      }
    } catch (e) {
      // Network/Host lookup failed or offline mode: log handled notice
      // Local Hive storage already keeps user logged in on device
    }

    return UserRole.client;
  }

  /// Sign Up a Worker in Hive local storage and Supabase Auth
  Future<UserRole> signUpWorker({
    required String fullName,
    required String phone,
    required String password,
    required String faydaNumber,
    String neighborhood = '',
  }) async {
    // 1. Always save session locally in Hive immediately
    await HiveService.instance.saveSession(
      role: UserRole.worker,
      fullName: fullName,
      phoneNumber: phone,
      neighborhood: neighborhood,
      password: password,
      faydaNumber: faydaNumber,
      isFaydaVerified: true,
    );

    // 2. Sync with Supabase Auth & DB if network is available
    try {
      final email = _phoneToEmail(phone);
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'phone_number': phone,
          'fayda_number': faydaNumber,
          'role': 'worker',
        },
      );

      final user = response.user;
      if (user != null) {
        await _client.from('workers').upsert({
          'id': user.id,
          'full_name': fullName,
          'phone_number': phone,
          'fayda_number': faydaNumber,
          'fayda_verified': true,
          'password_hash': password,
        });
      }
    } catch (e) {
      // Network/Host lookup failed or offline mode
    }

    return UserRole.worker;
  }

  /// Log In with Phone Number & Password
  Future<UserRole> login({
    required String phone,
    required String password,
  }) async {
    final email = _phoneToEmail(phone);

    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user != null) {
        // Fetch client profile
        final clientData = await _client
            .from('clients')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (clientData != null) {
          final name = (clientData['full_name'] as String?) ?? '';
          await HiveService.instance.saveSession(
            role: UserRole.client,
            fullName: name,
            phoneNumber: phone,
            password: password,
          );
          return UserRole.client;
        }

        // Fetch worker profile
        final workerData = await _client
            .from('workers')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (workerData != null) {
          final name = (workerData['full_name'] as String?) ?? '';
          final fayda = (workerData['fayda_number'] as String?) ?? '';
          await HiveService.instance.saveSession(
            role: UserRole.worker,
            fullName: name,
            phoneNumber: phone,
            password: password,
            faydaNumber: fayda,
            isFaydaVerified: true,
          );
          return UserRole.worker;
        }
      }
    } catch (e) {
      // If network is offline, verify against local Hive data
      final cached = HiveService.instance.getUserData();
      final cachedPhone = (cached['phoneNumber'] as String).replaceAll(RegExp(r'\D'), '');
      final inputPhone = phone.replaceAll(RegExp(r'\D'), '');

      if (cachedPhone.isNotEmpty && cachedPhone == inputPhone) {
        final role = (cached['role'] as UserRole?) ?? UserRole.client;
        await HiveService.instance.saveSession(
          role: role,
          fullName: cached['fullName'] as String,
          phoneNumber: phone,
          password: password,
        );
        return role;
      }
      rethrow;
    }

    // Default return role based on metadata or fallback
    await HiveService.instance.saveSession(
      role: UserRole.client,
      fullName: 'User',
      phoneNumber: phone,
      password: password,
    );
    return UserRole.client;
  }

  /// Restore user session directly from Hive local storage
  Future<UserRole?> restoreSession() async {
    if (HiveService.instance.isLoggedIn()) {
      final role = HiveService.instance.getRole();
      if (role != null) {
        return role;
      }
    }

    // Secondary fallback: check active Supabase Auth session if online
    try {
      final session = _client.auth.currentSession;
      if (session != null) {
        final userId = session.user.id;
        final clientData = await _client
            .from('clients')
            .select()
            .eq('id', userId)
            .maybeSingle();

        if (clientData != null) {
          final name = (clientData['full_name'] as String?) ?? '';
          final phone = (clientData['phone_number'] as String?) ?? '';
          await HiveService.instance.saveSession(
            role: UserRole.client,
            fullName: name,
            phoneNumber: phone,
          );
          return UserRole.client;
        }

        final workerData = await _client
            .from('workers')
            .select()
            .eq('id', userId)
            .maybeSingle();

        if (workerData != null) {
          final name = (workerData['full_name'] as String?) ?? '';
          final phone = (workerData['phone_number'] as String?) ?? '';
          final fayda = (workerData['fayda_number'] as String?) ?? '';
          await HiveService.instance.saveSession(
            role: UserRole.worker,
            fullName: name,
            phoneNumber: phone,
            faydaNumber: fayda,
            isFaydaVerified: true,
          );
          return UserRole.worker;
        }
      }
    } catch (_) {}

    return null;
  }

  /// Log out and clear local Hive user session
  Future<void> logout() async {
    try {
      await _client.auth.signOut();
    } catch (_) {}
    await HiveService.instance.clearSession();
  }
}
