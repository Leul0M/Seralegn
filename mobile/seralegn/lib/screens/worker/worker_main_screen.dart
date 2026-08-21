import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/booking.dart';
import '../../models/job.dart';
import '../../models/user_role.dart';
import '../../providers/language_provider.dart';
import '../../theme/app_theme.dart';
import '../bookings/bookings_screen.dart';
import 'worker_accept_job_sheet.dart';
import 'worker_active_jobs_screen.dart';
import 'worker_marketplace_screen.dart';
import 'worker_profile_screen.dart';
import 'worker_subscription_screen.dart';

class WorkerMainScreen extends StatefulWidget {
  final VoidCallback onSwitchRole;
  final VoidCallback onLogout;

  const WorkerMainScreen({
    super.key,
    required this.onSwitchRole,
    required this.onLogout,
  });

  @override
  State<WorkerMainScreen> createState() => _WorkerMainScreenState();
}

class _WorkerMainScreenState extends State<WorkerMainScreen> {
  int _currentIndex = 0;

  late List<Job> _allJobs;
  late List<Booking> _bookings;

  @override
  void initState() {
    super.initState();
    _allJobs = Job.getSampleJobs();
    _bookings = Booking.getSampleBookings();
  }

  List<Job> get _activeJobs => _allJobs
      .where((j) =>
          j.status == JobStatus.accepted ||
          j.status == JobStatus.inProgress ||
          j.status == JobStatus.awaitingApproval)
      .toList();

  List<Job> get _pastJobs =>
      _allJobs.where((j) => j.status == JobStatus.completed).toList();

  void _addBooking(Booking newBooking) {
    setState(() {
      _bookings.insert(0, newBooking);
    });
  }

  void _updateBookingStatus(Booking booking, BookingStatus newStatus) {
    setState(() {
      booking.status = newStatus;
    });
  }

  void _openClaimJobSheet(Job job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return WorkerAcceptJobSheet(
          job: job,
          onClose: () => Navigator.pop(context),
          onAcceptJob: () {
            // Capture ScaffoldMessenger BEFORE pop() deactivates the sheet's
            // context — otherwise we'd get a 'deactivated widget' error.
            final messenger = ScaffoldMessenger.of(context);
            final jobTitle = job.title;
            Navigator.pop(context);
            setState(() {
              job.status = JobStatus.accepted;
              job.workerId = 'worker-girma';
              _currentIndex = 1; // Switch to My Jobs tab
            });
            messenger.showSnackBar(
              SnackBar(
                content: Text('Job "$jobTitle" claimed successfully!'),
                backgroundColor: const Color(0xFF10B981),
              ),
            );
          },
        );
      },
    );
  }

  void _updateJobStatus(Job job, JobStatus newStatus) {
    setState(() {
      job.status = newStatus;
    });
  }

  void _openSubscriptionModal() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const WorkerSubscriptionScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = Get.find<LanguageController>();
    final pendingBookings = _bookings.where((b) => b.status == BookingStatus.pending).length;

    final List<Widget> pages = [
      WorkerMarketplaceScreen(
        availableJobs: _allJobs,
        onClaimJobPressed: _openClaimJobSheet,
        onDetailsPressed: _openClaimJobSheet,
        onRenewPlanPressed: _openSubscriptionModal,
      ),
      WorkerActiveJobsScreen(
        activeJobs: _activeJobs,
        pastJobs: _pastJobs,
        onBrowseJobsPressed: () => setState(() => _currentIndex = 0),
        onUpdateJobStatus: _updateJobStatus,
      ),
      BookingsScreen(
        userRole: UserRole.worker,
        bookings: _bookings,
        onAddBooking: _addBooking,
        onUpdateStatus: _updateBookingStatus,
      ),
      WorkerProfileScreen(
        onSwitchRole: widget.onSwitchRole,
        onLogout: widget.onLogout,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Obx(() => Container(
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
                _buildNavItem(
                  index: 0,
                  icon: Icons.explore_outlined,
                  activeIcon: Icons.explore_rounded,
                  label: lang.feedTab,
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.format_list_bulleted_rounded,
                  activeIcon: Icons.format_list_bulleted_rounded,
                  label: lang.myJobsTab,
                  badgeCount: _activeJobs.length,
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.calendar_month_outlined,
                  activeIcon: Icons.calendar_month_rounded,
                  label: lang.bookingsTab,
                  badgeCount: pendingBookings,
                ),
                _buildNavItem(
                  index: 3,
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: lang.profileTab,
                ),
              ],
            ),
          ),
        ),
      )),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
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
                isSelected ? activeIcon : icon,
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
