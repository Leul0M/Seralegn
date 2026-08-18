import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/models/job_model.dart';
import '../../../data/models/worker_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/database_repository.dart';
import '../../core/theme.dart';
import 'post_job_screen.dart';

class HomeOwnerDashboard extends StatefulWidget {
  const HomeOwnerDashboard({super.key});

  @override
  State<HomeOwnerDashboard> createState() => _HomeOwnerDashboardState();
}

class _HomeOwnerDashboardState extends State<HomeOwnerDashboard> {
  int _currentIndex = 0;
  List<JobModel> _jobs = [];
  bool _isLoading = false;
  
  // Cache of workers to avoid refetching continuously
  final Map<String, WorkerModel> _workerCache = {};

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    if (mounted) setState(() => _isLoading = true);
    final authRepo = Provider.of<AuthRepository>(context, listen: false);
    final dbRepo = Provider.of<DatabaseRepository>(context, listen: false);

    if (authRepo.currentUserId == null) return;

    try {
      final jobs = await dbRepo.getHomeOwnerJobs(authRepo.currentUserId!);
      setState(() {
        _jobs = jobs;
      });

      // Load worker details for claimed/in-progress jobs
      for (var job in jobs) {
        if (job.workerId != null && !_workerCache.containsKey(job.workerId)) {
          final worker = await dbRepo.getWorkerProfile(job.workerId!);
          if (worker != null) {
            setState(() {
              _workerCache[job.workerId!] = worker;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load jobs: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _callWorker(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open phone dialer')),
        );
      }
    }
  }

  void _confirmJobCompleted(JobModel job) async {
    final dbRepo = Provider.of<DatabaseRepository>(context, listen: false);
    try {
      await dbRepo.updateJobStatus(jobId: job.id, status: 'completed');
      _loadJobs();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job confirmed as completed! Thank you.'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to confirm job: $e')),
        );
      }
    }
  }

  void _reportIssueDialog(JobModel job) {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Report an Issue'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: reasonController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Describe the issue or reason for dispute...',
                labelText: 'Details',
                alignLabelWithHint: true,
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please provide a reason';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                
                final dbRepo = Provider.of<DatabaseRepository>(context, listen: false);
                try {
                  await dbRepo.reportIssue(
                    homeownerId: job.homeOwnerId,
                    workerId: job.workerId!,
                    jobId: job.id,
                    reason: reasonController.text.trim(),
                  );
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Issue reported. Support will review this case shortly.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                  _loadJobs();
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to report issue: $e')),
                    );
                  }
                }
              },
              child: const Text('Submit Report'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    String label = status.toUpperCase();

    switch (status) {
      case 'open':
        bg = Colors.blue.shade50;
        fg = Colors.blue.shade700;
        label = 'Open';
        break;
      case 'claimed':
        bg = Colors.orange.shade50;
        fg = Colors.orange.shade700;
        label = 'Claimed';
        break;
      case 'in_progress':
        bg = Colors.purple.shade50;
        fg = Colors.purple.shade700;
        label = 'In Progress';
        break;
      case 'pending_confirmation':
        bg = Colors.yellow.shade100;
        fg = Colors.yellow.shade900;
        label = 'Pending Confirm';
        break;
      case 'completed':
        bg = AppTheme.actionGreen.withOpacity(0.1);
        fg = AppTheme.actionGreen;
        label = 'Completed';
        break;
      case 'cancelled':
        bg = Colors.red.shade50;
        fg = Colors.red.shade700;
        label = 'Cancelled';
        break;
      default:
        bg = Colors.grey.shade100;
        fg = Colors.grey.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildJobCard(JobModel job, WorkerModel? worker) {
    Color badgeBg;
    Color badgeFg;
    String badgeLabel;

    switch (job.status) {
      case 'open':
        badgeBg = const Color(0xFFE2F0EA);
        badgeFg = AppTheme.primaryGreen;
        badgeLabel = '• Open';
        break;
      case 'claimed':
        badgeBg = const Color(0xFFFEF3C7);
        badgeFg = const Color(0xFFD97706);
        badgeLabel = '• Claimed';
        break;
      case 'in_progress':
        badgeBg = const Color(0xFFE2F0EA);
        badgeFg = AppTheme.primaryGreen;
        badgeLabel = '• In Progress';
        break;
      case 'pending_confirmation':
        badgeBg = const Color(0xFFFFEDD5);
        badgeFg = const Color(0xFFEA580C);
        badgeLabel = '• Confirm';
        break;
      case 'completed':
        badgeBg = const Color(0xFFE2F0EA);
        badgeFg = AppTheme.primaryGreen;
        badgeLabel = '• Completed';
        break;
      case 'cancelled':
      default:
        badgeBg = const Color(0xFFF1F5F9);
        badgeFg = const Color(0xFF64748B);
        badgeLabel = '• Closed';
        break;
    }

    // Determine mockup images and titles for seeded profiles
    String? workerImage;
    String workerTitle = 'Verified Provider';
    if (worker != null) {
      if (worker.fullName == 'Abebe D.') {
        workerImage = 'https://images.unsplash.com/photo-1540569014015-19a7be504e3a?w=150';
        workerTitle = 'Verified Pro Plumber';
      } else if (worker.fullName == 'Samuel T.') {
        workerImage = 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150';
        workerTitle = 'Verified Pro Handyman';
      } else {
        workerImage = 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150';
      }
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.cardBorderColor, width: 1.5),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Title & Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    job.title,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.neutralDark,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badgeLabel,
                    style: TextStyle(
                      color: badgeFg,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Middle: Worker profile if claimed/in_progress/etc.
            if (worker != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                      backgroundImage: workerImage != null ? NetworkImage(workerImage) : null,
                      child: workerImage == null ? const Icon(Icons.person, color: AppTheme.primaryGreen) : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            worker.fullName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.neutralDark,
                            ),
                          ),
                          Text(
                            workerTitle,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Call Button (circular green button)
                    GestureDetector(
                      onTap: () => _callWorker(worker.phoneNumber),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE2F0EA),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.phone_rounded,
                          color: AppTheme.primaryGreen,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
            // Action Buttons for confirmation
            if (job.status == 'pending_confirmation') ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _reportIssueDialog(job),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Text('Report Issue', style: TextStyle(fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _confirmJobCompleted(job),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Text('Confirm Done', style: TextStyle(fontSize: 13)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            // Bottom Row: Price Label & Value
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  worker != null ? 'Agreed Price' : 'Estimated Price',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textLight,
                  ),
                ),
                Text(
                  'ETB ${job.offeredPrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobsList(List<JobModel> list) {
    if (_isLoading && list.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.assignment_rounded, size: 72, color: Color(0xFFE2F0EA)),
              const SizedBox(height: 16),
              const Text(
                'No jobs posted yet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.neutralDark),
              ),
              const SizedBox(height: 8),
              const Text(
                'Publish a job to find local service workers in your area.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textLight),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadJobs,
      child: ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) {
          final job = list[index];
          final worker = job.workerId != null ? _workerCache[job.workerId] : null;
          return _buildJobCard(job, worker);
        },
      ),
    );
  }

  Widget _buildJobsTab() {
    // Filter active and history jobs to align with tabs in mockup
    final activeJobs = _jobs.where((j) => ['open', 'claimed', 'in_progress', 'pending_confirmation'].contains(j.status)).toList();
    final historyJobs = _jobs.where((j) => ['completed', 'cancelled'].contains(j.status)).toList();

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: const TabBar(
              indicatorColor: AppTheme.primaryGreen,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: AppTheme.primaryGreen,
              unselectedLabelColor: AppTheme.textLight,
              labelStyle: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold, fontSize: 14),
              unselectedLabelStyle: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold, fontSize: 14),
              tabs: [
                Tab(text: 'Active Tasks'),
                Tab(text: 'History'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildJobsList(activeJobs),
                _buildJobsList(historyJobs),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumTab() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Card(
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: AppTheme.cardBorderColor, width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.stars_rounded,
                  color: AppTheme.primaryGreen,
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Seralegn Premium',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.neutralDark,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Get matched with top-rated, background-checked professionals up to 3x faster. Plus, enjoy 24/7 priority support.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textLight, height: 1.4),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Upgrade to Premium'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    final authRepo = Provider.of<AuthRepository>(context);
    final theme = Theme.of(context);

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
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                child: Icon(Icons.house_rounded, size: 48, color: theme.colorScheme.primary),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Homeowner Profile',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            _buildProfileDetailRow(Icons.person, 'Full Name', authRepo.hasProfile ? 'Registered User' : 'Loading...'),
            const Divider(),
            _buildProfileDetailRow(Icons.phone, 'Phone Number', authRepo.currentPhoneNumber ?? 'Unknown'),
            const Divider(),
            _buildProfileDetailRow(Icons.verified_user, 'Account Type', 'Homeowner'),
            const SizedBox(height: 60),
            ElevatedButton.icon(
              onPressed: () => authRepo.signOut(),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
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
              label: const Text('Switch to Worker Account'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryGreen),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppTheme.textLight, fontSize: 13)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.neutralDark)),
            ],
          ),
        ],
      ),
    );
  }

  Widget? _buildPendingConfirmationOverlay() {
    final pendingJob = _jobs.firstWhere(
      (job) => job.status == 'pending_confirmation',
      orElse: () => JobModel(id: '', homeOwnerId: '', title: '', category: '', offeredPrice: 0),
    );

    if (pendingJob.id.isEmpty) return null;

    final worker = pendingJob.workerId != null ? _workerCache[pendingJob.workerId] : null;

    return Container(
      color: Colors.black.withOpacity(0.85),
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(24.0),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
              size: 80,
            ),
            const SizedBox(height: 24),
            const Text(
              'Job Completion Request!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'The worker claims they have finished working on: "${pendingJob.title}". Please confirm or report any issues.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            if (worker != null) ...[
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            worker.fullName,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            worker.phoneNumber,
                            style: const TextStyle(color: Colors.white60, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _callWorker(worker.phoneNumber),
                      icon: const Icon(Icons.phone, color: AppTheme.secondaryGreen),
                      tooltip: 'Call Worker',
                    )
                  ],
                ),
              ),
            ],
            const SizedBox(height: 60),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              onPressed: () => _confirmJobCompleted(pendingJob),
              child: const Text('Confirm Job Done & Pay'),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              onPressed: () => _reportIssueDialog(pendingJob),
              child: const Text('Report Issue / Raise Dispute'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentBody() {
    switch (_currentIndex) {
      case 0:
        return _buildJobsTab();
      case 1:
        return _buildJobsTab();
      case 2:
        return _buildPremiumTab();
      case 3:
        return _buildProfileTab();
      default:
        return _buildJobsTab();
    }
  }

  @override
  Widget build(BuildContext context) {
    final overlay = _buildPendingConfirmationOverlay();
    final theme = Theme.of(context);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.menu_rounded, color: AppTheme.primaryGreen),
              onPressed: () {},
            ),
            title: const Text(
              'Seralegn',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryGreen,
                fontSize: 22,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                  backgroundImage: const NetworkImage(
                    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
                  ),
                ),
              ),
            ],
          ),
          body: _buildCurrentBody(),
          floatingActionButton: _currentIndex == 0 || _currentIndex == 1
              ? FloatingActionButton(
                  onPressed: () async {
                    final success = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(builder: (context) => const PostJobScreen()),
                    );
                    if (success == true) {
                      _loadJobs();
                    }
                  },
                  backgroundColor: AppTheme.primaryGreen,
                  shape: const CircleBorder(),
                  child: const Icon(Icons.add, color: Colors.white),
                )
              : null,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() => _currentIndex = index);
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppTheme.primaryGreen,
            unselectedItemColor: AppTheme.textLight,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
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
        ),
        if (overlay != null) overlay,
      ],
    );
  }
}
