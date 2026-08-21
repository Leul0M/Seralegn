import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/booking.dart';
import '../../models/user_role.dart';
import '../../providers/language_provider.dart';
import '../../theme/app_theme.dart';
import 'create_booking_sheet.dart';

class BookingsScreen extends StatefulWidget {
  final UserRole userRole;
  final List<Booking> bookings;
  final Function(Booking) onAddBooking;
  final Function(Booking, BookingStatus) onUpdateStatus;
  final String currentUserId;

  const BookingsScreen({
    super.key,
    required this.userRole,
    required this.bookings,
    required this.onAddBooking,
    required this.onUpdateStatus,
    required this.currentUserId,
  });

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  String _selectedFilter = 'All';

  void _openBookingSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateBookingSheet(
        onBookingCreated: widget.onAddBooking,
        currentUserId: widget.currentUserId,
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  List<Booking> get _filteredBookings {
    if (_selectedFilter == 'Pending') {
      return widget.bookings.where((b) => b.status == BookingStatus.pending).toList();
    } else if (_selectedFilter == 'Confirmed') {
      return widget.bookings.where((b) => b.status == BookingStatus.confirmed).toList();
    } else if (_selectedFilter == 'Completed') {
      return widget.bookings.where((b) => b.status == BookingStatus.completed).toList();
    }
    return widget.bookings;
  }

  @override
  Widget build(BuildContext context) {
    final lang = Get.find<LanguageController>();
    final isClient = widget.userRole == UserRole.client;
    final totalCount = widget.bookings.length;

    return Obx(() => Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      floatingActionButton: isClient
          ? FloatingActionButton.extended(
              onPressed: _openBookingSheet,
              backgroundColor: AppTheme.primaryTeal,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: Text(
                lang.newBooking,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row with Book Button for Client
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lang.bookingsTab,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$totalCount total appointment${totalCount == 1 ? '' : 's'}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isClient)
                    SizedBox(
                      width: 130,
                      child: ElevatedButton.icon(
                        onPressed: _openBookingSheet,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryTeal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.calendar_month_rounded, size: 16),
                        label: Text(
                          lang.bookWorker,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('All (${widget.bookings.length})', 'All'),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'Pending (${widget.bookings.where((b) => b.status == BookingStatus.pending).length})',
                      'Pending',
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'Confirmed (${widget.bookings.where((b) => b.status == BookingStatus.confirmed).length})',
                      'Confirmed',
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'Completed (${widget.bookings.where((b) => b.status == BookingStatus.completed).length})',
                      'Completed',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Bookings List
              if (_filteredBookings.isEmpty)
                _buildEmptyState(isClient)
              else
                ..._filteredBookings.map((booking) => _buildBookingCard(booking, isClient)),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    ));
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? Colors.white : AppTheme.secondaryText,
        ),
      ),
      selected: isSelected,
      selectedColor: AppTheme.primaryTeal,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryTeal : const Color(0xFFE2E8F0),
        ),
      ),
      onSelected: (_) {
        setState(() => _selectedFilter = value);
      },
    );
  }

  Widget _buildEmptyState(bool isClient) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          const Icon(Icons.calendar_month_outlined, size: 48, color: AppTheme.lightText),
          const SizedBox(height: 12),
          Text(
            'No ${_selectedFilter.toLowerCase()} bookings found',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.darkText),
          ),
          const SizedBox(height: 4),
          Text(
            isClient
                ? 'Schedule a worker for a specific date to see it here.'
                : 'Direct date bookings from clients will appear here with push notifications.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: AppTheme.secondaryText),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Booking booking, bool isClient) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Status Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: booking.status.backgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              booking.status.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: booking.status.color,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Date & Time Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.event_rounded, color: AppTheme.primaryTeal, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(booking.bookingDate),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      booking.timeSlot,
                      style: const TextStyle(fontSize: 12, color: AppTheme.secondaryText),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Person Details
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFEEF2FF),
                child: Text(
                  isClient ? booking.workerName[0] : booking.clientName[0],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryTeal,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isClient ? 'Worker: ${booking.workerName}' : 'Client: ${booking.clientName}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.darkText),
                  ),
                  Text(
                    isClient ? booking.workerPhone : booking.clientPhone,
                    style: const TextStyle(fontSize: 11, color: AppTheme.secondaryText),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.secondaryText),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  booking.address,
                  style: const TextStyle(fontSize: 12, color: AppTheme.secondaryText),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          if (booking.notes.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Notes: "${booking.notes}"',
              style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppTheme.lightText),
            ),
          ],

          const SizedBox(height: 14),

          // Action Buttons
          if (booking.status == BookingStatus.pending) ...[
            Row(
              children: [
                if (!isClient) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        widget.onUpdateStatus(booking, BookingStatus.confirmed);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Booking accepted! Notification sent to ${booking.clientName}.'),
                            backgroundColor: const Color(0xFF10B981),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.check_circle_rounded, size: 16),
                      label: const Text('Accept Booking'),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      widget.onUpdateStatus(booking, BookingStatus.cancelled);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Booking cancelled.'),
                          backgroundColor: Color(0xFFEF4444),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      side: const BorderSide(color: Color(0xFFFCA5A5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.cancel_outlined, size: 16),
                    label: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ] else if (booking.status == BookingStatus.confirmed) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  widget.onUpdateStatus(booking, BookingStatus.completed);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Appointment marked as completed!'),
                      backgroundColor: Color(0xFF10B981),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryTeal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.task_alt_rounded, size: 16),
                label: const Text('Mark Appointment Completed'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

