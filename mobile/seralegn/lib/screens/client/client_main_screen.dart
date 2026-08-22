import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/booking.dart';
import '../../models/job.dart';
import '../../models/user_role.dart';
import '../../providers/language_provider.dart';
import '../../services/booking_service.dart';
import '../../services/hive_service.dart';
import '../../services/job_service.dart';
import '../../theme/app_theme.dart';
import '../bookings/bookings_screen.dart';
import 'client_homescreen.dart';
import 'client_post_job_screen.dart';
import 'client_profile_screen.dart';

class ClientMainScreen extends StatefulWidget {
  final VoidCallback onSwitchRole;
  final VoidCallback onLogout;

  const ClientMainScreen({
    super.key,
    required this.onSwitchRole,
    required this.onLogout,
  });

  @override
  State<ClientMainScreen> createState() => _ClientMainScreenState();
}

class _ClientMainScreenState extends State<ClientMainScreen> {
  int _currentIndex = 0;
  List<Job> _clientJobs = [];
  List<Booking> _clientBookings = [];
  bool _isLoading = true;
  bool _isOffline = false;

  String get _currentUserId {
    final userData = HiveService.instance.getUserData();
    final phone = (userData['phoneNumber'] as String?)?.trim() ?? '';
    return phone;
  }

  @override
  void initState() {
    super.initState();
    // Wait a short moment in case Supabase is still restoring the auth session
    // then load data. This prevents a false "offline" state on app start.
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
      final jobs = await JobService.instance.fetchClientJobs(phone);
      final bookings = await BookingService.instance.fetchClientBookings(phone);
      if (mounted) {
        setState(() {
          _clientJobs = jobs;
          _clientBookings = bookings;
          _isLoading = false;
          _isOffline = false;
        });
      }
    } on SocketException {
      // Genuine network/connectivity error
      if (mounted) setState(() { _isLoading = false; _isOffline = true; });
    } catch (e) {
      // Supabase/RLS/auth error — NOT an offline scenario
      if (mounted) {
        setState(() { _isLoading = false; _isOffline = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not load data: ${e.toString()}'),
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

  Future<void> _onJobCreated(Job newJob, List<XFile> imageFiles) async {
    try {
      final userData = HiveService.instance.getUserData();
      final name = (userData['fullName'] as String?) ?? 'Client';
      final phone = (userData['phoneNumber'] as String?) ?? '';

      final jobToPost = Job(
        id: '',
        title: newJob.title,
        description: newJob.description,
        category: newJob.category,
        budgetEtb: newJob.budgetEtb,
        neighborhood: newJob.neighborhood,
        addressDetail: newJob.addressDetail,
        latitude: newJob.latitude,
        longitude: newJob.longitude,
        status: JobStatus.open,
        clientName: name,
        clientPhone: phone,
        isClientVerified: true,
        distanceKm: 0,
        postedAt: DateTime.now(),
        clientId: _currentUserId,
        imagePaths: [],
      );

      final result = await JobService.instance.postJob(
        job: jobToPost,
        clientId: _currentUserId,
        imageFiles: imageFiles,
      );

      if (mounted) {
        setState(() {
          _clientJobs.insert(0, result.job);
          _currentIndex = 0;
        });

        if (result.failedUploads > 0 && imageFiles.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Job posted! ${result.failedUploads} photo(s) could not be '
                'uploaded due to network issues.',
              ),
              backgroundColor: const Color(0xFFF59E0B),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final errStr = e.toString();
        final isNetworkErr = errStr.contains('SocketException') || errStr.contains('Failed host lookup');
        final message = isNetworkErr
            ? 'Network error: Please check your internet connection and try again.'
            : 'Failed to post job: $e';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  Future<void> _onApproveJob(Job job) async {
    try {
      await JobService.instance.approveJobCompletion(
        jobId: job.id,
        clientId: _currentUserId,
      );
      setState(() {
        job.isCompleted = true;
        job.status = JobStatus.completed;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job completion approved! Work is marked as completed.'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to approve job: ${e.toString()}'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  Future<void> _onCancelJob(Job job) async {
    if (job.status != JobStatus.open) return;
    try {
      await JobService.instance.cancelJob(job.id);
      setState(() {
        _clientJobs.removeWhere((j) => j.id == job.id);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job cancelled successfully.'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel job: ${e.toString()}'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  Future<void> _onAddBooking(Booking newBooking) async {
    try {
      final created = await BookingService.instance.createBooking(newBooking);
      setState(() {
        _clientBookings.insert(0, created);
        _currentIndex = 1;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create booking: ${e.toString()}'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  Future<void> _updateBookingStatus(Booking booking, BookingStatus newStatus) async {
    try {
      await BookingService.instance.updateBookingStatus(booking.id, newStatus);
      setState(() { booking.status = newStatus; });
    } catch (_) {
      // If offline, update locally
      setState(() { booking.status = newStatus; });
    }
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
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryTeal,
                      minimumSize: const Size(120, 44),
                    ),
                    child: const Text('Close'),
                  ),
                  if (job.status == JobStatus.awaitingApproval && !job.isCompleted) ...[
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _onApproveJob(job);
                      },
                      icon: const Icon(Icons.verified_rounded, size: 16),
                      label: const Text('Approve Work'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(120, 44),
                      ),
                    ),
                  ],
                  if (job.status == JobStatus.open) ...[
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _onCancelJob(job);
                      },
                      icon: const Icon(Icons.cancel_outlined, size: 16),
                      label: const Text('Cancel Job'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFEF4444),
                        side: const BorderSide(color: Color(0xFFFCA5A5)),
                        minimumSize: const Size(120, 44),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
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
                  'Please connect back to the internet to see your jobs or post new ones.',
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

    final List<Widget> pages = [
      ClientHomeScreen(
        jobs: _clientJobs,
        onPostJobPressed: () => setState(() => _currentIndex = 2),
        onJobSelected: _showJobDetailModal,
        onCancelJob: _onCancelJob,
        onApproveJob: _onApproveJob,
        onGoToBookings: () => setState(() => _currentIndex = 1),
      ),
      BookingsScreen(
        userRole: UserRole.client,
        bookings: _clientBookings,
        onAddBooking: _onAddBooking,
        onUpdateStatus: _updateBookingStatus,
        currentUserId: _currentUserId,
      ),
      ClientPostJobScreen(
        onJobCreated: _onJobCreated,
        onCancel: () => setState(() => _currentIndex = 0),
      ),
      ClientProfileScreen(
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
                  icon: Icons.home_rounded,
                  label: lang.homeTab,
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.calendar_month_rounded,
                  label: lang.bookingsTab,
                  badgeCount: _clientBookings.where((b) => b.status == BookingStatus.pending).length,
                ),
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
                _buildNavItem(
                  index: 3,
                  icon: Icons.person_outline_rounded,
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
