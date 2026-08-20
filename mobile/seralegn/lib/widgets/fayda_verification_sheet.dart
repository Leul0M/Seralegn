import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FaydaVerificationSheet extends StatefulWidget {
  final String initialFaydaNumber;
  final Function(String number) onVerified;

  const FaydaVerificationSheet({
    super.key,
    required this.initialFaydaNumber,
    required this.onVerified,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String initialFaydaNumber,
    required Function(String number) onVerified,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: AppTheme.backgroundLight,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: FaydaVerificationSheet(
          initialFaydaNumber: initialFaydaNumber,
          onVerified: onVerified,
        ),
      ),
    );
  }

  @override
  State<FaydaVerificationSheet> createState() => _FaydaVerificationSheetState();
}

class _FaydaVerificationSheetState extends State<FaydaVerificationSheet> {
  late TextEditingController _faydaController;
  bool _isSendingCode = false;
  bool _codeSent = false;
  final TextEditingController _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _faydaController = TextEditingController(
      text: widget.initialFaydaNumber.isEmpty ? 'FAN-8492-3021-9876' : widget.initialFaydaNumber,
    );
  }

  @override
  void dispose() {
    _faydaController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _handleSendCode() {
    if (_faydaController.text.trim().isEmpty) return;
    setState(() {
      _isSendingCode = true;
    });

    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        setState(() {
          _isSendingCode = false;
          _codeSent = true;
        });
      }
    });
  }

  void _handleConfirmOtp() {
    widget.onVerified(_faydaController.text);
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Handle bar
        const SizedBox(height: 12),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        
        // App bar inside sheet
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              const Text(
                'Verify with Fayda',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.darkText,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Branding Header Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.inputBorder),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.lightTealBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.handyman_rounded, color: AppTheme.primaryTeal, size: 28),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Icon(Icons.swap_horiz, color: AppTheme.secondaryText, size: 24),
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.shield_outlined, color: Colors.white, size: 28),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Seralegn × Fayda',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.darkText,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Verify your identity securely using Ethiopia's national digital ID system.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.secondaryText,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Badges
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildBadge(Icons.lock_outline, 'Encrypted'),
                          _buildBadge(Icons.account_balance_outlined, 'Gov. Certified'),
                          _buildBadge(Icons.bolt_outlined, 'Instant'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Form section
                const Text(
                  'Enter your Fayda Number',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.darkText,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'FAN (Fayda Alias Number) or FCN (Fayda Card Number)',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.secondaryText,
                  ),
                ),
                const SizedBox(height: 12),

                // Input Field
                TextField(
                  controller: _faydaController,
                  enabled: !_codeSent,
                  decoration: InputDecoration(
                    hintText: 'Enter Your FAN (Fayda Alias Number)',
                    suffixIcon: const Icon(Icons.qr_code_scanner, color: AppTheme.primaryTeal),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.info_outline, size: 14, color: AppTheme.primaryTeal),
                    label: const Text(
                      'What is FAN/FCN?',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryTeal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                if (_codeSent) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTealBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.primaryTeal),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.mark_email_read_outlined, color: AppTheme.primaryTeal),
                            SizedBox(width: 8),
                            Text(
                              'Verification Code Sent',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppTheme.darkText,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'We sent a 6-digit OTP code to your registered mobile number (+251 91*** **78).',
                          style: TextStyle(fontSize: 12, color: AppTheme.secondaryText),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 8),
                          decoration: const InputDecoration(
                            hintText: '123456',
                            counterText: '',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // How it works section
                const Text(
                  'How it works',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.darkText,
                  ),
                ),
                const SizedBox(height: 12),
                _buildStepRow(1, 'Enter your FAN or FCN number below'),
                const SizedBox(height: 10),
                _buildStepRow(2, 'We send a verification code to your Fayda-registered phone'),
                const SizedBox(height: 10),
                _buildStepRow(3, "Confirm your identity and you're verified!"),
                const SizedBox(height: 32),

                // Button
                if (!_codeSent)
                  ElevatedButton(
                    onPressed: _isSendingCode ? null : _handleSendCode,
                    child: _isSendingCode
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Send Code'),
                  )
                else
                  ElevatedButton(
                    onPressed: _handleConfirmOtp,
                    child: const Text('Confirm Identity & Verify'),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.lightTealBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.lightTealBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppTheme.primaryTeal),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryTeal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepRow(int number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: AppTheme.primaryTeal,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '$number',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.secondaryText,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
