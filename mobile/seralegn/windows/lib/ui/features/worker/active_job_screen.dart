import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../data/models/job_model.dart';
import '../../../data/models/home_owner_model.dart';
import '../../../data/repositories/database_repository.dart';
import '../../core/theme.dart';

class ActiveJobScreen extends StatefulWidget {
  final String workerId;

  const ActiveJobScreen({super.key, required this.workerId});

  @override
  State<ActiveJobScreen> createState() => _ActiveJobScreenState();
}

class _ActiveJobScreenState extends State<ActiveJobScreen> {
  JobModel? _activeJob;
  HomeOwnerModel? _homeOwner;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadActiveJob();
  }

  Future<void> _loadActiveJob() async {
    if (mounted) setState(() => _isLoading = true);
    final dbRepo = Provider.of<DatabaseRepository>(context, listen: false);

    try {
      final activeJobs = await dbRepo.getWorkerActiveJobs(widget.workerId);
      if (activeJobs.isNotEmpty) {
        final job = activeJobs.first;
        setState(() {
          _activeJob = job;
        });

        // Load homeowner profile details
        final ho = await dbRepo.getHomeOwnerProfile(job.homeOwnerId);
        setState(() {
          _homeOwner = ho;
        });
      } else {
        setState(() {
          _activeJob = null;
          _homeOwner = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load active job: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _callHomeOwner(String phoneNumber) async {
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

  void _updateStatus(String newStatus) async {
    if (_activeJob == null) return;
    setState(() => _isLoading = true);
    final dbRepo = Provider.of<DatabaseRepository>(context, listen: false);

    try {
      await dbRepo.updateJobStatus(jobId: _activeJob!.id, status: newStatus);
      await _loadActiveJob();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newStatus == 'in_progress' ? 'Job started!' : 'Job marked as finished!'),
            backgroundColor: AppTheme.actionGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update job: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading && _activeJob == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_activeJob == null) {
      return RefreshIndicator(
        onRefresh: _loadActiveJob,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.work_history_rounded, size: 72, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    const Text(
                      'No Active Gigs',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Go to the Feed tab to accept available work, or drag down to refresh.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadActiveJob,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card Header
            Card(
              color: _activeJob!.status == 'claimed'
                  ? AppTheme.primaryBlue.withOpacity(0.05)
                  : _activeJob!.status == 'in_progress'
                      ? AppTheme.actionGreen.withOpacity(0.05)
                      : Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      _activeJob!.status == 'claimed'
                          ? Icons.assignment_turned_in_rounded
                          : _activeJob!.status == 'in_progress'
                              ? Icons.play_circle_fill_rounded
                              : Icons.hourglass_empty_rounded,
                      color: _activeJob!.status == 'claimed'
                          ? AppTheme.primaryBlue
                          : _activeJob!.status == 'in_progress'
                              ? AppTheme.actionGreen
                              : Colors.orange.shade700,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Current Status', style: TextStyle(color: Colors.black54, fontSize: 12)),
                          Text(
                            _activeJob!.status == 'claimed'
                                ? 'Claimed - Ready to Start'
                                : _activeJob!.status == 'in_progress'
                                    ? 'In Progress - Working...'
                                    : 'Pending Confirmation',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _activeJob!.status == 'claimed'
                                  ? AppTheme.primaryBlue
                                  : _activeJob!.status == 'in_progress'
                                      ? AppTheme.actionGreen
                                      : Colors.orange.shade800,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Job Details
            Text(
              _activeJob!.title,
              style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              _activeJob!.category,
              style: const TextStyle(color: AppTheme.actionGreen, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Text(
              _activeJob!.description ?? 'No description provided.',
              style: const TextStyle(color: Colors.black87, fontSize: 15, height: 1.4),
            ),
            const SizedBox(height: 8),
            Text(
              'Offered Budget: ${_activeJob!.offeredPrice.toStringAsFixed(0)} ETB',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryBlue),
            ),
            const Divider(height: 40),
            // Client details section
            if (_homeOwner != null) ...[
              const Text('Homeowner Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                        child: const Icon(Icons.person, color: AppTheme.primaryBlue),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _homeOwner!.fullName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              _homeOwner!.phoneNumber,
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _callHomeOwner(_homeOwner!.phoneNumber),
                        icon: const Icon(Icons.phone, color: AppTheme.actionGreen),
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.actionGreen.withOpacity(0.1),
                        ),
                        tooltip: 'Call Client',
                      )
                    ],
                  ),
                ),
              ),
              const Divider(height: 40),
            ],
            // Map location section
            if (_activeJob!.locationLat != null && _activeJob!.locationLng != null) ...[
              const Text('Worksite Location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 200,
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(_activeJob!.locationLat!, _activeJob!.locationLng!),
                      initialZoom: 15.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.seralgn.app',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(_activeJob!.locationLat!, _activeJob!.locationLng!),
                            child: const Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 38,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
            // State Machine Slide Buttons
            if (_activeJob!.status == 'claimed')
              _buildSlider(
                label: 'Slide to Start Work',
                color: AppTheme.primaryBlue,
                icon: Icons.play_arrow_rounded,
                onTriggered: () => _updateStatus('in_progress'),
              )
            else if (_activeJob!.status == 'in_progress')
              _buildSlider(
                label: 'Slide to Finish Work',
                color: AppTheme.actionGreen,
                icon: Icons.done_all_rounded,
                onTriggered: () => _updateStatus('pending_confirmation'),
              )
            else if (_activeJob!.status == 'pending_confirmation')
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange.shade300),
                ),
                child: const Column(
                  children: [
                    CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.orange)),
                    SizedBox(height: 16),
                    Text(
                      'Waiting for Homeowner Confirmation',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'The homeowner has been notified to verify and release payment. You can call them to speed up the process.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black87, fontSize: 13),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // A custom, dependency-free interactive slide-to-confirm widget
  Widget _buildSlider({
    required String label,
    required Color color,
    required IconData icon,
    required VoidCallback onTriggered,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double buttonSize = 56.0;

        return Container(
          height: buttonSize,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(buttonSize / 2),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Stack(
            children: [
              // Slide Label text
              Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              // Draggable button
              Dismissible(
                key: UniqueKey(),
                direction: DismissDirection.startToEnd,
                confirmDismiss: (direction) async {
                  onTriggered();
                  return true;
                },
                child: Row(
                  children: [
                    Container(
                      width: buttonSize,
                      height: buttonSize,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Icon(icon, color: Colors.white, size: 28),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
