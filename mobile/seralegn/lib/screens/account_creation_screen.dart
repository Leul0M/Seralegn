import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../fayda/fayda_decoder.dart';
import '../models/onboarding_data.dart';
import '../models/user_role.dart';
import '../theme/app_theme.dart';
import '../widgets/fayda_verification_sheet.dart';
import '../widgets/progress_header.dart';

class AccountCreationScreen extends StatefulWidget {
  final OnboardingData onboardingData;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const AccountCreationScreen({
    super.key,
    required this.onboardingData,
    required this.onBack,
    required this.onNext,
  });

  @override
  State<AccountCreationScreen> createState() => _AccountCreationScreenState();
}

class _AccountCreationScreenState extends State<AccountCreationScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _neighborhoodController;
  late TextEditingController _passwordController;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.onboardingData.fullName);
    _phoneController = TextEditingController(text: widget.onboardingData.phoneNumber);
    _neighborhoodController = TextEditingController(text: widget.onboardingData.neighborhood);
    _passwordController = TextEditingController(text: widget.onboardingData.password);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _neighborhoodController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _openFaydaSheet() {
    FaydaVerificationSheet.show(
      context,
      initialFaydaNumber: widget.onboardingData.faydaNumber,
      onVerified: (FaydaSuccess fayda) {
        setState(() {
          // Fill identity fields
          widget.onboardingData.faydaNumber = fayda.fan ?? '';
          widget.onboardingData.isFaydaVerified = true;
          widget.onboardingData.fullName = fayda.fullName;
          widget.onboardingData.firstName = fayda.firstName;
          widget.onboardingData.fatherName = fayda.fatherName;
          widget.onboardingData.dateOfBirth = fayda.dateOfBirth ?? '';
          widget.onboardingData.gender = fayda.genderLabel;
          widget.onboardingData.lastFanDigits = fayda.lastFanDigits;

          // Set profile image from Fayda face bytes (if present)
          if (fayda.faceBytes != null && fayda.faceBytes!.isNotEmpty) {
            widget.onboardingData.profileImageBytes = fayda.faceBytes;
          }

          // Auto-fill name field
          _nameController.text = fayda.fullName;
        });
      },
    );
  }

  Future<void> _changeProfilePhoto() async {
    final action = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Change Profile Photo',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.darkText),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppTheme.lightTealBg,
                child: Icon(Icons.camera_alt_rounded, color: AppTheme.primaryTeal),
              ),
              title: const Text('Take a photo', style: TextStyle(fontWeight: FontWeight.w500)),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppTheme.lightTealBg,
                child: Icon(Icons.photo_library_rounded, color: AppTheme.primaryTeal),
              ),
              title: const Text('Choose from gallery', style: TextStyle(fontWeight: FontWeight.w500)),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );

    if (action == null) return;

    final picker = ImagePicker();
    final file = await picker.pickImage(source: action, imageQuality: 85, maxWidth: 512, maxHeight: 512);
    if (file == null) return;

    final bytes = await file.readAsBytes();
    setState(() {
      widget.onboardingData.profileImageBytes = bytes;
    });
  }

  void _handleContinue() {
    if (_passwordController.text.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters long.'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }
    if (!widget.onboardingData.isFaydaVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please verify with Fayda before continuing.'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }
    widget.onboardingData.fullName = _nameController.text.trim();
    widget.onboardingData.phoneNumber = _phoneController.text.trim();
    widget.onboardingData.neighborhood = _neighborhoodController.text.trim();
    widget.onboardingData.password = _passwordController.text.trim();
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final role = widget.onboardingData.role;
    final data = widget.onboardingData;
    final profileBytes = data.profileImageBytes != null
        ? Uint8List.fromList(data.profileImageBytes!)
        : null;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ProgressHeader(
              currentStep: 1,
              totalSteps: 3,
              onBack: widget.onBack,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      role.accountTitle,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      role.accountSubtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.secondaryText,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Profile Avatar ──────────────────────────────────────
                    Center(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          GestureDetector(
                            onTap: _changeProfilePhoto,
                            child: Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: data.isFaydaVerified
                                      ? AppTheme.primaryTeal
                                      : AppTheme.inputBorder,
                                  width: 3,
                                ),
                              ),
                              child: ClipOval(
                                child: profileBytes != null
                                    ? Image.memory(profileBytes, fit: BoxFit.cover)
                                    : Container(
                                        color: AppTheme.lightTealBg,
                                        child: const Icon(Icons.person, color: AppTheme.primaryTeal, size: 48),
                                      ),
                              ),
                            ),
                          ),
                          // Camera edit badge
                          Positioned(
                            bottom: 0,
                            right: -4,
                            child: GestureDetector(
                              onTap: _changeProfilePhoto,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryTeal,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14),
                              ),
                            ),
                          ),
                          // Verified shield overlay (top-left)
                          if (data.isFaydaVerified)
                            Positioned(
                              top: -4,
                              left: -4,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryTeal,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(Icons.verified_user_rounded, color: Colors.white, size: 12),
                              ),
                            ),
                        ],
                      ),
                    ),

                    if (data.isFaydaVerified) ...[
                      const SizedBox(height: 8),
                      const Center(
                        child: Text(
                          'Tap photo to change',
                          style: TextStyle(fontSize: 11, color: AppTheme.secondaryText),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // ── Fayda Verified Card ─────────────────────────────────
                    if (data.isFaydaVerified) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTealBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.primaryTeal),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.verified_user_rounded, color: AppTheme.primaryTeal, size: 18),
                                const SizedBox(width: 8),
                                const Text(
                                  'Verified by Fayda ID',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primaryTeal,
                                  ),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: _openFaydaSheet,
                                  child: const Text(
                                    'Re-scan',
                                    style: TextStyle(fontSize: 12, color: AppTheme.primaryTeal, decoration: TextDecoration.underline),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(child: _infoChip('Full Name', data.fullName)),
                                const SizedBox(width: 8),
                                Expanded(child: _infoChip('Gender', data.gender)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(child: _infoChip('Date of Birth', data.dateOfBirth.isEmpty ? '—' : data.dateOfBirth)),
                                const SizedBox(width: 8),
                                Expanded(child: _infoChip('FAN', data.lastFanDigits.isEmpty ? '—' : '•••• •••• ${data.lastFanDigits}')),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // ── Full Name ───────────────────────────────────────────
                    Text(
                      role.nameFieldLabel,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: role.defaultNameExample,
                        suffixIcon: data.isFaydaVerified
                            ? const Icon(Icons.verified_user_rounded, color: AppTheme.primaryTeal, size: 18)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Phone Number ────────────────────────────────────────
                    const Text(
                      'Phone Number',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        prefixIcon: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          child: Text(
                            '+251',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.darkText,
                            ),
                          ),
                        ),
                        hintText: role.defaultPhoneExample,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Neighborhood ────────────────────────────────────────
                    Text(
                      role.neighborhoodLabel,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _neighborhoodController,
                      decoration: InputDecoration(
                        hintText: role.defaultNeighborhoodExample,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Password ────────────────────────────────────────────
                    const Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Minimum 6 characters',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: AppTheme.secondaryText,
                          ),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Fayda Verify Button ─────────────────────────────────
                    InkWell(
                      onTap: _openFaydaSheet,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: data.isFaydaVerified
                              ? AppTheme.lightTealBg
                              : AppTheme.lightTealBg.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: data.isFaydaVerified
                                ? AppTheme.primaryTeal
                                : AppTheme.lightTealBorder,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              data.isFaydaVerified
                                  ? Icons.verified_user_rounded
                                  : Icons.qr_code_scanner,
                              color: AppTheme.primaryTeal,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                data.isFaydaVerified
                                    ? 'Fayda Verified ✓'
                                    : 'Scan Fayda ID to Verify',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryTeal,
                                ),
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: AppTheme.primaryTeal, size: 20),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // ── Continue Button ─────────────────────────────────────
                    ElevatedButton(
                      onPressed: _handleContinue,
                      style: !data.isFaydaVerified
                          ? ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFCBD5E1),
                              foregroundColor: Colors.white,
                            )
                          : null,
                      child: Text(role.step1ButtonLabel),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppTheme.secondaryText, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.darkText),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
