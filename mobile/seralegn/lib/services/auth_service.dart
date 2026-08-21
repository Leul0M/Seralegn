import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_role.dart';

class AuthService {
  static final AuthService instance = AuthService._();
  AuthService._();

  SupabaseClient get _client => Supabase.instance.client;

  static const String _keyRole = 'seralegn_user_role';
  static const String _keyFullName = 'seralegn_user_full_name';
  static const String _keyPhone = 'seralegn_user_phone';
  static const String _keyFayda = 'seralegn_user_fayda';

  /// Helper to convert a phone number into a canonical email address for Supabase Auth
  String _phoneToEmail(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');
    return 'user_$cleaned@seralegn.app';
  }

  /// Sign Up a Client in Supabase Auth & public.clients table
  Future<UserRole> signUpClient({
    required String fullName,
    required String phone,
    required String password,
    String neighborhood = '',
  }) async {
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
    if (user == null) {
      throw const AuthException('Failed to create user account.');
    }

    // Insert or update public.clients row
    await _client.from('clients').upsert({
      'id': user.id,
      'full_name': fullName,
      'phone_number': phone,
      'password_hash': password,
    });

    await _saveLocalSession(
      role: UserRole.client,
      fullName: fullName,
      phone: phone,
    );

    return UserRole.client;
  }

  /// Sign Up a Worker in Supabase Auth & public.workers table
  Future<UserRole> signUpWorker({
    required String fullName,
    required String phone,
    required String password,
    required String faydaNumber,
    String neighborhood = '',
  }) async {
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
    if (user == null) {
      throw const AuthException('Failed to create worker account.');
    }

    // Insert or update public.workers row
    await _client.from('workers').upsert({
      'id': user.id,
      'full_name': fullName,
      'phone_number': phone,
      'fayda_number': faydaNumber,
      'fayda_verified': true,
      'password_hash': password,
    });

    await _saveLocalSession(
      role: UserRole.worker,
      fullName: fullName,
      phone: phone,
      faydaNumber: faydaNumber,
    );

    return UserRole.worker;
  }

  /// Log In with Phone Number & Password
  Future<UserRole> login({
    required String phone,
    required String password,
  }) async {
    final email = _phoneToEmail(phone);

    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) {
      throw const AuthException('Invalid login credentials.');
    }

    // Check if client
    final clientData = await _client
        .from('clients')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (clientData != null) {
      final name = (clientData['full_name'] as String?) ?? '';
      await _saveLocalSession(
        role: UserRole.client,
        fullName: name,
        phone: phone,
      );
      return UserRole.client;
    }

    // Check if worker
    final workerData = await _client
        .from('workers')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (workerData != null) {
      final name = (workerData['full_name'] as String?) ?? '';
      final fayda = (workerData['fayda_number'] as String?) ?? '';
      await _saveLocalSession(
        role: UserRole.worker,
        fullName: name,
        phone: phone,
        faydaNumber: fayda,
      );
      return UserRole.worker;
    }

    // Fallback: check metadata role
    final metaRole = user.userMetadata?['role'];
    final role = metaRole == 'worker' ? UserRole.worker : UserRole.client;
    final name = (user.userMetadata?['full_name'] as String?) ?? '';
    await _saveLocalSession(role: role, fullName: name, phone: phone);
    return role;
  }

  /// Check & restore existing active session on app startup
  Future<UserRole?> restoreSession() async {
    final session = _client.auth.currentSession;
    final prefs = await SharedPreferences.getInstance();
    final cachedRoleStr = prefs.getString(_keyRole);

    if (session == null && cachedRoleStr == null) {
      return null;
    }

    if (session != null) {
      final userId = session.user.id;
      // Try to match client profile
      try {
        final clientData = await _client
            .from('clients')
            .select()
            .eq('id', userId)
            .maybeSingle();

        if (clientData != null) {
          final name = (clientData['full_name'] as String?) ?? '';
          final phone = (clientData['phone_number'] as String?) ?? '';
          await _saveLocalSession(
            role: UserRole.client,
            fullName: name,
            phone: phone,
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
          await _saveLocalSession(
            role: UserRole.worker,
            fullName: name,
            phone: phone,
            faydaNumber: fayda,
          );
          return UserRole.worker;
        }
      } catch (_) {
        // In case of offline launch, fall back to cached role below
      }
    }

    // Fallback to local stored session
    if (cachedRoleStr != null) {
      if (cachedRoleStr == 'worker') {
        return UserRole.worker;
      } else if (cachedRoleStr == 'client') {
        return UserRole.client;
      }
    }

    return null;
  }

  /// Sign out current user and clear local cached data
  Future<void> logout() async {
    try {
      await _client.auth.signOut();
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyRole);
    await prefs.remove(_keyFullName);
    await prefs.remove(_keyPhone);
    await prefs.remove(_keyFayda);
  }

  Future<void> _saveLocalSession({
    required UserRole role,
    required String fullName,
    required String phone,
    String? faydaNumber,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyRole, role.name);
    await prefs.setString(_keyFullName, fullName);
    await prefs.setString(_keyPhone, phone);
    if (faydaNumber != null) {
      await prefs.setString(_keyFayda, faydaNumber);
    }
  }

  Future<Map<String, String>> getSavedUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'role': prefs.getString(_keyRole) ?? '',
      'fullName': prefs.getString(_keyFullName) ?? '',
      'phone': prefs.getString(_keyPhone) ?? '',
      'fayda': prefs.getString(_keyFayda) ?? '',
    };
  }
}
