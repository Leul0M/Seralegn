import 'package:flutter/material.dart';
import '../../models/booking.dart';
import '../../models/job.dart';
import '../../services/booking_service.dart';
import '../../services/hive_service.dart';
import '../../services/location_service.dart';
import '../../theme/app_theme.dart';

class CreateBookingSheet extends StatefulWidget {
  final Function(Booking) onBookingCreated;
  final String currentUserId;

  const CreateBookingSheet({
    super.key,
    required this.onBookingCreated,
    required this.currentUserId,
  });

  @override
  State<CreateBookingSheet> createState() => _CreateBookingSheetState();
}

class _CreateBookingSheetState extends State<CreateBookingSheet> {
  final _formKey = GlobalKey<FormState>();
  
  JobCategory _selectedCategory = JobCategory.electrical;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  bool _fetchingLocation = false;

  // Worker lookup
  final _workerPhoneController = TextEditingController();
  String? _foundWorkerName;
  String? _foundWorkerId;
  bool _lookingUpWorker = false;
  String? _workerLookupError;
  
  final _addressController = TextEditingController(text: 'Bole Atlas, Apt 4B, Addis Ababa');
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _workerPhoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _lookupWorker() async {
    final phone = _workerPhoneController.text.trim();
    if (phone.isEmpty) return;
    setState(() {
      _lookingUpWorker = true;
      _foundWorkerName = null;
      _foundWorkerId = null;
      _workerLookupError = null;
    });
    try {
      final result = await BookingService.instance.findWorkerByPhone(phone);
      if (result != null) {
        setState(() {
          _foundWorkerName = result['full_name'] as String?;
          _foundWorkerId = result['id'] as String?;
          _workerLookupError = null;
        });
      } else {
        setState(() {
          _workerLookupError = 'No registered worker found with this phone number.';
        });
      }
    } catch (_) {
      setState(() {
        _workerLookupError = 'Could not look up worker. Check your connection.';
      });
    } finally {
      setState(() => _lookingUpWorker = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryTeal,
              onPrimary: Colors.white,
              onSurface: AppTheme.darkText,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryTeal,
              onPrimary: Colors.white,
              onSurface: AppTheme.darkText,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _useNativeLocation() async {
    setState(() => _fetchingLocation = true);
    final pos = await LocationService.getCurrentLocation(context);
    setState(() => _fetchingLocation = false);

    if (pos != null) {
      setState(() {
        _addressController.text =
            'GPS: ${pos.latitude.toStringAsFixed(4)}° N, ${pos.longitude.toStringAsFixed(4)}° E (Addis Ababa)';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Native Android GPS position fetched!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    }
  }

  Future<void> _submitBooking() async {
    if (_formKey.currentState!.validate()) {
      if (_foundWorkerId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please look up a valid worker phone number first.'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
        return;
      }

      try {
        final userData = HiveService.instance.getUserData();
        final clientName = (userData['fullName'] as String?)?.trim() ?? 'Client';
        final clientPhone = (userData['phoneNumber'] as String?)?.trim() ?? '';
        final timeFormatted = _selectedTime.format(context);

        final newBooking = Booking(
          id: '',
          clientName: clientName,
          clientPhone: clientPhone,
          workerName: _foundWorkerName ?? '',
          workerPhone: _workerPhoneController.text.trim(),
          category: _selectedCategory,
          bookingDate: _selectedDate,
          timeSlot: timeFormatted,
          address: _addressController.text,
          notes: _notesController.text,
          status: BookingStatus.pending,
          createdAt: DateTime.now(),
          clientId: widget.currentUserId.isNotEmpty ? widget.currentUserId : null,
          workerId: _foundWorkerId,
        );

        widget.onBookingCreated(newBooking);

        final formattedDate = _formatDate(_selectedDate);
        final workerDisplayName = _foundWorkerName ?? 'the worker';
        final timeSlotLabel = timeFormatted;

        Navigator.pop(context);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          showDialog(
            context: context,
            builder: (dialogContext) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.notifications_active_rounded, color: AppTheme.primaryTeal, size: 28),
                  SizedBox(width: 10),
                  Text(
                    'Notification Sent!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your scheduled booking for $formattedDate has been submitted.',
                    style: const TextStyle(fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFC7D2FE)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '\u{1F4F2} Worker Notified ($workerDisplayName):',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryTeal,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'SMS & App Alert sent to worker for scheduled job on $formattedDate ($timeSlotLabel).',
                          style: const TextStyle(fontSize: 11, color: AppTheme.secondaryText),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryTeal,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(100, 44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Awesome'),
                ),
              ],
            ),
          );
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
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Book a Worker',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkText,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Schedule a direct appointment for a specific date',
                        style: TextStyle(fontSize: 12, color: AppTheme.secondaryText),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: AppTheme.lightText),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Category Selector
              const Text(
                'SERVICE CATEGORY',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: AppTheme.secondaryText,
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<JobCategory>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: JobCategory.values.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat.shortTitle, style: const TextStyle(fontSize: 13)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
              const SizedBox(height: 14),

              // Worker Lookup by Phone
              const Text(
                'WORKER PHONE NUMBER',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: AppTheme.secondaryText,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _workerPhoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: 'e.g. +251912345678',
                        prefixIcon: const Icon(Icons.phone_rounded, size: 20, color: AppTheme.lightText),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _lookingUpWorker ? null : _lookupWorker,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryTeal,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(80, 52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _lookingUpWorker
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Find', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              if (_foundWorkerName != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF6EE7B7)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Worker found: $_foundWorkerName',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF065F46),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (_workerLookupError != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _workerLookupError!,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF991B1B)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 14),

              // Specific Date Picker
              const Text(
                'BOOKING DATE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: AppTheme.secondaryText,
                ),
              ),
              const SizedBox(height: 6),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 18, color: AppTheme.primaryTeal),
                          const SizedBox(width: 10),
                          Text(
                            _formatDate(_selectedDate),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.darkText,
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'Change Date',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryTeal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Time Picker Selection
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'CHOOSE SPECIFIC TIME',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: AppTheme.secondaryText,
                    ),
                  ),
                  Text(
                    'Native Time Picker',
                    style: TextStyle(fontSize: 10, color: AppTheme.primaryTeal, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              InkWell(
                onTap: _pickTime,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.access_time_filled_rounded, size: 18, color: AppTheme.primaryTeal),
                          const SizedBox(width: 10),
                          Text(
                            _selectedTime.format(context),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.darkText,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Pick Custom Time',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryTeal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Address Field with Native GPS Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'LOCATION & ADDRESS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: AppTheme.secondaryText,
                    ),
                  ),
                  GestureDetector(
                    onTap: _fetchingLocation ? null : _useNativeLocation,
                    child: Row(
                      children: [
                        _fetchingLocation
                            ? const SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryTeal),
                              )
                            : const Icon(Icons.my_location_rounded, size: 12, color: AppTheme.primaryTeal),
                        const SizedBox(width: 4),
                        const Text(
                          'Use Android GPS',
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
                controller: _addressController,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.location_on_outlined, size: 18),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Address is required' : null,
              ),
              const SizedBox(height: 14),

              // Notes Field
              const Text(
                'JOB NOTES (OPTIONAL)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: AppTheme.secondaryText,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Describe specific instructions or issues...',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),

              // Submit Button
              ElevatedButton(
                onPressed: _submitBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryTeal,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.send_rounded, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Confirm & Notify Worker',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
