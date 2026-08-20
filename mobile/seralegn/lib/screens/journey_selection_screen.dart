import 'package:flutter/material.dart';
import '../models/user_role.dart';
import '../theme/app_theme.dart';

class JourneySelectionScreen extends StatefulWidget {
  final UserRole selectedRole;
  final ValueChanged<UserRole> onRoleChanged;
  final VoidCallback onContinue;

  const JourneySelectionScreen({
    super.key,
    required this.selectedRole,
    required this.onRoleChanged,
    required this.onContinue,
  });

  @override
  State<JourneySelectionScreen> createState() => _JourneySelectionScreenState();
}

class _JourneySelectionScreenState extends State<JourneySelectionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Choose your journey',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkText,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'How will you use Seralegn? You can always change this in your profile settings later.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.secondaryText,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),

              // Client Card
              _buildRoleCard(
                role: UserRole.client,
                icon: Icons.person_outline_rounded,
                title: UserRole.client.title,
                badgeText: UserRole.client.badgeText,
                subtitle: UserRole.client.description,
              ),
              const SizedBox(height: 16),

              // Worker Card
              _buildRoleCard(
                role: UserRole.worker,
                icon: Icons.handyman_outlined,
                title: UserRole.worker.title,
                subtitle: UserRole.worker.description,
              ),

              const Spacer(),

              // Primary CTA Button
              ElevatedButton(
                onPressed: widget.onContinue,
                child: Text(
                  widget.selectedRole == UserRole.client
                      ? 'Continue as Client'
                      : 'Continue as Worker',
                ),
              ),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'By continuing, you agree to our Terms of Service.',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.lightText,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required UserRole role,
    required IconData icon,
    required String title,
    String? badgeText,
    required String subtitle,
  }) {
    final isSelected = widget.selectedRole == role;

    return InkWell(
      onTap: () => widget.onRoleChanged(role),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryTeal : AppTheme.inputBorder,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.lightTealBg : AppTheme.backgroundLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppTheme.primaryTeal : AppTheme.iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? AppTheme.primaryTeal : AppTheme.darkText,
                        ),
                      ),
                      if (badgeText != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.lightTealBg,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppTheme.lightTealBorder, width: 0.8),
                          ),
                          child: Text(
                            badgeText,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryTeal,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.secondaryText,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
