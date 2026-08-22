import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/booking.dart';
import 'auth_service.dart';

/// Service that handles all Supabase operations for bookings.
class BookingService {
  static final BookingService instance = BookingService._();
  BookingService._();

  SupabaseClient get _client => Supabase.instance.client;

  Future<List<Booking>> fetchClientBookings(String phoneOrId) async {
    final clean = phoneOrId.trim();
    if (clean.isEmpty) return [];

    final isPhone = !clean.contains('-');
    final queryField = isPhone ? 'client_phone' : 'client_id';

    final response = await _client
        .from('bookings')
        .select()
        .eq(queryField, clean)
        .order('created_at', ascending: false);

    return (response as List)
        .map((row) => Booking.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Fetch bookings for a worker
  // ─────────────────────────────────────────────────────────────────────────
  Future<List<Booking>> fetchWorkerBookings(String phoneOrId) async {
    final clean = phoneOrId.trim();
    if (clean.isEmpty) return [];

    final isPhone = !clean.contains('-');
    final queryField = isPhone ? 'worker_phone' : 'worker_id';

    final response = await _client
        .from('bookings')
        .select()
        .eq(queryField, clean)
        .order('created_at', ascending: false);

    return (response as List)
        .map((row) => Booking.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Lookup a worker by phone number
  // ─────────────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> findWorkerByPhone(String phone) async {
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');
    final response = await _client
        .from('workers')
        .select('id, full_name, phone_number')
        .eq('phone_number', cleaned)
        .maybeSingle();
    return response;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Create a new booking
  // ─────────────────────────────────────────────────────────────────────────
  Future<Booking> createBooking(Booking booking) async {
    final activeClientId = (booking.clientId != null && booking.clientId!.isNotEmpty)
        ? booking.clientId!
        : (_client.auth.currentUser?.id ?? await AuthService.instance.ensureSupabaseSession());

    final map = booking.toMap();
    if (activeClientId != null && activeClientId.isNotEmpty) {
      map['client_id'] = activeClientId;
    } else {
      map.remove('client_id');
    }

    final response = await _client
        .from('bookings')
        .insert(map)
        .select()
        .single();

    return Booking.fromMap(response);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Update booking status (accept / complete / cancel)
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> updateBookingStatus(String bookingId, BookingStatus status) async {
    final statusStr = switch (status) {
      BookingStatus.pending   => 'pending',
      BookingStatus.confirmed => 'confirmed',
      BookingStatus.completed => 'completed',
      BookingStatus.cancelled => 'cancelled',
    };
    await _client
        .from('bookings')
        .update({'status': statusStr})
        .eq('id', bookingId);
  }
}
