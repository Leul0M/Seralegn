import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
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

  /// Hashes password with a per-user random salt for local Hive offline storage.
  /// Server-side password hashing is managed securely by Supabase Auth (Bcrypt/Argon2).
  String _hashPassword(String password, String salt) {
    if (password.isEmpty) return '';
    return sha256.convert(utf8.encode('$salt:$password')).toString();
  }

  /// Sign Up a Client in Hive local storage and Supabase Auth
  Future<UserRole> signUpClient({
    required String fullName,
    required String phone,
    required String password,
    String neighborhood = '',
    List<int>? profileImageBytes,
  }) async {
    final salt = HiveService.instance.generateRandomSalt();
    final passHash = _hashPassword(password, salt);
    final photoBase64 = profileImageBytes != null && profileImageBytes.isNotEmpty
        ? base64Encode(profileImageBytes)
        : '';

    // 1. Always save session locally in Hive immediately
    await HiveService.instance.saveSession(
      role: UserRole.client,
      fullName: fullName,
      phoneNumber: phone,
      neighborhood: neighborhood,
      password: passHash,
      passwordSalt: salt,
      profilePhoto: photoBase64,
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
          'profile_photo': photoBase64,
        },
      );

      final user = response.user;
      if (user != null) {
        var userId = user.id;
        // Ensure active session if auto-login didn't occur
        if (_client.auth.currentSession == null) {
          try {
            final signInResp = await _client.auth.signInWithPassword(
              email: email,
              password: password,
            );
            if (signInResp.user != null) {
              userId = signInResp.user!.id;
            }
          } catch (_) {}
        }

        final clientRow = <String, dynamic>{
          'id': userId,
          'full_name': fullName,
          'phone_number': phone,
          'password_hash': passHash,
        };

        await _client.from('clients').upsert(clientRow);

        // Try optional profile_photo column update if table has it
        if (photoBase64.isNotEmpty) {
          try {
            await _client.from('clients').update({'profile_photo': photoBase64}).eq('id', userId);
          } catch (_) {}
        }
      }
    } catch (_) {}

    return UserRole.client;
  }

  /// Sign Up a Worker in Hive local storage and Supabase Auth
  Future<UserRole> signUpWorker({
    required String fullName,
    required String phone,
    required String password,
    required String faydaNumber,
    String neighborhood = '',
    bool isFaydaVerified = false,
    List<int>? profileImageBytes,
  }) async {
    final salt = HiveService.instance.generateRandomSalt();
    final passHash = _hashPassword(password, salt);
    final photoBase64 = profileImageBytes != null && profileImageBytes.isNotEmpty
        ? base64Encode(profileImageBytes)
        : '';

    // 1. Always save session locally in Hive immediately
    await HiveService.instance.saveSession(
      role: UserRole.worker,
      fullName: fullName,
      phoneNumber: phone,
      neighborhood: neighborhood,
      password: passHash,
      passwordSalt: salt,
      faydaNumber: faydaNumber,
      isFaydaVerified: isFaydaVerified,
      profilePhoto: photoBase64,
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
          'fayda_verified': isFaydaVerified,
          'profile_photo': photoBase64,
          'role': 'worker',
        },
      );

      final user = response.user;
      if (user != null) {
        var userId = user.id;
        // Ensure active session if auto-login didn't occur
        if (_client.auth.currentSession == null) {
          try {
            final signInResp = await _client.auth.signInWithPassword(
              email: email,
              password: password,
            );
            if (signInResp.user != null) {
              userId = signInResp.user!.id;
            }
          } catch (_) {}
        }

        final workerRow = <String, dynamic>{
          'id': userId,
          'full_name': fullName,
          'phone_number': phone,
          'fayda_verified': isFaydaVerified,
          'password_hash': passHash,
        };
        final cleanedFayda = faydaNumber.trim();
        if (cleanedFayda.isNotEmpty && cleanedFayda != 'N/A') {
          workerRow['fayda_number'] = cleanedFayda;
        }

        await _client.from('workers').upsert(workerRow);

        // Try optional profile_photo column update if table has it
        if (photoBase64.isNotEmpty) {
          try {
            await _client.from('workers').update({'profile_photo': photoBase64}).eq('id', userId);
          } catch (_) {}
        }
      }
    } catch (_) {}

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
        final cached = HiveService.instance.getUserData();
        final salt = (cached['passwordSalt'] as String? ?? '').isNotEmpty
            ? cached['passwordSalt'] as String
            : HiveService.instance.generateRandomSalt();
        final passHash = _hashPassword(password, salt);

        // Fetch client profile
        final clientData = await _client
            .from('clients')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (clientData != null) {
          final name = (clientData['full_name'] as String?) ??
              (user.userMetadata?['full_name'] as String?) ?? '';
          final photo = (clientData['profile_photo'] as String?) ??
              (user.userMetadata?['profile_photo'] as String?) ?? '';
          await HiveService.instance.saveSession(
            role: UserRole.client,
            fullName: name,
            phoneNumber: phone,
            password: passHash,
            passwordSalt: salt,
            profilePhoto: photo,
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
          final name = (workerData['full_name'] as String?) ??
              (user.userMetadata?['full_name'] as String?) ?? '';
          final fayda = (workerData['fayda_number'] as String?) ??
              (user.userMetadata?['fayda_number'] as String?) ?? '';
          final isVerified = (workerData['fayda_verified'] as bool?) ??
              (user.userMetadata?['fayda_verified'] as bool?) ?? false;
          final photo = (workerData['profile_photo'] as String?) ??
              (user.userMetadata?['profile_photo'] as String?) ?? '';
          await HiveService.instance.saveSession(
            role: UserRole.worker,
            fullName: name,
            phoneNumber: phone,
            password: passHash,
            passwordSalt: salt,
            faydaNumber: fayda,
            isFaydaVerified: isVerified,
            profilePhoto: photo,
          );
          return UserRole.worker;
        }

        // Auto-heal: If database row was missing, create/upsert row from user.userMetadata
        final metaRole = (user.userMetadata?['role'] as String?) ?? 'client';
        final fullName = (user.userMetadata?['full_name'] as String?) ?? 'User';
        final faydaNumber = (user.userMetadata?['fayda_number'] as String?) ?? '';
        final isFaydaVerified = (user.userMetadata?['fayda_verified'] as bool?) ?? false;
        final photoBase64 = (user.userMetadata?['profile_photo'] as String?) ?? '';

        if (metaRole == 'worker') {
          final workerRow = <String, dynamic>{
            'id': user.id,
            'full_name': fullName,
            'phone_number': phone,
            'fayda_verified': isFaydaVerified,
            'password_hash': passHash,
          };
          if (faydaNumber.isNotEmpty && faydaNumber != 'N/A') {
            workerRow['fayda_number'] = faydaNumber;
          }
          try {
            await _client.from('workers').upsert(workerRow);
          } catch (_) {}
          await HiveService.instance.saveSession(
            role: UserRole.worker,
            fullName: fullName,
            phoneNumber: phone,
            password: passHash,
            passwordSalt: salt,
            faydaNumber: faydaNumber,
            isFaydaVerified: isFaydaVerified,
            profilePhoto: photoBase64,
          );
          return UserRole.worker;
        } else {
          final clientRow = <String, dynamic>{
            'id': user.id,
            'full_name': fullName,
            'phone_number': phone,
            'password_hash': passHash,
          };
          try {
            await _client.from('clients').upsert(clientRow);
          } catch (_) {}
          await HiveService.instance.saveSession(
            role: UserRole.client,
            fullName: fullName,
            phoneNumber: phone,
            password: passHash,
            passwordSalt: salt,
            profilePhoto: photoBase64,
          );
          return UserRole.client;
        }
      }
    } catch (e) {
      // If network is offline, verify against local Hive data (phone & salted password hash)
      final cached = HiveService.instance.getUserData();
      final cachedPhone = (cached['phoneNumber'] as String).replaceAll(RegExp(r'\D'), '');
      final inputPhone = phone.replaceAll(RegExp(r'\D'), '');
      final cachedPassHash = (cached['password'] as String? ?? '');
      final cachedSalt = (cached['passwordSalt'] as String? ?? '');

      bool isPasswordValid = false;
      if (cachedPassHash.isEmpty) {
        isPasswordValid = true;
      } else if (cachedSalt.isNotEmpty) {
        final inputHash = _hashPassword(password, cachedSalt);
        isPasswordValid = (cachedPassHash == inputHash);
      } else {
        // Legacy hash fallback for existing cached sessions
        final legacyHash = sha256.convert(utf8.encode('seralegn_salt_$password')).toString();
        isPasswordValid = (cachedPassHash == legacyHash || cachedPassHash == password);
      }

      if (cachedPhone.isNotEmpty &&
          cachedPhone == inputPhone &&
          isPasswordValid) {
        final role = (cached['role'] as UserRole?) ?? UserRole.client;
        return role;
      }
      rethrow;
    }

    // Default return role based on metadata or fallback
    final salt = HiveService.instance.generateRandomSalt();
    final passHash = _hashPassword(password, salt);
    await HiveService.instance.saveSession(
      role: UserRole.client,
      fullName: 'User',
      phoneNumber: phone,
      password: passHash,
      passwordSalt: salt,
    );
    return UserRole.client;
  }

  /// Ensures that there is an active Supabase Auth session for the current Hive user.
  /// If missing (e.g. registered while network permission was missing), automatically
  /// signs in or signs up with Supabase Auth using saved Hive credentials.
  Future<String?> ensureSupabaseSession() async {
    final current = _client.auth.currentUser;
    if (current != null) return current.id;

    if (!HiveService.instance.isLoggedIn()) return null;

    final userData = HiveService.instance.getUserData();
    final phone = (userData['phoneNumber'] as String?)?.trim() ?? '';
    final password = (userData['password'] as String?)?.trim() ?? '';

    if (phone.isEmpty) return null;

    final cleanedPhone = phone.replaceAll(RegExp(r'\D'), '');
    final effectivePassword = password.isNotEmpty ? password : 'SeralegnPass#$cleanedPhone';

    final email = _phoneToEmail(phone);
    final fullName = (userData['fullName'] as String?) ?? 'User';
    final role = HiveService.instance.getRole();
    final roleStr = role == UserRole.worker ? 'worker' : 'client';
    final profilePhoto = (userData['profilePhoto'] as String?) ?? '';

    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: effectivePassword,
      );
      return response.user?.id;
    } catch (_) {
      try {
        final response = await _client.auth.signUp(
          email: email,
          password: effectivePassword,
          data: {
            'full_name': fullName,
            'phone_number': phone,
            'role': roleStr,
            'profile_photo': profilePhoto,
          },
        );
        final user = response.user;
        if (user != null) {
          final table = roleStr == 'worker' ? 'workers' : 'clients';
          final Map<String, dynamic> row = {
            'id': user.id,
            'full_name': fullName,
            'phone_number': phone,
            'password_hash': effectivePassword,
          };
          if (profilePhoto.isNotEmpty) {
            row['profile_photo'] = profilePhoto;
          }
          if (roleStr == 'worker') {
            final fayda = (userData['faydaNumber'] as String?)?.trim();
            if (fayda != null && fayda.isNotEmpty && fayda != 'N/A') {
              row['fayda_number'] = fayda;
            }
            row['fayda_verified'] = (userData['isFaydaVerified'] as bool?) ?? true;
          }
          await _client.from(table).upsert(row);
        }
        return user?.id;
      } catch (_) {
        return null;
      }
    }
  }

  /// Restore user session directly from Hive local storage
  Future<UserRole?> restoreSession() async {
    if (HiveService.instance.isLoggedIn()) {
      final role = HiveService.instance.getRole();
      if (role != null) {
        // Asynchronously ensure Supabase Auth session is synced
        ensureSupabaseSession();
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
          final photo = (clientData['profile_photo'] as String?) ??
              (session.user.userMetadata?['profile_photo'] as String?) ?? '';
          await HiveService.instance.saveSession(
            role: UserRole.client,
            fullName: name,
            phoneNumber: phone,
            profilePhoto: photo,
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
          final isVerified = (workerData['fayda_verified'] as bool?) ?? false;
          final photo = (workerData['profile_photo'] as String?) ??
              (session.user.userMetadata?['profile_photo'] as String?) ?? '';
          await HiveService.instance.saveSession(
            role: UserRole.worker,
            fullName: name,
            phoneNumber: phone,
            faydaNumber: fayda,
            isFaydaVerified: isVerified,
            profilePhoto: photo,
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
