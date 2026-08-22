import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../fayda/fayda_decoder.dart';
import '../theme/app_theme.dart';

/// Result returned when Fayda scan succeeds.
class FaydaScanResult {
  final FaydaSuccess fayda;
  FaydaScanResult(this.fayda);
}

class FaydaVerificationSheet extends StatefulWidget {
  final String initialFaydaNumber;
  final Function(FaydaSuccess result) onVerified;

  const FaydaVerificationSheet({
    super.key,
    required this.initialFaydaNumber,
    required this.onVerified,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String initialFaydaNumber,
    required Function(FaydaSuccess result) onVerified,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.92,
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

class _FaydaVerificationSheetState extends State<FaydaVerificationSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  bool _loading = false;
  String? _error;
  bool _cameraHandled = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _tabs.addListener(() => setState(() => _error = null));
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  void _handleQrText(String text) {
    if (_cameraHandled || _loading) return;
    _cameraHandled = true;
    _processText(text);
  }

  Future<void> _processText(String text) async {
    setState(() { _loading = true; _error = null; });
    final result = decodePayload(text, includeFace: true);
    if (!mounted) return;

    if (result is FaydaResultOk) {
      widget.onVerified(result.data);
      if (mounted) Navigator.of(context).pop(true);
    } else if (result is FaydaResultErr) {
      final msgs = {
        FaydaErrorCode.notFayda: 'QR found but it\'s not a Fayda ID.\nMake sure you scan the BACK of the card.',
        FaydaErrorCode.unsupportedVersion: 'Unsupported card version. Please update the app.',
        FaydaErrorCode.noQrFound: 'No QR code found. Retake the photo with more light.',
        FaydaErrorCode.qrUnreadable: 'QR code unreadable. Try a clearer photo.',
      };
      setState(() {
        _error = msgs[result.error.code] ?? result.error.message;
        _loading = false;
        _cameraHandled = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 100);
    if (file == null) return;

    setState(() { _loading = true; _error = null; });
    final ctrl = MobileScannerController();
    final result = await ctrl.analyzeImage(file.path);
    await ctrl.dispose();

    if (!mounted) return;
    if (result != null && result.barcodes.isNotEmpty) {
      final raw = result.barcodes.first.rawValue;
      if (raw != null) {
        _processText(raw);
        return;
      }
    }
    setState(() {
      _error = 'No QR code found in the selected image.\nTry a clearer photo of the BACK of the card.';
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        // Handle bar
        Container(
          width: 40, height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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

        // Branding card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(16),
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
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTealBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.handyman_rounded, color: AppTheme.primaryTeal, size: 22),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(Icons.swap_horiz, color: AppTheme.secondaryText, size: 20),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.shield_outlined, color: Colors.white, size: 22),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Seralegn × Fayda',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.darkText),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Scan the QR code on the BACK of your Fayda card.\nYour identity is verified securely on-device.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppTheme.secondaryText, height: 1.4),
                ),
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _badge(Icons.lock_outline, 'Encrypted'),
                    _badge(Icons.account_balance_outlined, 'Gov. Certified'),
                    _badge(Icons.bolt_outlined, 'Instant'),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Tab bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: AppTheme.inputBorder),
            ),
            child: TabBar(
              controller: _tabs,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: AppTheme.primaryTeal,
              ),
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: AppTheme.secondaryText,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              tabs: const [
                Tab(text: '📷  Camera'),
                Tab(text: '🖼️  Gallery'),
              ],
            ),
          ),
        ),

        // Error banner
        if (_error != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Color(0xFFDC2626), fontSize: 12, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 10),

        // Content
        Expanded(
          child: _loading
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: AppTheme.primaryTeal),
                    const SizedBox(height: 16),
                    Text(
                      'Reading your Fayda ID…',
                      style: TextStyle(color: AppTheme.secondaryText, fontSize: 14),
                    ),
                  ],
                )
              : TabBarView(
                  controller: _tabs,
                  children: [
                    // Camera tab
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          children: [
                            MobileScanner(
                              onDetect: (capture) {
                                final raw = capture.barcodes.firstOrNull?.rawValue;
                                if (raw != null) _handleQrText(raw);
                              },
                            ),
                            // Corner frame overlay
                            Positioned.fill(
                              child: CustomPaint(painter: _ScanFramePainter()),
                            ),
                            Positioned(
                              bottom: 16, left: 0, right: 0,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: const Text(
                                    'Point at the QR on the back of the card',
                                    style: TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Gallery tab
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.inputBorder),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppTheme.lightTealBg,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.photo_library_outlined, color: AppTheme.primaryTeal, size: 44),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Upload Fayda Card Photo',
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.darkText),
                            ),
                            const SizedBox(height: 8),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                'Select a clear photo of the BACK of your\nFayda card where the QR code is visible.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 13, color: AppTheme.secondaryText, height: 1.5),
                              ),
                            ),
                            const SizedBox(height: 32),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: ElevatedButton.icon(
                                onPressed: _pickImage,
                                icon: const Icon(Icons.upload_file_rounded, size: 18),
                                label: const Text('Choose from Gallery'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _badge(IconData icon, String text) {
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
          Icon(icon, size: 12, color: AppTheme.primaryTeal),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.primaryTeal)),
        ],
      ),
    );
  }
}

/// Draws the four corner bracket guides for the scan frame.
class _ScanFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryTeal
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    const r = 12.0;
    const len = 28.0;
    final cx = size.width / 2;
    final cy = size.height / 2;
    const hw = 110.0;
    const hh = 110.0;

    // Top-left
    canvas.drawPath(Path()
      ..moveTo(cx - hw + r, cy - hh)..lineTo(cx - hw + r + len, cy - hh)
      ..moveTo(cx - hw, cy - hh + r)..lineTo(cx - hw, cy - hh + r + len), paint);
    // Top-right
    canvas.drawPath(Path()
      ..moveTo(cx + hw - r, cy - hh)..lineTo(cx + hw - r - len, cy - hh)
      ..moveTo(cx + hw, cy - hh + r)..lineTo(cx + hw, cy - hh + r + len), paint);
    // Bottom-left
    canvas.drawPath(Path()
      ..moveTo(cx - hw + r, cy + hh)..lineTo(cx - hw + r + len, cy + hh)
      ..moveTo(cx - hw, cy + hh - r)..lineTo(cx - hw, cy + hh - r - len), paint);
    // Bottom-right
    canvas.drawPath(Path()
      ..moveTo(cx + hw - r, cy + hh)..lineTo(cx + hw - r - len, cy + hh)
      ..moveTo(cx + hw, cy + hh - r)..lineTo(cx + hw, cy + hh - r - len), paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
