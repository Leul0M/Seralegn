import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/worker_model.dart';
import '../../../data/repositories/database_repository.dart';
import '../../core/theme.dart';
import '../payment/chapa_payment_screen.dart';

class SubscriptionTab extends StatefulWidget {
  final WorkerModel worker;
  final VoidCallback onRenewed;

  const SubscriptionTab({
    super.key,
    required this.worker,
    required this.onRenewed,
  });

  @override
  State<SubscriptionTab> createState() => _SubscriptionTabState();
}

class _SubscriptionTabState extends State<SubscriptionTab> {

  void _expireSubscriptionMock() {
    final dbRepo = Provider.of<DatabaseRepository>(context, listen: false);
    dbRepo.simulateSubscriptionExpiration(widget.worker.id);
    widget.onRenewed(); // Trigger parent reload
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mock Info: Subscription forced to EXPIRED state.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = widget.worker.daysLeft;
    final isExpired = days <= 0;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            // Circular Progress Indicator representing remaining days
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: CircularProgressIndicator(
                      value: isExpired ? 0.0 : (days > 30 ? 1.0 : days / 30.0),
                      strokeWidth: 12,
                      backgroundColor: Colors.grey.shade100,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isExpired
                            ? Colors.red
                            : days < 7
                                ? Colors.orange
                                : AppTheme.actionGreen,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isExpired ? 'Expired' : '$days',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: isExpired
                              ? Colors.red
                              : days < 7
                                  ? Colors.orange
                                  : AppTheme.primaryBlue,
                        ),
                      ),
                      Text(
                        isExpired ? 'Access Blocked' : 'Days Left',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // Subscription Status Card
            Card(
              color: isExpired
                  ? Colors.red.shade50
                  : days < 7
                      ? Colors.orange.shade50
                      : AppTheme.actionGreen.withOpacity(0.05),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                      isExpired
                          ? 'Your subscription has expired!'
                          : days < 7
                              ? 'Your subscription is expiring soon!'
                              : 'Your subscription is active!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isExpired
                            ? Colors.red.shade800
                            : days < 7
                                ? Colors.orange.shade800
                                : AppTheme.actionGreen,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isExpired
                          ? 'Renew now to unlock access to jobs and keep receiving requests.'
                          : 'You have full access to browse and claim open gigs in the marketplace.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'Premium Membership Benefits',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildBenefitRow(Icons.check_circle_rounded, 'Browse unlimited available gigs'),
            _buildBenefitRow(Icons.check_circle_rounded, 'Real-time client location maps'),
            _buildBenefitRow(Icons.check_circle_rounded, 'Secure in-app chat & calls'),
            _buildBenefitRow(Icons.check_circle_rounded, 'Zero platform commissions on earnings'),
            const SizedBox(height: 48),
            // Pay button
            ElevatedButton.icon(
              onPressed: () async {
                final success = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (context) => ChapaPaymentScreen(
                      workerId: widget.worker.id,
                      amount: 250.0,
                    ),
                  ),
                );
                if (success == true) {
                  widget.onRenewed();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.actionGreen,
                shadowColor: AppTheme.actionGreen.withOpacity(0.3),
              ),
              icon: const Icon(Icons.payment_rounded),
              label: const Text('Renew for 30 Days (250 ETB)'),
            ),
            const SizedBox(height: 32),
            // Dev simulation panel
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bug_report, color: Colors.red),
                      SizedBox(width: 8),
                      Text(
                        'Developer Simulation Controls',
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Click the button below to force expire this worker\'s subscription in-memory. This enables testing the feed blocker.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _expireSubscriptionMock,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Text('Force Expire Subscription'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.actionGreen, size: 20),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
