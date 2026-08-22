import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/subscription_plan.dart';

// ─── Chapa Brand Colors ───────────────────────────────────────────────────────
class _ChapaColors {
  static const Color green = Color(0xFF7DC400);
  static const Color darkNavy = Color(0xFF0D1B34);
  static const Color tealGreen = Color(0xFF268D60);
  static const Color bgLight = Color(0xFFF2F7FF);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E8F0);
  static const Color labelText = Color(0xFF64748B);
  static const Color inputBg = Color(0xFFF8FAFC);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color successGreen = Color(0xFF22C55E);
}

// ─── Payment Methods ──────────────────────────────────────────────────────────
enum _ChapaMethod {
  telebirr,
  cbeBirr,
  mpesa,
  awash,
  abyssinia,
  card,
}

extension _ChapaMethodExt on _ChapaMethod {
  String get label {
    switch (this) {
      case _ChapaMethod.telebirr:   return 'Telebirr';
      case _ChapaMethod.cbeBirr:    return 'CBE Birr';
      case _ChapaMethod.mpesa:      return 'M-Pesa';
      case _ChapaMethod.awash:      return 'Awash Bank';
      case _ChapaMethod.abyssinia:  return 'Bank of Abyssinia';
      case _ChapaMethod.card:       return 'Visa / Mastercard';
    }
  }

  String get subtitle {
    switch (this) {
      case _ChapaMethod.telebirr:   return 'Ethio Telecom';
      case _ChapaMethod.cbeBirr:    return 'Commercial Bank of Ethiopia';
      case _ChapaMethod.mpesa:      return 'Safaricom';
      case _ChapaMethod.awash:      return 'Awash International Bank';
      case _ChapaMethod.abyssinia:  return 'Bank of Abyssinia';
      case _ChapaMethod.card:       return 'International cards accepted';
    }
  }

  IconData get icon {
    switch (this) {
      case _ChapaMethod.telebirr:   return Icons.phone_android_rounded;
      case _ChapaMethod.cbeBirr:    return Icons.account_balance_rounded;
      case _ChapaMethod.mpesa:      return Icons.phone_android_outlined;
      case _ChapaMethod.awash:      return Icons.account_balance_outlined;
      case _ChapaMethod.abyssinia:  return Icons.account_balance_outlined;
      case _ChapaMethod.card:       return Icons.credit_card_rounded;
    }
  }

  Color get color {
    switch (this) {
      case _ChapaMethod.telebirr:   return const Color(0xFF009E60);
      case _ChapaMethod.cbeBirr:    return const Color(0xFF005BAA);
      case _ChapaMethod.mpesa:      return const Color(0xFF60BB46);
      case _ChapaMethod.awash:      return const Color(0xFFE2001A);
      case _ChapaMethod.abyssinia:  return const Color(0xFF003580);
      case _ChapaMethod.card:       return const Color(0xFF1A1F71);
    }
  }

  bool get isMobileWallet {
    switch (this) {
      case _ChapaMethod.telebirr:
      case _ChapaMethod.cbeBirr:
      case _ChapaMethod.mpesa:
        return true;
      default:
        return false;
    }
  }

  bool get isBankApp {
    switch (this) {
      case _ChapaMethod.awash:
      case _ChapaMethod.abyssinia:
        return true;
      default:
        return false;
    }
  }
}

// ─── Entry Point ──────────────────────────────────────────────────────────────
Future<bool?> showChapaPaymentSheet(
  BuildContext context, {
  required SubscriptionPlan plan,
  required String prefillPhone,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ChapaPaymentSheet(plan: plan, prefillPhone: prefillPhone),
  );
}

// ─── Main Sheet Widget ────────────────────────────────────────────────────────
class _ChapaPaymentSheet extends StatefulWidget {
  final SubscriptionPlan plan;
  final String prefillPhone;
  const _ChapaPaymentSheet({required this.plan, required this.prefillPhone});

  @override
  State<_ChapaPaymentSheet> createState() => _ChapaPaymentSheetState();
}

enum _SheetStep { methodSelect, phoneEntry, otpEntry, cardEntry, processing, success, failed }

class _ChapaPaymentSheetState extends State<_ChapaPaymentSheet>
    with SingleTickerProviderStateMixin {
  _ChapaMethod _selectedMethod = _ChapaMethod.telebirr;
  _SheetStep _step = _SheetStep.methodSelect;

  final _phoneCtrl = TextEditingController();
  final _otpCtrls = List.generate(6, (_) => TextEditingController());
  final _otpFocuses = List.generate(6, (_) => FocusNode());
  final _cardNumCtrl = TextEditingController();
  final _cardExpCtrl = TextEditingController();
  final _cardCvvCtrl = TextEditingController();
  final _cardNameCtrl = TextEditingController();

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  String? _txRef;
  Timer? _autoTimer;

  @override
  void initState() {
    super.initState();
    _phoneCtrl.text = widget.prefillPhone;
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _phoneCtrl.dispose();
    for (var c in _otpCtrls) { c.dispose(); }
    for (var f in _otpFocuses) { f.dispose(); }
    _cardNumCtrl.dispose();
    _cardExpCtrl.dispose();
    _cardCvvCtrl.dispose();
    _cardNameCtrl.dispose();
    _autoTimer?.cancel();
    super.dispose();
  }

  void _goTo(_SheetStep step) {
    setState(() => _step = step);
    _animCtrl.forward(from: 0);
  }

  void _onContinue() {
    if (_selectedMethod.isMobileWallet || _selectedMethod.isBankApp) {
      _goTo(_SheetStep.phoneEntry);
    } else {
      _goTo(_SheetStep.cardEntry);
    }
  }

  void _onSendOtp() {
    _txRef = 'TX-${DateTime.now().millisecondsSinceEpoch}';
    _goTo(_SheetStep.otpEntry);
  }

  void _onVerifyOtp() {
    _goTo(_SheetStep.processing);
    // Simulate processing delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _goTo(_SheetStep.success);
    });
  }

  void _onPayCard() {
    _goTo(_SheetStep.processing);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _goTo(_SheetStep.success);
    });
  }

  void _onDone() => Navigator.of(context).pop(true);
  void _onFail() => Navigator.of(context).pop(false);

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Container(
      constraints: BoxConstraints(maxHeight: mq.size.height * 0.92),
      decoration: const BoxDecoration(
        color: _ChapaColors.cardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Chapa Header
          _buildChapaHeader(),
          const Divider(height: 1, color: _ChapaColors.border),
          // Body
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 20, right: 20, top: 20,
                bottom: mq.viewInsets.bottom + 24,
              ),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: _buildStepContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildChapaHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Chapa Logo Area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _ChapaColors.darkNavy,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 18, height: 18,
                  decoration: const BoxDecoration(
                    color: _ChapaColors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.bolt, size: 12, color: Colors.white),
                ),
                const SizedBox(width: 6),
                const Text(
                  'chapa',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Seralegn · ${widget.plan.title}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _ChapaColors.darkNavy,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'ETB ${widget.plan.priceEtb.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: _ChapaColors.labelText,
                  ),
                ),
              ],
            ),
          ),
          // Amount Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _ChapaColors.successGreen.withValues(alpha: 0.3)),
            ),
            child: Text(
              '${widget.plan.priceEtb.toInt()} ETB',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: _ChapaColors.successGreen,
              ),
            ),
          ),
          // Close
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(false),
            child: Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.close, size: 16, color: _ChapaColors.labelText),
            ),
          ),
        ],
      ),
    );
  }

  // ── Step Router ─────────────────────────────────────────────────────────────
  Widget _buildStepContent() {
    switch (_step) {
      case _SheetStep.methodSelect:  return _buildMethodSelect();
      case _SheetStep.phoneEntry:    return _buildPhoneEntry();
      case _SheetStep.otpEntry:      return _buildOtpEntry();
      case _SheetStep.cardEntry:     return _buildCardEntry();
      case _SheetStep.processing:    return _buildProcessing();
      case _SheetStep.success:       return _buildSuccess();
      case _SheetStep.failed:        return _buildFailed();
    }
  }

  // ── Step 1: Method Selection ─────────────────────────────────────────────
  Widget _buildMethodSelect() {
    final mobileWallets = _ChapaMethod.values.where((m) => m.isMobileWallet).toList();
    final bankApps = _ChapaMethod.values.where((m) => m.isBankApp).toList();
    final cardMethods = _ChapaMethod.values.where((m) => m == _ChapaMethod.card).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Payment Method', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _ChapaColors.darkNavy)),
        const SizedBox(height: 4),
        const Text('Choose how you want to pay securely', style: TextStyle(fontSize: 12, color: _ChapaColors.labelText)),
        const SizedBox(height: 20),

        _buildMethodGroup('Mobile Wallets', mobileWallets),
        const SizedBox(height: 16),
        _buildMethodGroup('Bank Apps', bankApps),
        const SizedBox(height: 16),
        _buildMethodGroup('Card Payment', cardMethods),

        const SizedBox(height: 24),

        // Continue Button
        _buildChapaButton(
          label: 'Continue',
          onTap: _onContinue,
        ),
        const SizedBox(height: 16),
        _buildSecurityFooter(),
      ],
    );
  }

  Widget _buildMethodGroup(String title, List<_ChapaMethod> methods) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _ChapaColors.labelText, letterSpacing: 0.8),
        ),
        const SizedBox(height: 8),
        ...methods.map((m) => _buildMethodTile(m)),
      ],
    );
  }

  Widget _buildMethodTile(_ChapaMethod method) {
    final isSelected = _selectedMethod == method;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = method),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? method.color.withValues(alpha: 0.06) : _ChapaColors.inputBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? method.color : _ChapaColors.border,
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: method.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(method.icon, color: method.color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(method.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _ChapaColors.darkNavy)),
                  Text(method.subtitle, style: const TextStyle(fontSize: 11, color: _ChapaColors.labelText)),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 20, height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? method.color : Colors.transparent,
                border: Border.all(
                  color: isSelected ? method.color : const Color(0xFFCBD5E1),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ── Step 2: Phone Entry ──────────────────────────────────────────────────
  Widget _buildPhoneEntry() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBackButton(() => _goTo(_SheetStep.methodSelect)),
        const SizedBox(height: 16),
        Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: _selectedMethod.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_selectedMethod.icon, color: _selectedMethod.color, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_selectedMethod.label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _ChapaColors.darkNavy)),
                Text(_selectedMethod.subtitle, style: const TextStyle(fontSize: 11, color: _ChapaColors.labelText)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text('Mobile Number', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _ChapaColors.labelText)),
        const SizedBox(height: 8),
        TextField(
          controller: _phoneCtrl,
          keyboardType: TextInputType.phone,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _ChapaColors.darkNavy),
          decoration: InputDecoration(
            filled: true,
            fillColor: _ChapaColors.inputBg,
            hintText: '+251 9XX XXX XXX',
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: Text('🇪🇹', style: const TextStyle(fontSize: 20)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _ChapaColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _ChapaColors.green, width: 1.8)),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Row(
            children: const [
              Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFFD97706)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'You\'ll receive a push notification / SMS prompt to authorize this payment.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF92400E), height: 1.4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildChapaButton(label: 'Send Payment Prompt', onTap: _onSendOtp),
        const SizedBox(height: 16),
        _buildSecurityFooter(),
      ],
    );
  }

  // ── Step 3: OTP Entry ────────────────────────────────────────────────────
  Widget _buildOtpEntry() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBackButton(() => _goTo(_SheetStep.phoneEntry)),
        const SizedBox(height: 16),
        const Center(
          child: Icon(Icons.sms_rounded, size: 48, color: _ChapaColors.green),
        ),
        const SizedBox(height: 16),
        const Center(
          child: Text('Enter OTP Code', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _ChapaColors.darkNavy)),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            'A 6-digit code was sent to ${_phoneCtrl.text}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: _ChapaColors.labelText),
          ),
        ),
        const SizedBox(height: 28),
        // OTP Fields
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(6, (i) => _buildOtpBox(i)),
        ),
        const SizedBox(height: 20),
        Center(
          child: TextButton(
            onPressed: () {},
            child: const Text('Resend OTP', style: TextStyle(fontSize: 13, color: _ChapaColors.green, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 8),
        _buildChapaButton(label: 'Verify & Pay', onTap: _onVerifyOtp),
        const SizedBox(height: 16),
        _buildSecurityFooter(),
      ],
    );
  }

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 44,
      child: TextField(
        controller: _otpCtrls[index],
        focusNode: _otpFocuses[index],
        textAlign: TextAlign.center,
        maxLength: 1,
        keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _ChapaColors.darkNavy),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: _ChapaColors.inputBg,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _ChapaColors.border, width: 1.5)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _ChapaColors.green, width: 2)),
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (v) {
          if (v.isNotEmpty && index < 5) {
            _otpFocuses[index + 1].requestFocus();
          } else if (v.isEmpty && index > 0) {
            _otpFocuses[index - 1].requestFocus();
          }
        },
      ),
    );
  }

  // ── Step 4: Card Entry ───────────────────────────────────────────────────
  Widget _buildCardEntry() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBackButton(() => _goTo(_SheetStep.methodSelect)),
        const SizedBox(height: 16),
        const Text('Card Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _ChapaColors.darkNavy)),
        const SizedBox(height: 4),
        const Text('Securely enter your card information', style: TextStyle(fontSize: 12, color: _ChapaColors.labelText)),
        const SizedBox(height: 20),

        // Card Preview
        Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0D1B34), Color(0xFF1A3A5C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: const Color(0xFF0D1B34).withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -30, top: -30,
                child: Container(
                  width: 130, height: 130,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                right: 20, bottom: -20,
                child: Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _ChapaColors.green.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('chapa', style: TextStyle(color: _ChapaColors.green, fontWeight: FontWeight.w800, fontSize: 11)),
                        ),
                        Row(
                          children: [
                            Container(width: 24, height: 24, decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.8), shape: BoxShape.circle)),
                            Transform.translate(
                              offset: const Offset(-10, 0),
                              child: Container(width: 24, height: 24, decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.8), shape: BoxShape.circle)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    ValueListenableBuilder(
                      valueListenable: _cardNumCtrl,
                      builder: (context, value, child) {
                        final raw = _cardNumCtrl.text.replaceAll(' ', '');
                        final padded = raw.padRight(16, '•');
                        final formatted = '${padded.substring(0, 4)} ${padded.substring(4, 8)} ${padded.substring(8, 12)} ${padded.substring(12, 16)}';
                        return Text(
                          formatted,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 2),
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('CARD HOLDER', style: TextStyle(color: Colors.white54, fontSize: 8, letterSpacing: 1)),
                            const SizedBox(height: 2),
                            ValueListenableBuilder(
                              valueListenable: _cardNameCtrl,
                              builder: (context, value, child) => Text(
                                _cardNameCtrl.text.isEmpty ? 'FULL NAME' : _cardNameCtrl.text.toUpperCase(),
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('EXPIRES', style: TextStyle(color: Colors.white54, fontSize: 8, letterSpacing: 1)),
                            const SizedBox(height: 2),
                            ValueListenableBuilder(
                              valueListenable: _cardExpCtrl,
                              builder: (context, value, child) => Text(
                                _cardExpCtrl.text.isEmpty ? 'MM/YY' : _cardExpCtrl.text,
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Card Number
        _buildCardFieldLabel('Card Number'),
        const SizedBox(height: 6),
        TextField(
          controller: _cardNumCtrl,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _ChapaColors.darkNavy),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, _CardNumberFormatter()],
          maxLength: 19,
          decoration: _cardInputDecoration(hint: '0000 0000 0000 0000', suffixIcon: Icons.credit_card_rounded),
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCardFieldLabel('Expiry Date'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _cardExpCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _ChapaColors.darkNavy),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, _ExpiryFormatter()],
                    maxLength: 5,
                    decoration: _cardInputDecoration(hint: 'MM / YY'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCardFieldLabel('CVV'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _cardCvvCtrl,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 3,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _ChapaColors.darkNavy),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: _cardInputDecoration(hint: '•••', suffixIcon: Icons.lock_outline_rounded),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        _buildCardFieldLabel('Cardholder Name'),
        const SizedBox(height: 6),
        TextField(
          controller: _cardNameCtrl,
          textCapitalization: TextCapitalization.characters,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _ChapaColors.darkNavy),
          decoration: _cardInputDecoration(hint: 'As printed on card'),
        ),

        const SizedBox(height: 24),
        _buildChapaButton(label: 'Pay ${widget.plan.priceEtb.toInt()} ETB', onTap: _onPayCard),
        const SizedBox(height: 16),
        _buildSecurityFooter(),
      ],
    );
  }

  Widget _buildCardFieldLabel(String label) {
    return Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _ChapaColors.labelText));
  }

  InputDecoration _cardInputDecoration({required String hint, IconData? suffixIcon}) {
    return InputDecoration(
      counterText: '',
      filled: true,
      fillColor: _ChapaColors.inputBg,
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFCBD5E1), fontWeight: FontWeight.normal),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      suffixIcon: suffixIcon != null ? Icon(suffixIcon, size: 18, color: _ChapaColors.labelText) : null,
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _ChapaColors.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _ChapaColors.green, width: 1.8)),
    );
  }

  // ── Processing ───────────────────────────────────────────────────────────
  Widget _buildProcessing() {
    return SizedBox(
      height: 260,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 60, height: 60,
            child: CircularProgressIndicator(
              color: _ChapaColors.green,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          const Text('Processing Payment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _ChapaColors.darkNavy)),
          const SizedBox(height: 8),
          const Text('Please wait, do not close this window...', style: TextStyle(fontSize: 12, color: _ChapaColors.labelText)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_rounded, size: 12, color: _ChapaColors.tealGreen),
                SizedBox(width: 6),
                Text('Secured by Chapa', style: TextStyle(fontSize: 11, color: _ChapaColors.tealGreen, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Success ──────────────────────────────────────────────────────────────
  Widget _buildSuccess() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          width: 80, height: 80,
          decoration: const BoxDecoration(color: Color(0xFFF0FDF4), shape: BoxShape.circle),
          child: const Icon(Icons.check_circle_rounded, size: 48, color: _ChapaColors.successGreen),
        ),
        const SizedBox(height: 20),
        const Text('Payment Successful!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _ChapaColors.darkNavy)),
        const SizedBox(height: 8),
        Text(
          'Your ${widget.plan.title} subscription is now active.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: _ChapaColors.labelText, height: 1.5),
        ),
        const SizedBox(height: 24),
        // Transaction Reference
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _ChapaColors.inputBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _ChapaColors.border),
          ),
          child: Column(
            children: [
              _buildReceiptRow('Amount', 'ETB ${widget.plan.priceEtb.toStringAsFixed(2)}'),
              const Divider(height: 20, color: _ChapaColors.border),
              _buildReceiptRow('Plan', widget.plan.title),
              const Divider(height: 20, color: _ChapaColors.border),
              _buildReceiptRow('Duration', '${widget.plan.durationDays} Days'),
              const Divider(height: 20, color: _ChapaColors.border),
              _buildReceiptRow('Tx Ref', _txRef ?? 'TX-${DateTime.now().millisecondsSinceEpoch}'),
              const Divider(height: 20, color: _ChapaColors.border),
              _buildReceiptRow('Status', 'PAID', valueColor: _ChapaColors.successGreen),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildChapaButton(label: 'Done', onTap: _onDone),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildReceiptRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: _ChapaColors.labelText)),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: valueColor ?? _ChapaColors.darkNavy,
          ),
        ),
      ],
    );
  }

  // ── Failed ───────────────────────────────────────────────────────────────
  Widget _buildFailed() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          width: 80, height: 80,
          decoration: const BoxDecoration(color: Color(0xFFFEF2F2), shape: BoxShape.circle),
          child: const Icon(Icons.cancel_rounded, size: 48, color: _ChapaColors.errorRed),
        ),
        const SizedBox(height: 20),
        const Text('Payment Failed', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _ChapaColors.darkNavy)),
        const SizedBox(height: 8),
        const Text('Transaction was declined. Please try again.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: _ChapaColors.labelText)),
        const SizedBox(height: 24),
        _buildChapaButton(label: 'Try Again', onTap: () => _goTo(_SheetStep.methodSelect)),
        const SizedBox(height: 12),
        TextButton(onPressed: _onFail, child: const Text('Cancel', style: TextStyle(color: _ChapaColors.labelText))),
      ],
    );
  }

  // ── Common Widgets ───────────────────────────────────────────────────────
  Widget _buildChapaButton({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7DC400), Color(0xFF5FA000)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: const Color(0xFF7DC400).withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 5)),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.3),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.arrow_back_ios_rounded, size: 14, color: _ChapaColors.labelText),
          SizedBox(width: 4),
          Text('Back', style: TextStyle(fontSize: 13, color: _ChapaColors.labelText, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildSecurityFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.lock_rounded, size: 11, color: _ChapaColors.labelText),
        SizedBox(width: 5),
        Text('Secured by Chapa · PCI DSS Compliant', style: TextStyle(fontSize: 10, color: _ChapaColors.labelText)),
      ],
    );
  }
}

// ─── Input Formatters ─────────────────────────────────────────────────────────
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll('/', '');
    if (digits.length <= 2) return newValue.copyWith(text: digits, selection: TextSelection.collapsed(offset: digits.length));
    final result = '${digits.substring(0, 2)}/${digits.substring(2)}';
    return newValue.copyWith(text: result, selection: TextSelection.collapsed(offset: result.length));
  }
}
