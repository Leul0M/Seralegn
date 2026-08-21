import 'package:flutter/material.dart';
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
      onVerified: (number) {
        setState(() {
          widget.onboardingData.faydaNumber = number;
          widget.onboardingData.isFaydaVerified = true;
        });
      },
    );
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

                    // Full Name
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
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Phone Number
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

                    // Neighborhood
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

                    // Password
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
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Fayda Verification Action Card / Button
                    InkWell(
                      onTap: _openFaydaSheet,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: widget.onboardingData.isFaydaVerified
                              ? AppTheme.lightTealBg
                              : AppTheme.lightTealBg.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: widget.onboardingData.isFaydaVerified
                                ? AppTheme.primaryTeal
                                : AppTheme.lightTealBorder,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              widget.onboardingData.isFaydaVerified
                                  ? Icons.verified_user_rounded
                                  : Icons.shield_outlined,
                              color: AppTheme.primaryTeal,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                widget.onboardingData.isFaydaVerified
                                    ? 'Fayda Verified (${widget.onboardingData.faydaNumber})'
                                    : 'Verify with Fayda',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryTeal,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: AppTheme.primaryTeal,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Primary Button
                    ElevatedButton(
                      onPressed: _handleContinue,
                      style: !widget.onboardingData.isFaydaVerified
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
}
