import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/worker_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/database_repository.dart';
import '../../core/theme.dart';
import 'worker_feed.dart';
import 'active_job_screen.dart';
import 'subscription_tab.dart';

class WorkerDashboard extends StatefulWidget {
  const WorkerDashboard({super.key});

  @override
  State<WorkerDashboard> createState() => _WorkerDashboardState();
}

class _WorkerDashboardState extends State<WorkerDashboard> {
  int _currentIndex = 0;
  WorkerModel? _worker;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (mounted) setState(() => _isLoading = true);
    final authRepo = Provider.of<AuthRepository>(context, listen: false);
    final dbRepo = Provider.of<DatabaseRepository>(context, listen: false);

    if (authRepo.currentUserId == null) return;

    try {
      final worker = await dbRepo.getWorkerProfile(authRepo.currentUserId!);
      setState(() {
        _worker = worker;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load profile: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildProfileTab() {
    final authRepo = Provider.of<AuthRepository>(context);
    final theme = Theme.of(context);

    if (_worker == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: theme.colorScheme.secondary.withValues(
                  alpha: 0.1,
                ),
                child: Icon(
                  Icons.construction_rounded,
                  size: 48,
                  color: theme.colorScheme.secondary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _worker!.fullName,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'National ID: ${_worker!.faydaNumber}',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            _buildProfileDetailRow(
              Icons.phone,
              'Phone Number',
              _worker!.phoneNumber,
            ),
            const Divider(),
            _buildProfileDetailRow(
              Icons.verified_user,
              'Fayda Verification',
              _worker!.faydaVerified ? 'Verified' : 'Pending Verification',
              color: _worker!.faydaVerified
                  ? AppTheme.actionGreen
                  : Colors.orange,
            ),
            const Divider(),
            _buildProfileDetailRow(
              Icons.warning_amber_rounded,
              'Strikes / Reports',
              '${_worker!.flagCount} / 3 Flags Applied',
              color: _worker!.flagCount > 0 ? Colors.red : Colors.black87,
            ),
            const Divider(),
            _buildProfileDetailRow(
              Icons.calendar_month_rounded,
              'Subscription Days Left',
              '${_worker!.daysLeft} Days Remaining',
              color: _worker!.daysLeft <= 0 ? Colors.red : AppTheme.actionGreen,
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () => authRepo.signOut(),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                shadowColor: theme.colorScheme.error.withValues(alpha: 0.3),
              ),
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () async {
                await authRepo.signOut();
              },
              icon: const Icon(Icons.swap_horiz_rounded),
              label: const Text('Switch to Client Account'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDetailRow(
    IconData icon,
    String label,
    String value, {
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryBlue),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color ?? Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentBody() {
    if (_worker == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_worker!.isSuspended) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.gavel_rounded, size: 72, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Account Suspended',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Your worker account has been suspended due to receiving 3 or more strikes. Please contact Seralgn support to resolve this issue.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
      );
    }

    switch (_currentIndex) {
      case 0:
        return WorkerFeed(worker: _worker!);
      case 1:
        return ActiveJobScreen(workerId: _worker!.id);
      case 2:
        return SubscriptionTab(worker: _worker!, onRenewed: _loadProfile);
      case 3:
        return _buildProfileTab();
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: AppTheme.primaryGreen),
          onPressed: () {},
        ),
        title: Text(
          _currentIndex == 0
              ? 'Seralegn'
              : _currentIndex == 1
              ? 'My Active Gigs'
              : _currentIndex == 2
              ? 'Premium Membership'
              : 'Worker Profile',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
            color: _currentIndex == 0
                ? AppTheme.primaryGreen
                : AppTheme.neutralDark,
            fontSize: 22,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.1),
              backgroundImage: const NetworkImage(
                'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
              ),
            ),
          ),
        ],
      ),
      body: _isLoading && _worker == null
          ? const Center(child: CircularProgressIndicator())
          : _buildCurrentBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryGreen,
        unselectedItemColor: AppTheme.textLight,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            activeIcon: Icon(Icons.grid_view_rounded),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline_rounded),
            activeIcon: Icon(Icons.work_rounded),
            label: 'My Jobs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.stars_rounded),
            activeIcon: Icon(Icons.stars_rounded),
            label: 'Premium',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
