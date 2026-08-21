import 'package:flutter/material.dart';
import '../services/location_service.dart';
import '../theme/app_theme.dart';

class SimulatedMapWidget extends StatelessWidget {
  final String locationName;
  final String? subAddress;
  final double latitude;
  final double longitude;
  final String districtLabel;
  final bool showWorkerRoute;
  final bool isInteractive;
  final VoidCallback? onGpsPressed;
  final ValueChanged<String>? onLocationSelected;

  const SimulatedMapWidget({
    super.key,
    required this.locationName,
    this.subAddress,
    this.latitude = 9.0083,
    this.longitude = 38.7831,
    this.districtLabel = 'BOLE DISTRICT',
    this.showWorkerRoute = false,
    this.isInteractive = false,
    this.onGpsPressed,
    this.onLocationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Stack(
        children: [
          // Background Grid & Roads Simulation
          CustomPaint(
            size: Size.infinite,
            painter: MapBackgroundPainter(showRoute: showWorkerRoute),
          ),

          // District Watermark
          Positioned(
            left: 16,
            top: 14,
            child: Text(
              districtLabel.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Color(0xFF94A3B8),
              ),
            ),
          ),

          // Action buttons at top right (Native Map Share & GPS)
          Positioned(
            right: 12,
            top: 12,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    LocationService.shareNativeLocation(
                      latitude: latitude,
                      longitude: longitude,
                      label: locationName,
                      context: context,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.share_location_rounded, size: 14, color: AppTheme.primaryTeal),
                        SizedBox(width: 4),
                        Text(
                          'Share Map',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryTeal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (isInteractive && onGpsPressed != null) ...[
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: onGpsPressed,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTeal,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryTeal.withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.my_location_rounded, size: 14, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'GPS',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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

          // Worker En Route Pin
          if (showWorkerRoute)
            Positioned(
              left: 45,
              top: 45,
              child: Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2563EB),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.navigation_rounded, size: 18, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: const Text(
                      'Worker En Route',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D4ED8),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Target Location Pin (Center-right)
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTeal,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryTeal.withValues(alpha: 0.4),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    locationName,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryTeal,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Coordinates & Address Bar at bottom
          Positioned(
            left: 10,
            right: 10,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryTeal,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      subAddress ?? locationName,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${latitude.toStringAsFixed(4)}° N, ${longitude.toStringAsFixed(4)}° E',
                    style: const TextStyle(
                      fontSize: 9,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MapBackgroundPainter extends CustomPainter {
  final bool showRoute;

  MapBackgroundPainter({this.showRoute = false});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1.0;

    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 16.0
      ..strokeCap = StrokeCap.round;

    final secondaryRoadPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 6.0;

    // Draw Grid Lines
    for (double i = 0; i < size.width; i += 30) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double i = 0; i < size.height; i += 30) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }

    // Draw Major simulated roads
    final mainRoad = Path()
      ..moveTo(0, size.height * 0.7)
      ..quadraticBezierTo(size.width * 0.4, size.height * 0.6, size.width, size.height * 0.3);
    canvas.drawPath(mainRoad, roadPaint);

    final crossRoad = Path()
      ..moveTo(size.width * 0.3, 0)
      ..quadraticBezierTo(size.width * 0.35, size.height * 0.5, size.width * 0.5, size.height);
    canvas.drawPath(crossRoad, secondaryRoadPaint);

    // If route requested, draw route line
    if (showRoute) {
      final routePaint = Paint()
        ..color = const Color(0xFF3B82F6)
        ..strokeWidth = 3.5
        ..style = PaintingStyle.stroke;

      final routePath = Path()
        ..moveTo(60, 60)
        ..lineTo(size.width * 0.35, size.height * 0.45)
        ..lineTo(size.width * 0.5, size.height * 0.45);

      canvas.drawPath(routePath, routePaint);
    }
  }

  @override
  bool shouldRepaint(covariant MapBackgroundPainter oldDelegate) {
    return oldDelegate.showRoute != showRoute;
  }
}
