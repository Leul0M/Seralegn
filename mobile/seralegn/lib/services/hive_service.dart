import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_role.dart';

class HiveService {
  static final HiveService instance = HiveService._();
  HiveService._();

  static const String boxName = 'auth_box';

  Box? _box;

  Box get _authBox {
    if (_box == null || !_box!.isOpen) {
      throw StateError(
        'HiveService has not been initialized. Call init() first.',
      );
    }
    return _box!;
  }

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(boxName);
  }

  bool isLoggedIn() => Supabase.instance.client.auth.currentUser != null;

  UserRole? getRole() {
    final roleName =
        Supabase.instance.client.auth.currentUser?.userMetadata?['role'];
    for (final role in UserRole.values) {
      if (role.name == roleName) return role;
    }
    return null;
  }

  Map<String, dynamic> getUserData() {
    final user = Supabase.instance.client.auth.currentUser;
    final metadata = user?.userMetadata ?? const <String, dynamic>{};
    return {
      'isLoggedIn': user != null,
      'id': user?.id ?? '',
      'role': getRole(),
      'fullName': metadata['full_name'] as String? ?? '',
      'phoneNumber': metadata['phone_number'] as String? ?? '',
      'neighborhood': metadata['neighborhood'] as String? ?? '',
      'faydaNumber': metadata['fayda_number'] as String? ?? '',
      'isFaydaVerified': metadata['fayda_verified'] as bool? ?? false,
      'profilePhoto': metadata['profile_photo'] as String? ?? '',
    };
  }

  Future<void> clearSession() async {
    await _authBox.clear();
  }
}
