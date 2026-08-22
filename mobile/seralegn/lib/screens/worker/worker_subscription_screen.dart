import 'package:flutter/material.dart';
import '../../models/subscription_plan.dart';
import '../../theme/app_theme.dart';
import 'chapa_payment_sheet.dart';

class WorkerSubscriptionScreen extends StatefulWidget {
  const WorkerSubscriptionScreen({super.key});

  @override
  State<WorkerSubscriptionScreen> createState() => _WorkerSubscriptionScreenState();
}

class _WorkerSubscriptionScreenState extends State<WorkerSubscriptionScreen> {
  String _selectedPlanId = 'monthly';
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

  Future<void> _processPayment() async {
    final success = await showChapaPaymentSheet(
      context,
      plan: _selectedPlan,
      prefillPhone: _phoneController.text,
    );
    if (!mounted) return;
    if (success == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 Subscription activated! Your ${_selectedPlan.title} is now live.'),
          backgroundColor: const Color(0xFF22C55E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
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

              // Payment Section
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
                        _buildSectionLabel('PAYMENT'),
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
                              color: AppTheme.primaryTeal,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Chapa Pay Button
                    GestureDetector(
                      onTap: _processPayment,
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF7DC400), Color(0xFF5FA000)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF7DC400).withValues(alpha: 0.35),
                              blurRadius: 14,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 22, height: 22,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.bolt, size: 14, color: Colors.white),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Pay ${_selectedPlan.priceEtb.toInt()} ETB via Chapa',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Chapa badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.lock_rounded, size: 11, color: Color(0xFF94A3B8)),
                        SizedBox(width: 4),
                        Text(
                          'Secured by Chapa · PCI DSS Compliant',
                          style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                        ),
                      ],
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
                color: isSelected ? AppTheme.primaryTeal : const Color(0xFFE2E8F0),
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
                        color: isSelected ? AppTheme.primaryTeal : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? AppTheme.primaryTeal : const Color(0xFFCBD5E1),
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
                        color: isSelected ? AppTheme.primaryTeal : AppTheme.darkText,
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
                              size: 14, color: AppTheme.primaryTeal),
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
                  color: AppTheme.primaryTeal,
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
