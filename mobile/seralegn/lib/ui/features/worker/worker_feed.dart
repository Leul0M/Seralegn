import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../data/models/worker_model.dart';
import '../../../data/models/job_model.dart';
import '../../../data/repositories/database_repository.dart';
import '../../core/theme.dart';
import 'active_job_screen.dart';
import '../payment/chapa_payment_screen.dart';

class WorkerFeed extends StatefulWidget {
  final WorkerModel worker;

  const WorkerFeed({super.key, required this.worker});

  @override
  State<WorkerFeed> createState() => _WorkerFeedState();
}

class _WorkerFeedState extends State<WorkerFeed> {
  List<JobModel> _openJobs = [];
  bool _isLoading = false;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadFeed() async {
    setState(() => _isLoading = true);
    final dbRepo = Provider.of<DatabaseRepository>(context, listen: false);

    try {
      // 1. Get current location for distance calculation
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        _currentPosition = await Geolocator.getCurrentPosition();
      }

      // 2. Fetch jobs
      final jobs = await dbRepo.getOpenJobs();
      setState(() {
        _openJobs = jobs;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load marketplace: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  double _calculateDistance(double? jobLat, double? jobLng) {
    if (jobLat == null || jobLng == null || _currentPosition == null) {
      return 0.0;
    }

    // Returns distance in meters, convert to kilometers
    final meters = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      jobLat,
      jobLng,
    );
    return meters / 1000.0;
  }

  void _claimJob(JobModel job) async {
    setState(() => _isLoading = true);
    final dbRepo = Provider.of<DatabaseRepository>(context, listen: false);

    try {
      final success = await dbRepo.claimJobSecurely(
        jobId: job.id,
        workerId: widget.worker.id,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job claimed successfully! Directed to active job.'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        // Direct worker to active job tab or active job screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text('Active Job Details')),
              body: ActiveJobScreen(workerId: widget.worker.id),
            ),
          ),
        );
        _loadFeed();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job already taken! Try another one.'),
            backgroundColor: Colors.red,
          ),
        );
        _loadFeed();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to claim job: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildExpiredBlocker() {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Card(
          elevation: 4,
          shadowColor: theme.colorScheme.error.withValues(alpha: 0.2),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 32.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.lock_clock_rounded,
                  color: Colors.red,
                  size: 64,
                ),
                const SizedBox(height: 20),
                Text(
                  'Subscription Expired',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your free trial or premium membership has expired. To access open gigs, publish bid offers, and unlock job maps, please activate Seralgn Premium.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ChapaPaymentScreen(
                          workerId: widget.worker.id,
                          amount: 250.0, // Static renewal fee
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.actionGreen,
                  ),
                  icon: const Icon(Icons.payment_rounded),
                  label: const Text('Pay with Chapa (250 ETB)'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJobCard(JobModel job, int index) {
    final distance = _calculateDistance(job.locationLat, job.locationLng);

    // Dynamic category images from Unsplash to match the high-end mockup look
    String imageUrl;
    switch (job.category.toLowerCase()) {
      case 'plumbing':
        imageUrl =
            'https://images.unsplash.com/photo-1504328345606-18bbc8c9d7d1?w=500&auto=format&fit=crop&q=80';
        break;
      case 'cleaning':
        imageUrl =
            'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=500&auto=format&fit=crop&q=80';
        break;
      case 'electrical':
        imageUrl =
            'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=500&auto=format&fit=crop&q=80';
        break;
      default:
        imageUrl =
            'https://images.unsplash.com/photo-1581094794329-c8112a89af12?w=500&auto=format&fit=crop&q=80';
    }

    final showApplyButton = index == 0;

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.cardBorderColor, width: 1.5),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Image representing the task category
          Image.network(
            imageUrl,
            height: 140,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Category Pill & Budget
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2F0EA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        job.category,
                        style: const TextStyle(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Text(
                      'ETB ${job.offeredPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Title
                Text(
                  job.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.neutralDark,
                  ),
                ),
                const SizedBox(height: 6),
                // Description
                if (job.description != null && job.description!.isNotEmpty) ...[
                  Text(
                    job.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.textLight,
                      fontSize: 14,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                // Bottom Row: Location & Age, and Action button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                size: 15,
                                color: AppTheme.textLight,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                distance > 0
                                    ? '${distance.toStringAsFixed(1)} km away'
                                    : 'Location available',
                                style: const TextStyle(
                                  color: AppTheme.textLight,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_rounded,
                                size: 14,
                                color: AppTheme.textLight,
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'Posted 3h ago',
                                style: TextStyle(
                                  color: AppTheme.textLight,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Action button: Apply Now (pill) vs Right Arrow circle
                    if (showApplyButton)
                      ElevatedButton(
                        onPressed: () =>
                            _showJobDetailsBottomSheet(job, distance),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Apply Now',
                          style: TextStyle(fontSize: 13),
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: () => _showJobDetailsBottomSheet(job, distance),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFFE2F0EA),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: AppTheme.primaryGreen,
                            size: 20,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showJobDetailsBottomSheet(JobModel job, double distance) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        job.category,
                        style: const TextStyle(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${job.offeredPrice.toStringAsFixed(0)} ETB',
                        style: const TextStyle(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    job.title,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.neutralDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 18,
                        color: AppTheme.primaryGreen,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        distance > 0
                            ? '${distance.toStringAsFixed(1)} km away'
                            : 'Location coordinates hidden',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.neutralDark,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  const Text(
                    'Job Description',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.neutralDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    job.description ?? 'No description provided.',
                    style: const TextStyle(
                      color: AppTheme.textLight,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (job.locationLat != null && job.locationLng != null) ...[
                    const Text(
                      'Job Area Map',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppTheme.neutralDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        height: 150,
                        child: FlutterMap(
                          options: MapOptions(
                            center: LatLng(
                              job.locationLat!,
                              job.locationLng!,
                            ),
                            zoom: 14.0,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.seralgn.app',
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: LatLng(
                                    job.locationLat!,
                                    job.locationLng!,
                                  ),
                                  builder: (context) => const Icon(
                                    Icons.location_pin,
                                    color: Colors.red,
                                    size: 32,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _claimJob(job);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    child: const Text('ACCEPT & SECURE GIG'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildJobsList() {
    if (_isLoading && _openJobs.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_openJobs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.search_off_rounded,
                size: 72,
                color: Color(0xFFE2F0EA),
              ),
              const SizedBox(height: 16),
              const Text(
                'No jobs available right now',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.neutralDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Check back later! New client jobs appear automatically in the feed.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textLight),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFeed,
      child: ListView.builder(
        itemCount: _openJobs.length,
        itemBuilder: (context, index) {
          return _buildJobCard(_openJobs[index], index);
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search for a task near you',
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppTheme.textLight,
          ),
          suffixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFE2F0EA),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: AppTheme.primaryGreen,
              size: 20,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(
              color: AppTheme.cardBorderColor,
              width: 1.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(
              color: AppTheme.cardBorderColor,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.worker.daysLeft <= 0) {
      return _buildExpiredBlocker();
    }

    return Column(
      children: [
        _buildSearchBar(),
        Expanded(child: _buildJobsList()),
      ],
    );
  }
}
