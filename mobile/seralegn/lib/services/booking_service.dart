import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/booking.dart';

/// Service that handles all Supabase operations for bookings.
class BookingService {
  static final BookingService instance = BookingService._();
  BookingService._();

  SupabaseClient get _client => Supabase.instance.client;

  // ─────────────────────────────────────────────────────────────────────────
  // Fetch bookings for a client
  // ─────────────────────────────────────────────────────────────────────────
  Future<List<Booking>> fetchClientBookings(String clientId) async {
    final response = await _client
        .from('bookings')
        .select()
        .eq('client_id', clientId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((row) => Booking.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Fetch bookings for a worker
  // ─────────────────────────────────────────────────────────────────────────
  Future<List<Booking>> fetchWorkerBookings(String workerId) async {
    final response = await _client
        .from('bookings')
        .select()
        .eq('worker_id', workerId)
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
    final response = await _client
        .from('bookings')
        .insert(booking.toMap())
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
