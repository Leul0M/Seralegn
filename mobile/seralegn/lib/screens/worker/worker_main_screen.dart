import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/booking.dart';
import '../../models/job.dart';
import '../../models/user_role.dart';
import '../../providers/language_provider.dart';
import '../../services/booking_service.dart';
import '../../services/hive_service.dart';
import '../../services/job_service.dart';
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

  List<Job> _allJobs = [];
  List<Booking> _bookings = [];
  bool _isLoading = true;
  bool _isOffline = false;

  String get _currentUserId =>
      Supabase.instance.client.auth.currentUser?.id ?? '';

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), _loadData);
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() { _isLoading = true; _isOffline = false; });

    final userData = HiveService.instance.getUserData();
    final phone = (userData['phoneNumber'] as String?)?.trim() ?? '';

    if (phone.isEmpty) {
      setState(() { _isLoading = false; _isOffline = false; });
      return;
    }

    try {
      final jobs = await JobService.instance.fetchOpenJobs();
      final bookings = await BookingService.instance.fetchWorkerBookings(phone);
      if (mounted) {
        setState(() {
          _allJobs = jobs;
          _bookings = bookings;
          _isLoading = false;
          _isOffline = false;
        });
      }
    } on SocketException {
      if (mounted) setState(() { _isLoading = false; _isOffline = true; });
    } catch (e) {
      if (mounted) {
        setState(() { _isLoading = false; _isOffline = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not load jobs: ${e.toString()}'),
            backgroundColor: const Color(0xFFEF4444),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _loadData,
            ),
          ),
        );
      }
    }
  }

  List<Job> get _activeJobs => _allJobs
      .where((j) =>
          j.status == JobStatus.accepted ||
          j.status == JobStatus.inProgress ||
          j.status == JobStatus.awaitingApproval)
      .toList();

  List<Job> get _pastJobs =>
      _allJobs.where((j) => j.status == JobStatus.completed).toList();

  Future<void> _onAddBooking(Booking newBooking) async {
    try {
      final created = await BookingService.instance.createBooking(newBooking);
      setState(() { _bookings.insert(0, created); });
    } catch (_) {
      setState(() { _bookings.insert(0, newBooking); });
    }
  }

  Future<void> _updateBookingStatus(Booking booking, BookingStatus newStatus) async {
    try {
      await BookingService.instance.updateBookingStatus(booking.id, newStatus);
      setState(() { booking.status = newStatus; });
    } catch (_) {
      setState(() { booking.status = newStatus; });
    }
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
          onAcceptJob: () async {
            final messenger = ScaffoldMessenger.of(context);
            final jobTitle = job.title;
            Navigator.pop(context);

            try {
              await JobService.instance.claimJob(
                jobId: job.id,
                workerId: _currentUserId,
              );
              setState(() {
                job.status = JobStatus.accepted;
                job.workerId = _currentUserId;
                _currentIndex = 1;
              });
              messenger.showSnackBar(
                SnackBar(
                  content: Text('Job "$jobTitle" claimed successfully!'),
                  backgroundColor: const Color(0xFF10B981),
                ),
              );
            } catch (e) {
              messenger.showSnackBar(
                SnackBar(
                  content: Text('Failed to claim job: ${e.toString()}'),
                  backgroundColor: const Color(0xFFEF4444),
                ),
              );
            }
          },
        );
      },
    );
  }

  Future<void> _updateJobStatus(Job job, JobStatus newStatus) async {
    try {
      await JobService.instance.updateJobStatus(job.id, newStatus);
      setState(() { job.status = newStatus; });
    } catch (_) {
      setState(() { job.status = newStatus; });
    }
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

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_isOffline) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wifi_off_rounded, size: 64, color: AppTheme.lightText),
                const SizedBox(height: 16),
                const Text(
                  'You are offline',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.darkText),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please connect back to the internet to see job offers.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppTheme.secondaryText),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() { _isLoading = true; _isOffline = false; });
                    _loadData();
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryTeal,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(140, 48),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final pendingBookings = _bookings.where((b) => b.status == BookingStatus.pending).length;

    final List<Widget> pages = [
      WorkerMarketplaceScreen(
        availableJobs: _allJobs,
        currentWorkerId: _currentUserId,
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
        onAddBooking: _onAddBooking,
        onUpdateStatus: _updateBookingStatus,
        currentUserId: _currentUserId,
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
