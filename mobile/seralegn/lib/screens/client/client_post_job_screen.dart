import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/job.dart';
import '../../services/hive_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/simulated_map_widget.dart';

class ClientPostJobScreen extends StatefulWidget {
  /// Called with the Job object AND the list of selected image XFiles.
  final Function(Job, List<XFile>) onJobCreated;
  final VoidCallback? onCancel;

  const ClientPostJobScreen({
    super.key,
    required this.onJobCreated,
    this.onCancel,
  });

  @override
  State<ClientPostJobScreen> createState() => _ClientPostJobScreenState();
}

class _ClientPostJobScreenState extends State<ClientPostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isPosting = false;

  JobCategory _selectedCategory = JobCategory.plumbing;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController(text: '650');

  String _selectedNeighborhood = 'Bole Atlas';
  double _lat = 9.0083;
  double _lng = 38.7831;

  static const int _maxImages = 5;
  final List<XFile> _selectedImages = [];
  final ImagePicker _imagePicker = ImagePicker();

  final List<String> _neighborhoods = [
    'Bole Atlas',
    'Bole Medhanialem',
    'Kazanchis',
    'Megenagna',
    'CMC',
    'Sarbet',
    'Piassa',
    'Gotera',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_selectedImages.length >= _maxImages) return;

    // Let user choose source
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Add Photo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFEEF2FF),
                  child: Icon(Icons.photo_library_rounded, color: AppTheme.primaryTeal),
                ),
                title: const Text('Choose from Gallery'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFEEF2FF),
                  child: Icon(Icons.camera_alt_rounded, color: AppTheme.primaryTeal),
                ),
                title: const Text('Take a Photo'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    final XFile? picked = await _imagePicker.pickImage(
      source: source,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );

    if (picked != null && mounted) {
      setState(() {
        if (_selectedImages.length < _maxImages) {
          _selectedImages.add(picked);
        }
      });
    }
  }

  void _removeImage(int index) {
    setState(() => _selectedImages.removeAt(index));
  }

  void _autofillTemplate() {
    switch (_selectedCategory) {
      case JobCategory.plumbing:
        _titleController.text = 'Emergency Kitchen Sink Leak Repair';
        _descriptionController.text =
            'Kitchen sink drainage pipe is leaking under the cabinet. Need experienced plumber to replace trap seals and test water flow.';
        _budgetController.text = '650';
        break;
      case JobCategory.electrical:
        _titleController.text = 'Circuit Breaker & Switch Box Replacement';
        _descriptionController.text =
            'Main circuit breaker trips whenever heavy appliances are turned on. Need certified electrician to inspect fuse panel.';
        _budgetController.text = '1200';
        break;
      case JobCategory.cleaning:
        _titleController.text = 'Deep House Cleaning for 3-Bedroom Villa';
        _descriptionController.text =
            'Full deep cleaning including tile scrubbing, window wiping, grease removal, and floor sanitization.';
        _budgetController.text = '1500';
        break;
      default:
        _titleController.text = '${_selectedCategory.shortTitle} Service Task';
        _descriptionController.text =
            'Need a verified craftsman for urgent home repair and installation in $_selectedNeighborhood.';
        _budgetController.text = '800';
    }
    setState(() {});
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isPosting = true);
      try {
        final userData = HiveService.instance.getUserData();
        final clientName = (userData['fullName'] as String?)?.trim();
        final clientPhone = (userData['phoneNumber'] as String?)?.trim();

        final double budget = double.tryParse(_budgetController.text.trim()) ?? 650.0;
        final newJob = Job(
          id: '',
          title: _titleController.text.trim().isEmpty
              ? 'Emergency Service Task'
              : _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? 'Describe the issue clearly for local service providers.'
              : _descriptionController.text.trim(),
          category: _selectedCategory,
          budgetEtb: budget,
          neighborhood: _selectedNeighborhood,
          addressDetail: '$_selectedNeighborhood, House #204',
          latitude: _lat,
          longitude: _lng,
          status: JobStatus.open,
          clientName: (clientName != null && clientName.isNotEmpty) ? clientName : 'Client',
          clientPhone: (clientPhone != null && clientPhone.isNotEmpty) ? clientPhone : '',
          isClientVerified: true,
          distanceKm: 0,
          postedAt: DateTime.now(),
          imagePaths: [],
        );

        await widget.onJobCreated(newJob, _selectedImages);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Job "${newJob.title}" posted successfully!'),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
          // Clear the form
          _titleController.clear();
          _descriptionController.clear();
          _budgetController.text = '650';
          setState(() => _selectedImages.clear());
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to post job. Please try again.'),
              backgroundColor: const Color(0xFFEF4444),
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isPosting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Post a Job'),
        leading: widget.onCancel != null
            ? IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: widget.onCancel,
              )
            : null,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row with STEP 1/2
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Post a Job',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkText,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'STEP 1/2',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryTeal,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Connect with verified Addis Ababa pros in minutes',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.secondaryText,
                  ),
                ),
                const SizedBox(height: 20),

                // Category Field
                _buildFieldLabel('CATEGORY'),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.inputBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.inputBorder),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<JobCategory>(
                      value: _selectedCategory,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down, color: AppTheme.secondaryText),
                      onChanged: (newCat) {
                        if (newCat != null) {
                          setState(() => _selectedCategory = newCat);
                        }
                      },
                      items: JobCategory.values.map((cat) {
                        return DropdownMenuItem<JobCategory>(
                          value: cat,
                          child: Text(
                            '${cat.nameAmharic} — ${cat.priceRange}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.darkText,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Task Title Field
                _buildFieldLabel('TASK TITLE'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Emergency Sink Leak Repair',
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter a task title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // Job Description Field with Auto-fill Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildFieldLabel('JOB DESCRIPTION'),
                    GestureDetector(
                      onTap: _autofillTemplate,
                      child: Row(
                        children: const [
                          Icon(Icons.verified_rounded, size: 12, color: AppTheme.primaryTeal),
                          SizedBox(width: 4),
                          Text(
                            'Auto-fill template',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryTeal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText:
                        'Describe the issue (e.g. kitchen sink pipe burst, leaking water under cabinet)...',
                  ),
                ),
                const SizedBox(height: 18),

                 // Job Photos Section
                 Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildFieldLabel('JOB PHOTOS (OPTIONAL)'),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _selectedImages.length >= _maxImages
                            ? const Color(0xFFFEE2E2)
                            : const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${_selectedImages.length}/$_maxImages',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _selectedImages.length >= _maxImages
                              ? const Color(0xFFEF4444)
                              : AppTheme.primaryTeal,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 96,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      // Existing image thumbnails
                      ..._selectedImages.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final img = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  File(img.path),
                                  width: 86,
                                  height: 96,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              // Remove button
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => _removeImage(idx),
                                  child: Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.65),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close_rounded,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      // Add Photo tile
                      if (_selectedImages.length < _maxImages)
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 86,
                            height: 96,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.primaryTeal,
                                width: 1.5,
                                strokeAlign: BorderSide.strokeAlignOutside,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.add_photo_alternate_rounded,
                                  color: AppTheme.primaryTeal,
                                  size: 28,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Add Photo',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryTeal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                 // Estimated Budget Input
                _buildFieldLabel('ESTIMATED BUDGET (ETB)'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _budgetController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(14.0),
                      child: Text(
                        '\$',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondaryText,
                        ),
                      ),
                    ),
                    suffixIcon: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
                      child: Text(
                        'ETB',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryTeal,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Service Location Section
                _buildFieldLabel('SERVICE LOCATION'),
                const SizedBox(height: 8),

                SimulatedMapWidget(
                  locationName: _selectedNeighborhood,
                  subAddress: '$_selectedNeighborhood, House #204',
                  latitude: _lat,
                  longitude: _lng,
                  isInteractive: true,
                  onGpsPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('GPS updated to your exact device location.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                // Quick Select Neighborhood Chips
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Row(
                      children: [
                        Icon(Icons.verified_rounded, size: 12, color: AppTheme.primaryTealHover),
                        SizedBox(width: 4),
                        Text(
                          'Quick Select Neighborhood',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.secondaryText,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Tap to reposition pin',
                      style: TextStyle(fontSize: 10, color: AppTheme.lightText),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _neighborhoods.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final nh = _neighborhoods[index];
                      final isSelected = _selectedNeighborhood == nh;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedNeighborhood = nh;
                            _lat = 9.0000 + (index * 0.0035);
                            _lng = 38.7500 + (index * 0.0050);
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.primaryTeal : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected ? AppTheme.primaryTeal : AppTheme.inputBorder,
                            ),
                          ),
                          child: Text(
                            nh,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : AppTheme.darkText,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 28),

                // Publish Button
                ElevatedButton(
                  onPressed: _isPosting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isPosting
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Publish Job',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Inserts into database with status: open',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.primaryTealHover,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.8,
        color: AppTheme.secondaryText,
      ),
    );
  }
}
