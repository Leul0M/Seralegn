import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // Developer: Populate these to connect to your live Supabase project
  static const String _supabaseUrl = ''; // E.g., 'https://xyz.supabase.co'
  static const String _supabaseAnonKey = '';

  static final SupabaseService instance = SupabaseService._internal();

  SupabaseService._internal();

  bool _mockMode = true;
  bool get mockMode => _mockMode;

  SupabaseClient get client {
    if (_mockMode) {
      throw StateError('Cannot access Supabase client when running in Mock Mode.');
    }
    return Supabase.instance.client;
  }

  Future<void> initialize() async {
    if (_supabaseUrl.isEmpty || _supabaseAnonKey.isEmpty) {
      if (kDebugMode) {
        print('------------------------------------------------------------');
        print('Seralgn Info: Supabase credentials are empty.');
        print('Running the app in [MOCK MODE] (In-Memory Database).');
        print('To use a real database, populate the keys in:');
        print('lib/data/services/supabase_service.dart');
        print('------------------------------------------------------------');
      }
      _mockMode = true;
      return;
    }

    try {
      await Supabase.initialize(
        url: _supabaseUrl,
        anonKey: _supabaseAnonKey,
      );
      _mockMode = false;
      if (kDebugMode) {
        print('Seralgn Info: Successfully connected to Supabase Database.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Seralgn Error: Failed to initialize Supabase. Fallback to [MOCK MODE].');
        print('Error: $e');
      }
      _mockMode = true;
    }
  }
}
