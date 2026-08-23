import 'dart:convert';
import 'dart:math';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_role.dart';

class HiveService {
  static final HiveService instance = HiveService._();
  HiveService._();

  static const String boxName = 'auth_box';

  Box? _box;

  Box get _authBox {
    if (_box == null || !_box!.isOpen) {
      throw StateError('HiveService has not been initialized. Call init() first.');
    }
    return _box!;
  }

  /// Initialize Hive for Flutter and open the auth box
  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(boxName);
  }

  /// Generates a cryptographically secure random salt for per-user local password hashing
  String generateRandomSalt() {
    final random = Random.secure();
    final values = List<int>.generate(16, (_) => random.nextInt(256));
    return base64UrlEncode(values);
  }

  /// Save logged-in user session & profile locally in Hive
  Future<void> saveSession({
    required UserRole role,
    required String fullName,
    required String phoneNumber,
    String neighborhood = '',
    String password = '',
    String passwordSalt = '',
    String faydaNumber = '',
    bool isFaydaVerified = false,
    String profilePhoto = '',
  }) async {
    await _authBox.put('is_logged_in', true);
    await _authBox.put('user_role', role.name);
    await _authBox.put('full_name', fullName);
    await _authBox.put('phone_number', phoneNumber);
    await _authBox.put('neighborhood', neighborhood);
    if (password.isNotEmpty) {
      await _authBox.put('password', password);
    }
    if (passwordSalt.isNotEmpty) {
      await _authBox.put('password_salt', passwordSalt);
    }
    if (faydaNumber.isNotEmpty) {
      await _authBox.put('fayda_number', faydaNumber);
    }
    await _authBox.put('is_fayda_verified', isFaydaVerified);
    if (profilePhoto.isNotEmpty) {
      await _authBox.put('profile_photo', profilePhoto);
    }
  }

  /// Check if a user is logged in
  bool isLoggedIn() {
    return _authBox.get('is_logged_in', defaultValue: false) == true;
  }

  /// Retrieve the current cached UserRole
  UserRole? getRole() {
    final roleStr = _authBox.get('user_role') as String?;
    if (roleStr == 'worker') {
      return UserRole.worker;
    } else if (roleStr == 'client') {
      return UserRole.client;
    }
    return null;
  }

  /// Retrieve cached user profile details
  Map<String, dynamic> getUserData() {
    return {
      'isLoggedIn': isLoggedIn(),
      'role': getRole(),
      'fullName': _authBox.get('full_name', defaultValue: '') as String,
      'phoneNumber': _authBox.get('phone_number', defaultValue: '') as String,
      'neighborhood': _authBox.get('neighborhood', defaultValue: '') as String,
      'password': _authBox.get('password', defaultValue: '') as String,
      'passwordSalt': _authBox.get('password_salt', defaultValue: '') as String,
      'faydaNumber': _authBox.get('fayda_number', defaultValue: '') as String,
      'isFaydaVerified': _authBox.get('is_fayda_verified', defaultValue: false) as bool,
      'profilePhoto': _authBox.get('profile_photo', defaultValue: '') as String,
    };
  }

  /// Clear the local user session on logout
  Future<void> clearSession() async {
    await _authBox.put('is_logged_in', false);
    await _authBox.clear();
  }
}

