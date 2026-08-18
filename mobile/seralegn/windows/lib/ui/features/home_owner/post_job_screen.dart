import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../data/models/job_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/database_repository.dart';
import '../../core/theme.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  
  String _selectedCategory = 'Plumbing';
  final List<String> _categories = [
    'Plumbing',
    'Electrical',
    'Cleaning',
    'Gardening',
    'Painting',
    'Carpentry',
    'Appliance Repair',
    'Moving Services',
  ];

  LatLng _currentLocation = const LatLng(9.0300, 38.7400); // Defaults to Addis Ababa center
  late final MapController _mapController;
  bool _isLocating = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _determinePosition();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    setState(() => _isLocating = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied.');
      }

      final position = await Geolocator.getCurrentPosition();
      final newLatLng = LatLng(position.latitude, position.longitude);
      
      setState(() {
        _currentLocation = newLatLng;
      });
      _mapController.move(newLatLng, 15.5);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not fetch GPS location: ${e.toString()}'),
            action: SnackBarAction(label: 'OK', onPressed: () {}),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  void _publishJob() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final authRepo = Provider.of<AuthRepository>(context, listen: false);
    final dbRepo = Provider.of<DatabaseRepository>(context, listen: false);

    final homeownerId = authRepo.currentUserId;
    if (homeownerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Homeowner ID not found.')),
      );
      setState(() => _isLoading = false);
      return;
    }

    final newJob = JobModel(
      id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
      homeOwnerId: homeownerId,
      title: _titleController.text.trim(),
      category: _selectedCategory,
      description: _descController.text.trim(),
      offeredPrice: double.parse(_priceController.text.trim()),
      status: 'open',
      locationLat: _currentLocation.latitude,
      locationLng: _currentLocation.longitude,
    );

    try {
      await dbRepo.createJob(newJob);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job published successfully! Workers can now claim it.'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        Navigator.of(context).pop(true); // Return success to reload feed
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to publish job: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildSectionHeader(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Roboto',
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: AppTheme.neutralDark,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppTheme.primaryGreen),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Post a new task',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
            color: AppTheme.neutralDark,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppTheme.primaryGreen),
                    SizedBox(height: 16),
                    Text('Publishing job to Seralegn...'),
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSectionHeader('Category'),
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          hint: const Text('Select a category...'),
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          ),
                          items: _categories.map((cat) {
                            return DropdownMenuItem(
                              value: cat,
                              child: Text(cat),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedCategory = val);
                            }
                          },
                        ),
                        
                        _buildSectionHeader('Task Title'),
                        TextFormField(
                          controller: _titleController,
                          maxLength: 50,
                          decoration: const InputDecoration(
                            hintText: 'e.g. Fix leaking kitchen sink',
                            counterText: '',
                            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter a brief title';
                            }
                            return null;
                          },
                        ),
                        
                        _buildSectionHeader('Task Description'),
                        TextFormField(
                          controller: _descController,
                          maxLines: 4,
                          maxLength: 300,
                          decoration: const InputDecoration(
                            hintText: 'Describe what needs to be done in detail...',
                            counterText: '',
                            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter a description';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Be as specific as possible to get the best workers.',
                          style: TextStyle(
                            color: AppTheme.textLight,
                            fontSize: 12,
                          ),
                        ),
                        
                        _buildSectionHeader('Service Location'),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            height: 200,
                            decoration: BoxDecoration(
                              border: Border.all(color: AppTheme.cardBorderColor, width: 1.5),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Stack(
                              children: [
                                FlutterMap(
                                  mapController: _mapController,
                                  options: MapOptions(
                                    initialCenter: _currentLocation,
                                    initialZoom: 14.0,
                                    onPositionChanged: (position, hasGesture) {
                                      if (position.center != null) {
                                        _currentLocation = position.center!;
                                      }
                                    },
                                  ),
                                  children: [
                                    TileLayer(
                                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                      userAgentPackageName: 'com.seralgn.app',
                                    ),
                                  ],
                                ),
                                const IgnorePointer(
                                  child: Center(
                                    child: Padding(
                                      padding: EdgeInsets.only(bottom: 30),
                                      child: Icon(
                                        Icons.location_pin,
                                        size: 40,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 12,
                                  left: 12,
                                  right: 12,
                                  child: Card(
                                    margin: EdgeInsets.zero,
                                    elevation: 2,
                                    shadowColor: Colors.black.withOpacity(0.1),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    color: Colors.white,
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                                      child: Row(
                                        children: [
                                          Icon(Icons.location_on_rounded, color: AppTheme.primaryGreen, size: 18),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Bole, Addis Ababa',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.neutralDark,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: Column(
                                    children: [
                                      FloatingActionButton.small(
                                        heroTag: 'map_locate',
                                        onPressed: _isLocating ? null : _determinePosition,
                                        backgroundColor: Colors.white,
                                        child: _isLocating
                                            ? const SizedBox(
                                                width: 16,
                                                height: 16,
                                                child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryGreen),
                                              )
                                            : const Icon(Icons.my_location_rounded, color: AppTheme.primaryGreen, size: 18),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        _buildSectionHeader('Estimated Budget (ETB)'),
                        TextFormField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: 'e.g. 500',
                            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter your budget';
                            }
                            final numVal = double.tryParse(val);
                            if (numVal == null || numVal <= 0) {
                              return 'Please enter a valid price greater than 0';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 36),
                        ElevatedButton(
                          onPressed: _publishJob,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('PUBLISH JOB'),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, size: 18),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
