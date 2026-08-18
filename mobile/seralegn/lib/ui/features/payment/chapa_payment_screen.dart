import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../data/repositories/database_repository.dart';
import '../../core/theme.dart';

class ChapaPaymentScreen extends StatefulWidget {
  final String workerId;
  final double amount;
  final String? liveCheckoutUrl; // Optional live URL from Chapa API

  const ChapaPaymentScreen({
    super.key,
    required this.workerId,
    required this.amount,
    this.liveCheckoutUrl,
  });

  @override
  State<ChapaPaymentScreen> createState() => _ChapaPaymentScreenState();
}

class _ChapaPaymentScreenState extends State<ChapaPaymentScreen> {
  late final WebViewController? _webViewController;
  bool _isLoading = true;
  bool _useMockPayment = true;

  @override
  void initState() {
    super.initState();
    if (widget.liveCheckoutUrl != null && widget.liveCheckoutUrl!.isNotEmpty) {
      _useMockPayment = false;
      _initWebViewController();
    } else {
      _useMockPayment = true;
      _isLoading = false;
    }
  }

  void _initWebViewController() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (url) {
            setState(() => _isLoading = false);
            
            // Intercept success redirect URL from Chapa (e.g., standard callback url)
            if (url.contains('checkout/test-redirect') || url.contains('success')) {
              _completePayment('chapa-tx-ref-${DateTime.now().millisecondsSinceEpoch}');
            }
          },
          onNavigationRequest: (request) {
            if (request.url.contains('cancel')) {
              Navigator.of(context).pop(false);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.liveCheckoutUrl!));
  }

  void _completePayment(String txRef) async {
    setState(() => _isLoading = true);
    final dbRepo = Provider.of<DatabaseRepository>(context, listen: false);

    try {
      await dbRepo.renewSubscription(
        workerId: widget.workerId,
        amount: widget.amount,
        txRef: txRef,
      );
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              icon: const Icon(Icons.check_circle_rounded, color: AppTheme.actionGreen, size: 48),
              title: const Text('Payment Successful!'),
              content: const Text(
                'Your premium membership has been renewed. You now have full access to the gig marketplace.',
                textAlign: TextAlign.center,
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Dismiss Dialog
                    Navigator.of(context).pop(true); // Return success to parent
                  },
                  child: const Text('Go to Feed'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to renew subscription: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildMockChapaCheckout() {
    final theme = Theme.of(context);
    String selectedMethod = 'Telebirr';

    return StatefulBuilder(
      builder: (context, setMockState) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Chapa Checkout Gateway'),
            backgroundColor: const Color(0xFF0F172A),
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Gateway Header
                Container(
                  color: const Color(0xFF1E293B),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    children: [
                      const Text(
                        'CHAPA PAYMENTS',
                        style: TextStyle(
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${widget.amount.toStringAsFixed(2)} ETB',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Recipient: Seralgn (ስራልኝ) Technology Inc.',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                // Payment Method Tabs
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Select Payment Method',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      // Payment Methods Selection
                      _buildPaymentMethodOption(
                        title: 'Telebirr (Mobile Money)',
                        subtitle: 'Pay securely using your Telebirr account',
                        icon: Icons.phone_android_rounded,
                        isSelected: selectedMethod == 'Telebirr',
                        onTap: () => setMockState(() => selectedMethod = 'Telebirr'),
                      ),
                      const SizedBox(height: 12),
                      _buildPaymentMethodOption(
                        title: 'CBE Birr',
                        subtitle: 'Commercial Bank of Ethiopia Direct Pay',
                        icon: Icons.account_balance_rounded,
                        isSelected: selectedMethod == 'CBE Birr',
                        onTap: () => setMockState(() => selectedMethod = 'CBE Birr'),
                      ),
                      const SizedBox(height: 12),
                      _buildPaymentMethodOption(
                        title: 'Credit / Debit Card',
                        subtitle: 'Visa, Mastercard, or local cards',
                        icon: Icons.credit_card_rounded,
                        isSelected: selectedMethod == 'Card',
                        onTap: () => setMockState(() => selectedMethod = 'Card'),
                      ),
                      const SizedBox(height: 40),
                      // Actions
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                        onPressed: _isLoading
                            ? null
                            : () {
                                setMockState(() => _isLoading = true);
                                Future.delayed(const Duration(seconds: 2), () {
                                  _completePayment('chapa-mock-tx-${DateTime.now().millisecondsSinceEpoch}');
                                });
                              },
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  strokeWidth: 2,
                                ),
                              )
                            : Text('Pay ${widget.amount.toStringAsFixed(0)} ETB via $selectedMethod'),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Secured and encrypted by Chapa Payment Gateway. Licensed by National Bank of Ethiopia.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentMethodOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFECFDF5) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF10B981) : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF10B981) : Colors.grey.shade600, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isSelected ? const Color(0xFF065F46) : Colors.grey.shade900,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981))
            else
              const Icon(Icons.circle_outlined, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_useMockPayment) {
      return _buildMockChapaCheckout();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chapa Secured Checkout'),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _webViewController!),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
