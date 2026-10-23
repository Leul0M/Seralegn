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
    required String faydaQrHash,
    String neighborhood = '',
    bool isFaydaVerified = false,
    List<int>? profileImageBytes,
  }) async {
    final profilePhoto = _profilePhoto(profileImageBytes);
    final cleanedQrHash = faydaQrHash.trim().toLowerCase();
    if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(cleanedQrHash)) {
      throw StateError(
        'Scan a valid Fayda QR code before creating a client account.',
      );
    }

    final existingClient = await _client
        .from('clients')
        .select('id')
        .eq('fayda_qr_hash', cleanedQrHash)
        .maybeSingle();
    if (existingClient != null) {
      throw StateError(
        'This Fayda identity is already linked to another client account.',
      );
    }

    final existingWorker = await _client
        .from('workers')
        .select('id')
        .eq('fayda_qr_hash', cleanedQrHash)
        .maybeSingle();
    if (existingWorker != null) {
      throw StateError(
        'This Fayda identity is already linked to another worker account.',
      );
    }

    final response = await _client.auth.signUp(
      email: _phoneToEmail(phone),
      password: password,
      data: {
        'full_name': fullName,
        'phone_number': phone,
        'fayda_qr_hash': cleanedQrHash,
        'fayda_verified': isFaydaVerified,
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
    await _verifyProfile(user.id, UserRole.client);

    return UserRole.client;
  }

  Future<UserRole> signUpWorker({
    required String fullName,
    required String phone,
    required String password,
    required String faydaQrHash,
    String neighborhood = '',
    bool isFaydaVerified = false,
    List<int>? profileImageBytes,
  }) async {
    final profilePhoto = _profilePhoto(profileImageBytes);
    final cleanedQrHash = faydaQrHash.trim().toLowerCase();
    if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(cleanedQrHash)) {
      throw StateError(
        'Scan a valid Fayda QR code before creating a worker account.',
      );
    }

    final existingClient = await _client
        .from('clients')
        .select('id')
        .eq('fayda_qr_hash', cleanedQrHash)
        .maybeSingle();
    if (existingClient != null) {
      throw StateError(
        'This Fayda identity is already linked to another client account.',
      );
    }

    final existingWorker = await _client
        .from('workers')
        .select('id')
        .eq('fayda_qr_hash', cleanedQrHash)
        .maybeSingle();
    if (existingWorker != null) {
      throw StateError(
        'This Fayda identity is already linked to another worker account.',
      );
    }

    final response = await _client.auth.signUp(
      email: _phoneToEmail(phone),
      password: password,
      data: {
        'full_name': fullName,
        'phone_number': phone,
        'fayda_qr_hash': cleanedQrHash,
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

    await _verifyProfile(user.id, UserRole.worker);

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

    try {
      return await _profileRole(user.id);
    } catch (error, stackTrace) {
      await _client.auth.signOut(scope: SignOutScope.local);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<String?> ensureSupabaseSession() async => _client.auth.currentUser?.id;

  Future<UserRole> _profileRole(String userId) async {
    final clientProfile = await _client
        .from('clients')
        .select('id')
        .eq('id', userId)
        .maybeSingle();
    if (clientProfile != null) return UserRole.client;

    final workerProfile = await _client
        .from('workers')
        .select('id')
        .eq('id', userId)
        .maybeSingle();
    if (workerProfile != null) return UserRole.worker;

    throw StateError(
      'No client or worker profile exists for this Supabase account.',
    );
  }

  Future<void> _verifyProfile(String userId, UserRole expectedRole) async {
    try {
      final actualRole = await _profileRole(userId);
      if (actualRole != expectedRole) {
        throw StateError(
          'Supabase created a ${actualRole.name} profile instead of a '
          '${expectedRole.name} profile.',
        );
      }
    } catch (error, stackTrace) {
      await _client.auth.signOut(scope: SignOutScope.local);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<UserRole?> restoreSession() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    try {
      return await _profileRole(user.id);
    } on StateError {
      await _client.auth.signOut(scope: SignOutScope.local);
      return null;
    }
  }

  Future<void> logout() async {
    await _client.auth.signOut(scope: SignOutScope.local);
    await HiveService.instance.clearSession();
  }
}
