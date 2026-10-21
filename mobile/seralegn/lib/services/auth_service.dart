import 'dart:convert';

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

  String _profilePhoto(List<int>? bytes) {
    if (bytes == null || bytes.isEmpty) return '';
    return base64Encode(bytes);
  }

  Future<UserRole> signUpClient({
    required String fullName,
    required String phone,
    required String password,
    String neighborhood = '',
    List<int>? profileImageBytes,
  }) async {
    final profilePhoto = _profilePhoto(profileImageBytes);
    final response = await _client.auth.signUp(
      email: _phoneToEmail(phone),
      password: password,
      data: {
        'full_name': fullName,
        'phone_number': phone,
        'role': UserRole.client.name,
        'neighborhood': neighborhood,
        'profile_photo': profilePhoto,
      },
    );

    final user = response.user;
    if (user == null) {
      throw StateError('Supabase did not return a user for this registration.');
    }

    if (_client.auth.currentSession == null) {
      await _client.auth.signInWithPassword(
        email: _phoneToEmail(phone),
        password: password,
      );
    }

    await _client.from('clients').upsert({
      'id': user.id,
      'full_name': fullName,
      'phone_number': phone,
    });

    return UserRole.client;
  }

  Future<UserRole> signUpWorker({
    required String fullName,
    required String phone,
    required String password,
    required String faydaNumber,
    String neighborhood = '',
    bool isFaydaVerified = false,
    List<int>? profileImageBytes,
  }) async {
    final profilePhoto = _profilePhoto(profileImageBytes);
    final cleanedFayda = faydaNumber.trim();
    final response = await _client.auth.signUp(
      email: _phoneToEmail(phone),
      password: password,
      data: {
        'full_name': fullName,
        'phone_number': phone,
        'fayda_number': cleanedFayda,
        'fayda_verified': isFaydaVerified,
        'profile_photo': profilePhoto,
        'role': UserRole.worker.name,
        'neighborhood': neighborhood,
      },
    );

    final user = response.user;
    if (user == null) {
      throw StateError('Supabase did not return a user for this registration.');
    }

    if (_client.auth.currentSession == null) {
      await _client.auth.signInWithPassword(
        email: _phoneToEmail(phone),
        password: password,
      );
    }

    final workerRow = <String, dynamic>{
      'id': user.id,
      'full_name': fullName,
      'phone_number': phone,
      'fayda_verified': isFaydaVerified,
    };
    if (cleanedFayda.isNotEmpty && cleanedFayda != 'N/A') {
      workerRow['fayda_number'] = cleanedFayda;
    }
    await _client.from('workers').upsert(workerRow);

    return UserRole.worker;
  }

  Future<UserRole> login({
    required String phone,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: _phoneToEmail(phone),
      password: password,
    );
    final user = response.user;
    if (user == null) {
      throw StateError('Supabase did not return a user for this login.');
    }

    final clientData = await _client
        .from('clients')
        .select()
        .eq('id', user.id)
        .maybeSingle();
    if (clientData != null) {
      return UserRole.client;
    }

    final workerData = await _client
        .from('workers')
        .select()
        .eq('id', user.id)
        .maybeSingle();
    if (workerData != null) {
      return UserRole.worker;
    }

    throw StateError(
      'No client or worker profile exists for this Supabase account.',
    );
  }

  Future<String?> ensureSupabaseSession() async => _client.auth.currentUser?.id;

  Future<UserRole?> restoreSession() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final metadata = user.userMetadata ?? const <String, dynamic>{};
    final roleName = metadata['role'] as String?;
    for (final role in UserRole.values) {
      if (role.name == roleName) return role;
    }

    final clientProfile = await _client
        .from('clients')
        .select('id')
        .eq('id', user.id)
        .maybeSingle();
    if (clientProfile != null) return UserRole.client;

    final workerProfile = await _client
        .from('workers')
        .select('id')
        .eq('id', user.id)
        .maybeSingle();
    if (workerProfile != null) return UserRole.worker;

    throw StateError('The Supabase account has no client or worker profile.');
  }

  Future<void> logout() async {
    await _client.auth.signOut();
    await HiveService.instance.clearSession();
  }
}
