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
  });

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
