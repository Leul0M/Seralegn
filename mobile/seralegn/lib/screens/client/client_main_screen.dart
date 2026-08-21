import 'package:flutter/material.dart';
import '../../models/booking.dart';
import '../../models/job.dart';
import '../../models/user_role.dart';
import '../../theme/app_theme.dart';
import '../bookings/bookings_screen.dart';
import 'client_homescreen.dart';
import 'client_post_job_screen.dart';
import 'client_profile_screen.dart';

class ClientMainScreen extends StatefulWidget {
  final VoidCallback onSwitchRole;

  const ClientMainScreen({
    super.key,
    required this.onSwitchRole,
  });

  @override
  State<ClientMainScreen> createState() => _ClientMainScreenState();
}

class _ClientMainScreenState extends State<ClientMainScreen> {
  int _currentIndex = 0;
  late List<Job> _clientJobs;
  late List<Booking> _clientBookings;

  @override
  void initState() {
    super.initState();
    _clientJobs = Job.getSampleJobs();
    _clientBookings = Booking.getSampleBookings();
  }

  void _addJob(Job newJob) {
    setState(() {
      _clientJobs.insert(0, newJob);
      _currentIndex = 0; // Return to home tab to see the new job
    });
  }

  void _addBooking(Booking newBooking) {
    setState(() {
      _clientBookings.insert(0, newBooking);
      _currentIndex = 1; // Switch to Bookings tab
    });
  }

  void _updateBookingStatus(Booking booking, BookingStatus newStatus) {
    setState(() {
      booking.status = newStatus;
    });
  }

  void _showJobDetailModal(Job job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      job.category.shortTitle,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryTeal,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${job.budgetEtb.toInt()} ETB',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryTeal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                job.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                job.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.secondaryText,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 16, color: AppTheme.secondaryText),
                  const SizedBox(width: 4),
                  Text(
                    '${job.neighborhood} (${job.addressDetail})',
                    style: const TextStyle(fontSize: 13, color: AppTheme.secondaryText),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time_rounded, size: 16, color: AppTheme.secondaryText),
                  const SizedBox(width: 4),
                  Text(
                    'Status: ${job.status.label}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: job.status.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryTeal,
                  minimumSize: const Size(120, 44),
                ),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      ClientHomeScreen(
        jobs: _clientJobs,
        onPostJobPressed: () => setState(() => _currentIndex = 2),
        onJobSelected: _showJobDetailModal,
        onBookingCreated: _addBooking,
      ),
      BookingsScreen(
        userRole: UserRole.client,
        bookings: _clientBookings,
        onAddBooking: _addBooking,
        onUpdateStatus: _updateBookingStatus,
      ),
      ClientPostJobScreen(
        onJobCreated: _addJob,
        onCancel: () => setState(() => _currentIndex = 0),
      ),
      ClientProfileScreen(
        onSwitchRole: widget.onSwitchRole,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Home Tab
                _buildNavItem(
                  index: 0,
                  icon: Icons.home_rounded,
                  label: 'Home',
                ),

                // Bookings Tab
                _buildNavItem(
                  index: 1,
                  icon: Icons.calendar_month_rounded,
                  label: 'Bookings',
                  badgeCount: _clientBookings.where((b) => b.status == BookingStatus.pending).length,
                ),

                // Center Floating Post Button
                GestureDetector(
                  onTap: () => setState(() => _currentIndex = 2),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryTeal,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryTeal.withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),

                // Profile Tab
                _buildNavItem(
                  index: 3,
                  icon: Icons.person_outline_rounded,
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    int badgeCount = 0,
  }) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                icon,
                color: isSelected ? AppTheme.primaryTeal : AppTheme.lightText,
                size: 24,
              ),
              if (badgeCount > 0)
                Positioned(
                  right: -6,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF59E0B),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$badgeCount',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? AppTheme.primaryTeal : AppTheme.lightText,
            ),
          ),
        ],
      ),
    );
  }
}
