import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/booking.dart';

/// Service that handles all Supabase operations for bookings.
class BookingService {
  static final BookingService instance = BookingService._();
  BookingService._();

  SupabaseClient get _client => Supabase.instance.client;

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
    final response = await _client.rpc(
      'lookup_worker_by_phone',
      params: {'p_phone': phone},
    );
    final rows = response as List<dynamic>;
    if (rows.isEmpty) return null;
    return Map<String, dynamic>.from(rows.first as Map);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Create a new booking
  // ─────────────────────────────────────────────────────────────────────────
  Future<Booking> createBooking(Booking booking) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw StateError('You must be logged in to create a booking.');
    }

    final clientProfile = await _client
        .from('clients')
        .select('id')
        .eq('id', user.id)
        .maybeSingle();
    if (clientProfile == null) {
      throw StateError('Only client accounts can create bookings.');
    }
    if (booking.workerId == null || booking.workerId!.trim().isEmpty) {
      throw StateError('Select a registered worker before creating a booking.');
    }

    final map = booking.toMap();
    map['client_id'] = user.id;
    map['worker_id'] = booking.workerId!.trim();

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
    final updatedRows = await _client
        .from('bookings')
        .update({'status': statusStr})
        .eq('id', bookingId)
        .select('id');
    if (updatedRows.isEmpty) {
      throw StateError('Booking was not updated. It may no longer be available.');
    }
  }
}
