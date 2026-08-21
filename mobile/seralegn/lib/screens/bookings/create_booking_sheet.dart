import 'package:flutter/material.dart';
import '../../models/booking.dart';
import '../../models/job.dart';
import '../../services/location_service.dart';
import '../../theme/app_theme.dart';

class CreateBookingSheet extends StatefulWidget {
  final Function(Booking) onBookingCreated;

  const CreateBookingSheet({
    super.key,
    required this.onBookingCreated,
  });

  @override
  State<CreateBookingSheet> createState() => _CreateBookingSheetState();
}

class _CreateBookingSheetState extends State<CreateBookingSheet> {
  final _formKey = GlobalKey<FormState>();
  
  JobCategory _selectedCategory = JobCategory.electrical;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  String _workerName = 'Yared Girma (PRO - Certified Electrician)';
  bool _fetchingLocation = false;
  
  final _addressController = TextEditingController(text: 'Bole Atlas, Apt 4B, Addis Ababa');
  final _notesController = TextEditingController();

  final List<String> _sampleWorkers = [
    'Yared Girma (PRO - Certified Electrician)',
    'Alemayehu Tadesse (Plumbing Specialist)',
    'Hiwot Tesfaye (General Home Maintenance)',
  ];

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
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

  void _submitBooking() {
    if (_formKey.currentState!.validate()) {
      final timeFormatted = _selectedTime.format(context);
      final newBooking = Booking(
        id: 'bk-${DateTime.now().millisecondsSinceEpoch}',
        clientName: 'Solomon Ayalew',
        clientPhone: '+251 912 345 678',
        workerName: _workerName.split(' (').first,
        workerPhone: '+251 944 567 890',
        category: _selectedCategory,
        bookingDate: _selectedDate,
        timeSlot: timeFormatted,
        address: _addressController.text,
        notes: _notesController.text,
        status: BookingStatus.pending,
        createdAt: DateTime.now(),
      );

      widget.onBookingCreated(newBooking);

      // Capture date/worker info before the pop so the closure doesn't
      // accidentally use stale state after the widget is disposed.
      final formattedDate = _formatDate(_selectedDate);
      final workerDisplayName = _workerName.split(' (').first;
      final timeSlotLabel = timeFormatted;

      // Pop the sheet first, then show the confirmation dialog using the
      // parent navigator's context via the mounted check.
      Navigator.pop(context);

      // Show the notification confirmation dialog on the parent context.
      // We must re-check mounted because pop() deactivates this widget.
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
                        '📲 Worker Notified ($workerDisplayName):',
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

              // Worker Selector
              const Text(
                'SELECT WORKER',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: AppTheme.secondaryText,
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _workerName,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: _sampleWorkers.map((w) {
                  return DropdownMenuItem(
                    value: w,
                    child: Text(w, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _workerName = val);
                },
              ),
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
