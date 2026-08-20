import 'package:flutter/material.dart';
import '../models/onboarding_data.dart';
import '../models/user_role.dart';
import '../theme/app_theme.dart';

class CompletionScreen extends StatelessWidget {
  final OnboardingData onboardingData;
  final VoidCallback onRestart;

  const CompletionScreen({
    super.key,
    required this.onboardingData,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final role = onboardingData.role;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20.0),
          child: Column(
            children: [
              const Spacer(),

              // Badge Icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppTheme.lightTealBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.lightTealBorder, width: 2),
                ),
                child: Icon(
                  role == UserRole.client
                      ? Icons.check_circle_outline_rounded
                      : Icons.workspace_premium_rounded,
                  color: AppTheme.primaryTeal,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),

              // Title & Subtitle
              Text(
                role.completionTitle,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkText,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                role.completionSubtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.secondaryText,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // Stats Card
              Container(
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.inputBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      icon: role == UserRole.client
                          ? Icons.people_outline_rounded
                          : Icons.task_alt_rounded,
                      value: role.stat1Value,
                      label: role.stat1Label,
                    ),
                    Container(
                      height: 36,
                      width: 1,
                      color: AppTheme.inputBorder,
                    ),
                    _buildStatItem(
                      icon: role == UserRole.client
                          ? Icons.star_outline_rounded
                          : Icons.timer_outlined,
                      value: role.stat2Value,
                      label: role.stat2Label,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Primary Button
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Navigating to ${role.primaryCtaLabel}...'),
                      backgroundColor: AppTheme.primaryTeal,
                    ),
                  );
                },
                child: Text(role.primaryCtaLabel),
              ),
              const SizedBox(height: 12),

              // Secondary Button
              OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Navigating to ${role.secondaryCtaLabel}...'),
                    ),
                  );
                },
                child: Text(role.secondaryCtaLabel),
              ),
              const SizedBox(height: 16),

              // Switch Role / Reset Flow
              TextButton(
                onPressed: onRestart,
                child: const Text(
                  'Restart Onboarding / Change Role',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.secondaryText,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppTheme.primaryTeal),
            const SizedBox(width: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.darkText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.secondaryText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
