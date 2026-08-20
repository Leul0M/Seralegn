import 'package:flutter/material.dart';
import '../../models/job.dart';
import '../../theme/app_theme.dart';
import 'worker_accept_job_sheet.dart';
import 'worker_active_jobs_screen.dart';
import 'worker_marketplace_screen.dart';
import 'worker_profile_screen.dart';
import 'worker_subscription_screen.dart';

class WorkerMainScreen extends StatefulWidget {
  final VoidCallback onSwitchRole;

  const WorkerMainScreen({
    super.key,
    required this.onSwitchRole,
  });

  @override
  State<WorkerMainScreen> createState() => _WorkerMainScreenState();
}

class _WorkerMainScreenState extends State<WorkerMainScreen> {
  int _currentIndex = 0;

  late List<Job> _allJobs;

  @override
  void initState() {
    super.initState();
    _allJobs = Job.getSampleJobs();
  }

  List<Job> get _activeJobs => _allJobs
      .where((j) =>
          j.status == JobStatus.accepted ||
          j.status == JobStatus.inProgress ||
          j.status == JobStatus.awaitingApproval)
      .toList();

  List<Job> get _pastJobs =>
      _allJobs.where((j) => j.status == JobStatus.completed).toList();

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
            Navigator.pop(context);
            setState(() {
              job.status = JobStatus.accepted;
              job.workerId = 'worker-girma';
              _currentIndex = 1; // Switch to My Jobs tab
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Job "${job.title}" claimed successfully!'),
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

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      WorkerMarketplaceScreen(
        availableJobs: _allJobs,
        onClaimJobPressed: _openClaimJobSheet,
        onDetailsPressed: _openClaimJobSheet,
        onRenewPlanPressed: () => setState(() => _currentIndex = 2),
      ),
      WorkerActiveJobsScreen(
        activeJobs: _activeJobs,
        pastJobs: _pastJobs,
        onBrowseJobsPressed: () => setState(() => _currentIndex = 0),
        onUpdateJobStatus: _updateJobStatus,
      ),
      const WorkerSubscriptionScreen(),
      WorkerProfileScreen(
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
                _buildNavItem(
                  index: 0,
                  icon: Icons.explore_outlined,
                  activeIcon: Icons.explore_rounded,
                  label: 'Feed',
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.format_list_bulleted_rounded,
                  activeIcon: Icons.format_list_bulleted_rounded,
                  label: 'My Jobs',
                  badgeCount: _activeJobs.length,
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.credit_card_outlined,
                  activeIcon: Icons.credit_card_rounded,
                  label: 'Subscription',
                ),
                _buildNavItem(
                  index: 3,
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
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
                color: isSelected ? const Color(0xFF4F46E5) : AppTheme.lightText,
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
              color: isSelected ? const Color(0xFF4F46E5) : AppTheme.lightText,
            ),
          ),
        ],
      ),
    );
  }
}
