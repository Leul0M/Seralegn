import 'package:flutter/material.dart';
import 'job.dart';

enum BookingStatus {
  pending,
  confirmed,
  completed,
  cancelled,
}

extension BookingStatusExtension on BookingStatus {
  String get label {
    switch (this) {
      case BookingStatus.pending:
        return 'Pending Confirmation';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case BookingStatus.pending:
        return const Color(0xFFD97706); // Amber
      case BookingStatus.confirmed:
        return const Color(0xFF6366F1); // Indigo
      case BookingStatus.completed:
        return const Color(0xFF10B981); // Emerald
      case BookingStatus.cancelled:
        return const Color(0xFFEF4444); // Red
    }
  }

  Color get backgroundColor {
    switch (this) {
      case BookingStatus.pending:
        return const Color(0xFFFEF3C7);
      case BookingStatus.confirmed:
        return const Color(0xFFEEF2FF);
      case BookingStatus.completed:
        return const Color(0xFFECFDF5);
      case BookingStatus.cancelled:
        return const Color(0xFFFEF2F2);
    }
  }
}

class Booking {
  final String id;
  final String clientName;
  final String clientPhone;
  final String workerName;
  final String workerPhone;
  final JobCategory category;
  final DateTime bookingDate;
  final String timeSlot;
  final String address;
  final String notes;
  BookingStatus status;
  final DateTime createdAt;
  /// Supabase UUID of the client (auth user).
  final String? clientId;
  /// Supabase UUID of the assigned worker (auth user).
  final String? workerId;

  Booking({
    required this.id,
    required this.clientName,
    required this.clientPhone,
    required this.workerName,
    required this.workerPhone,
    required this.category,
    required this.bookingDate,
    required this.timeSlot,
    required this.address,
    this.notes = '',
    this.status = BookingStatus.pending,
    required this.createdAt,
    this.clientId,
    this.workerId,
  });

  /// Deserialize a booking from a Supabase row map.
  factory Booking.fromMap(Map<String, dynamic> map) {
    final catStr = (map['category'] as String? ?? 'electrical').toLowerCase();
    final category = JobCategory.values.firstWhere(
      (c) => c.name.toLowerCase() == catStr,
      orElse: () => JobCategory.electrical,
    );

    final statusStr = (map['status'] as String? ?? 'pending').toLowerCase();
    final BookingStatus status;
    switch (statusStr) {
      case 'pending':   status = BookingStatus.pending; break;
      case 'confirmed': status = BookingStatus.confirmed; break;
      case 'completed': status = BookingStatus.completed; break;
      case 'cancelled': status = BookingStatus.cancelled; break;
      default:          status = BookingStatus.pending;
    }

    return Booking(
      id: map['id'] as String,
      clientName: map['client_name'] as String? ?? '',
      clientPhone: map['client_phone'] as String? ?? '',
      workerName: map['worker_name'] as String? ?? '',
      workerPhone: map['worker_phone'] as String? ?? '',
      category: category,
      bookingDate: map['booking_date'] != null
          ? DateTime.parse(map['booking_date'] as String)
          : DateTime.now(),
      timeSlot: map['time_slot'] as String? ?? '',
      address: map['address'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
      status: status,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
      clientId: map['client_id'] as String?,
      workerId: map['worker_id'] as String?,
    );
  }

  /// Serialize to a map for inserting/updating in Supabase.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'client_name': clientName,
      'client_phone': clientPhone,
      'worker_name': workerName,
      'worker_phone': workerPhone,
      'category': category.name.toLowerCase(),
      'booking_date': bookingDate.toIso8601String(),
      'time_slot': timeSlot,
      'address': address,
      'notes': notes,
      'status': status.name.toLowerCase(),
    };
    if (clientId != null && clientId!.trim().isNotEmpty) {
      map['client_id'] = clientId!.trim();
    }
    if (workerId != null && workerId!.trim().isNotEmpty) {
      map['worker_id'] = workerId!.trim();
    }
    return map;
  }

  static List<Booking> getSampleBookings() {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    final nextWeek = now.add(const Duration(days: 4));

    return [
      Booking(
        id: 'bk-101',
        clientName: 'Solomon Ayalew',
        clientPhone: '+251 912 345 678',
        workerName: 'Yared Girma',
        workerPhone: '+251 944 567 890',
        category: JobCategory.electrical,
        bookingDate: tomorrow,
        timeSlot: 'Morning (09:00 AM - 12:00 PM)',
        address: 'Bole Atlas, Kirkos Tower Apt 4B',
        notes: 'Please inspect the circuit breaker and test electrical outlets.',
        status: BookingStatus.confirmed,
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      Booking(
        id: 'bk-102',
        clientName: 'Solomon Ayalew',
        clientPhone: '+251 912 345 678',
        workerName: 'Alemayehu Tadesse',
        workerPhone: '+251 911 887 123',
        category: JobCategory.plumbing,
        bookingDate: nextWeek,
        timeSlot: 'Afternoon (02:00 PM - 05:00 PM)',
        address: 'Kazanchis Near UNECA, Addis Ababa',
        notes: 'Water pipe leak repair in bathroom.',
        status: BookingStatus.pending,
        createdAt: now.subtract(const Duration(minutes: 30)),
      ),
    ];
  }
}
