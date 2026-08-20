import 'package:flutter/material.dart';
import '../../models/subscription_plan.dart';
import '../../theme/app_theme.dart';

class WorkerSubscriptionScreen extends StatefulWidget {
  const WorkerSubscriptionScreen({super.key});

  @override
  State<WorkerSubscriptionScreen> createState() => _WorkerSubscriptionScreenState();
}

class _WorkerSubscriptionScreenState extends State<WorkerSubscriptionScreen> {
  String _selectedPlanId = 'monthly';
  PaymentMethod _selectedPaymentMethod = PaymentMethod.telebirr;
  final TextEditingController _phoneController =
      TextEditingController(text: '+251 944 567 890');

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  SubscriptionPlan get _selectedPlan {
    return SubscriptionPlan.defaultPlans.firstWhere(
      (p) => p.id == _selectedPlanId,
      orElse: () => SubscriptionPlan.defaultPlans[1],
    );
  }

  void _processPayment() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEEF2FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.bolt_rounded, size: 36, color: Color(0xFF4F46E5)),
                ),
                const SizedBox(height: 16),
                Text(
                  'Processing Chapa Payment',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sending prompt to ${_phoneController.text} via ${_selectedPaymentMethod.title}...',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: AppTheme.secondaryText),
                ),
                const SizedBox(height: 20),
                const CircularProgressIndicator(color: Color(0xFF4F46E5)),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Subscription renewed! Your ${_selectedPlan.title} is active.'),
                        backgroundColor: const Color(0xFF10B981),
                      ),
                    );
                  },
                  child: const Text('Simulate Approval Success'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Status Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: const [
                        Text(
                          '30',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.darkText,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Days Left',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Your account has full access to claim unlimited jobs across Addis Ababa.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.secondaryText,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Section Header: Choose Renewal Plan
              _buildSectionLabel('CHOOSE RENEWAL PLAN'),
              const SizedBox(height: 10),

              // Subscription Plan Cards
              ...SubscriptionPlan.defaultPlans.map((plan) => _buildPlanCard(plan)),

              const SizedBox(height: 24),

              // Payment Method (Chapa) Section
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionLabel('PAYMENT METHOD (CHAPA)'),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Instant Activation',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4F46E5),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Payment Provider Grid
                    Row(
                      children: PaymentMethod.values.map((pm) {
                        final isSelected = _selectedPaymentMethod == pm;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedPaymentMethod = pm),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFEEF2FF)
                                    : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF4F46E5)
                                      : const Color(0xFFE2E8F0),
                                  width: isSelected ? 1.8 : 1.0,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    pm.title,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? const Color(0xFF4F46E5)
                                          : AppTheme.darkText,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    pm.subtitle,
                                    style: const TextStyle(
                                      fontSize: 9,
                                      color: AppTheme.secondaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),

                    // Mobile Number Input
                    _buildSectionLabel('PAYMENT MOBILE NUMBER'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Pay Button
                    ElevatedButton.icon(
                      onPressed: _processPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.bolt_rounded, size: 20),
                      label: Text(
                        'Pay with Chapa (${_selectedPlan.priceEtb.toInt()} ETB)',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan) {
    final isSelected = _selectedPlanId == plan.id;

    return GestureDetector(
      onTap: () => setState(() => _selectedPlanId = plan.id),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFEEF2FF) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0),
                width: isSelected ? 2.0 : 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? const Color(0xFF4F46E5) : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFCBD5E1),
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.darkText,
                            ),
                          ),
                          Text(
                            plan.subtitle,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${plan.priceEtb.toInt()} ETB',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? const Color(0xFF4F46E5) : AppTheme.darkText,
                      ),
                    ),
                  ],
                ),

                // Features bullet list if selected
                if (isSelected) ...[
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: Color(0xFFC7D2FE)),
                  const SizedBox(height: 12),
                  ...plan.features.map(
                    (feat) => Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Row(
                        children: [
                          const Icon(Icons.check_rounded,
                              size: 14, color: Color(0xFF4F46E5)),
                          const SizedBox(width: 8),
                          Text(
                            feat,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.darkText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          if (plan.isPopular)
            Positioned(
              right: 16,
              top: -8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF4F46E5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'MOST POPULAR',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
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
