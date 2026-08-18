import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

enum UserRole { client, worker }

abstract class AuthRepository extends ChangeNotifier {
  String? get currentUserId;
  String? get currentPhoneNumber;
  UserRole? get currentRole;
  bool get hasProfile;
  bool get isLoading;

  Future<void> signInWithPhone(String phoneNumber);
  Future<bool> verifyOtp(String phoneNumber, String otp);
  Future<void> registerClient(String fullName);
  Future<void> registerWorker(String fullName, String faydaNumber);
  Future<void> signOut();
  Future<void> checkExistingProfile();
}

class SupabaseAuthRepository extends ChangeNotifier implements AuthRepository {
  final _client = SupabaseService.instance.client;

  String? _userId;
  String? _phoneNumber;
  UserRole? _role;
  bool _hasProfile = false;
  bool _isLoading = false;

  @override
  String? get currentUserId => _userId;

  @override
  String? get currentPhoneNumber => _phoneNumber;

  @override
  UserRole? get currentRole => _role;

  @override
  bool get hasProfile => _hasProfile;

  @override
  bool get isLoading => _isLoading;

  SupabaseAuthRepository() {
    _userId = _client.auth.currentUser?.id;
    _phoneNumber = _client.auth.currentUser?.email?.split('@').first;
    if (_userId != null) {
      checkExistingProfile();
    }
  }

  @override
  Future<void> signInWithPhone(String phoneNumber) async {
    _isLoading = true;
    notifyListeners();
    try {
      // In a real app with SMS OTP enabled, we would do:
      // await _client.auth.signInWithOtp(phone: phoneNumber);

      // As auth OTP is skipped/bypassed, we simulate sending code.
      await Future.delayed(const Duration(seconds: 1));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  Future<bool> verifyOtp(String phoneNumber, String otp) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Bypassing SMS OTP by signing in/up with an email/password under the hood.
      // Phone number format becomes email placeholder.
      final cleanPhone = phoneNumber.replaceAll('+', '').trim();
      final email = '$cleanPhone@seralgn.mock';
      const password = 'StaticMockPassword123!';

      try {
        // Try logging in first
        final response = await _client.auth.signInWithPassword(
          email: email,
          password: password,
        );
        _userId = response.user?.id;
        _phoneNumber = phoneNumber;
      } on AuthException catch (e) {
        // If user doesn't exist, sign them up
        if (e.message.contains('Invalid login credentials') ||
            e.message.contains('User not found')) {
          final response = await _client.auth.signUp(
            email: email,
            password: password,
          );
          _userId = response.user?.id;
          _phoneNumber = phoneNumber;
        } else {
          rethrow;
        }
      }

      await checkExistingProfile();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseAuthRepository error: $e');
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  Future<void> registerClient(String fullName) async {
    if (_userId == null || _phoneNumber == null) {
      throw StateError('Cannot register profile: User is not authenticated.');
    }

    _isLoading = true;
    notifyListeners();
    try {
      await _client.from('clients').insert({
        'id': _userId,
        'full_name': fullName,
        'phone_number': _phoneNumber,
      });
      _role = UserRole.client;
      _hasProfile = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  Future<void> registerWorker(String fullName, String faydaNumber) async {
    if (_userId == null || _phoneNumber == null) {
      throw StateError('Cannot register profile: User is not authenticated.');
    }

    _isLoading = true;
    notifyListeners();
    try {
      await _client.from('workers').insert({
        'id': _userId,
        'full_name': fullName,
        'phone_number': _phoneNumber,
        'fayda_number': faydaNumber,
        'fayda_verified': false,
        'trial_ends_at': DateTime.now()
            .add(const Duration(days: 30))
            .toIso8601String(),
      });
      _role = UserRole.worker;
      _hasProfile = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
    _userId = null;
    _phoneNumber = null;
    _role = null;
    _hasProfile = false;
    notifyListeners();
  }

  @override
  Future<void> checkExistingProfile() async {
    if (_userId == null) return;

    _isLoading = true;
    notifyListeners();
    try {
      // 1. Check if user is a Client
      final clientRes = await _client
          .from('clients')
          .select()
          .eq('id', _userId!)
          .maybeSingle();

      if (clientRes != null) {
        _role = UserRole.client;
        _hasProfile = true;
        return;
      }

      // 2. Check if user is a Worker
      final workerRes = await _client
          .from('workers')
          .select()
          .eq('id', _userId!)
          .maybeSingle();

      if (workerRes != null) {
        _role = UserRole.worker;
        _hasProfile = true;
        return;
      }

      // Neither profiles exist: user is authenticated but not registered
      _role = null;
      _hasProfile = false;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking existing profile: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

class MockAuthRepository extends ChangeNotifier implements AuthRepository {
  String? _userId;
  String? _phoneNumber;
  UserRole? _role;
  bool _hasProfile = false;
  bool _isLoading = false;

  @override
  String? get currentUserId => _userId;

  @override
  String? get currentPhoneNumber => _phoneNumber;

  @override
  UserRole? get currentRole => _role;

  @override
  bool get hasProfile => _hasProfile;

  @override
  bool get isLoading => _isLoading;

  // Static list to persist profiles during mock session
  static final Map<String, String> _mockClients = {}; // id -> fullName
  static final Map<String, Map<String, String>> _mockWorkers =
      {}; // id -> {fullName, fayda}

  @override
  Future<void> signInWithPhone(String phoneNumber) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    _isLoading = false;
    notifyListeners();
  }

  @override
  Future<bool> verifyOtp(String phoneNumber, String otp) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));

    // Deterministic UUID for the phone number to simulate persistent sessions
    _userId = 'mock-user-uuid-${phoneNumber.replaceAll('+', '')}';
    _phoneNumber = phoneNumber;

    await checkExistingProfile();

    _isLoading = false;
    notifyListeners();
    return true;
  }

  @override
  Future<void> registerClient(String fullName) async {
    if (_userId == null) throw StateError('Not authenticated');
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));

    _mockClients[_userId!] = fullName;
    _role = UserRole.client;
    _hasProfile = true;

    _isLoading = false;
    notifyListeners();
  }

  @override
  Future<void> registerWorker(String fullName, String faydaNumber) async {
    if (_userId == null) throw StateError('Not authenticated');
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));

    _mockWorkers[_userId!] = {'fullName': fullName, 'faydaNumber': faydaNumber};
    _role = UserRole.worker;
    _hasProfile = true;

    _isLoading = false;
    notifyListeners();
  }

  @override
  Future<void> signOut() async {
    _userId = null;
    _phoneNumber = null;
    _role = null;
    _hasProfile = false;
    notifyListeners();
  }

  @override
  Future<void> checkExistingProfile() async {
    if (_userId == null) return;

    if (_mockClients.containsKey(_userId)) {
      _role = UserRole.client;
      _hasProfile = true;
    } else if (_mockWorkers.containsKey(_userId)) {
      _role = UserRole.worker;
      _hasProfile = true;
    } else {
      _role = null;
      _hasProfile = false;
    }
  }
}
