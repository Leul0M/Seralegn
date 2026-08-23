import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../providers/language_provider.dart';
import '../../services/hive_service.dart';
import '../../theme/app_theme.dart';

class ClientProfileScreen extends StatelessWidget {
  final VoidCallback onSwitchRole;
  final VoidCallback onLogout;

  const ClientProfileScreen({
    super.key,
    required this.onSwitchRole,
    required this.onLogout,
  });

  String _getInitials(String name) {
    final clean = name.trim();
    if (clean.isEmpty) return 'C';
    final parts = clean.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  void _confirmLogout(BuildContext context, LanguageController lang) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 24),
            const SizedBox(width: 10),
            Text(
              lang.logout,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          lang.confirmLogout,
          style: const TextStyle(fontSize: 13, color: AppTheme.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(lang.cancel, style: const TextStyle(color: AppTheme.secondaryText)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              onLogout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(lang.logout),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = Get.find<LanguageController>();

    final userData = HiveService.instance.getUserData();
    final name = (userData['fullName'] as String? ?? '').isNotEmpty
        ? userData['fullName'] as String
        : 'Client Profile';
    final phone = (userData['phoneNumber'] as String? ?? '').isNotEmpty
        ? userData['phoneNumber'] as String
        : '+251 900 000 000';
    final neighborhood = (userData['neighborhood'] as String? ?? '').isNotEmpty
        ? userData['neighborhood'] as String
        : 'Addis Ababa';
    final profilePhotoBase64 = (userData['profilePhoto'] as String? ?? '');

    Uint8List? photoBytes;
    if (profilePhotoBase64.isNotEmpty) {
      try {
        photoBytes = base64Decode(profilePhotoBase64);
      } catch (_) {}
    }

    return Obx(() => Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lang.profileTab,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkText,
                ),
              ),
              const SizedBox(height: 16),

              // Profile Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.inputBorder),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: const Color(0xFFEEF2FF),
                      backgroundImage: photoBytes != null ? MemoryImage(photoBytes) : null,
                      child: photoBytes == null
                          ? Text(
                              _getInitials(name),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryTeal,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.darkText,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEEF2FF),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'CLIENT',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryTeal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            phone,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.secondaryText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Location: $neighborhood',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Stats Row
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.inputBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat('6', 'Total Jobs'),
                    Container(height: 30, width: 1, color: AppTheme.inputBorder),
                    _buildStat('4.9 ★', 'Client Rating'),
                    Container(height: 30, width: 1, color: AppTheme.inputBorder),
                    _buildStat('100%', 'Payment Rate'),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Settings Options
              const Text(
                'ACCOUNT SETTINGS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: AppTheme.secondaryText,
                ),
              ),
              const SizedBox(height: 10),

              // Language Change Button (English & Amharic)
              _buildOptionTile(
                icon: Icons.language_rounded,
                title: lang.languageTitle,
                subtitle: lang.isAmharic ? 'አሁናዊ ቋንቋ: አማርኛ' : 'Current Language: English',
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    lang.isAmharic ? 'EN ➔ አማ' : 'አማ ➔ EN',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryTeal,
                    ),
                  ),
                ),
                onTap: () => lang.toggleLanguage(),
              ),

              _buildOptionTile(
                icon: Icons.published_with_changes_rounded,
                title: 'Switch Role ( worker mode )',
                subtitle: 'Switch to Worker Portal view',
                onTap: onSwitchRole,
              ),

              _buildOptionTile(
                icon: Icons.location_on_outlined,
                title: 'Saved Locations',
                subtitle: 'Manage home & office addresses',
                onTap: () {},
              ),

              _buildOptionTile(
                icon: Icons.verified_user_outlined,
                title: 'Identity Verification',
                subtitle: 'Fayda ID verified',
                trailing: const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 18),
                onTap: () {},
              ),

              _buildOptionTile(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'Push & SMS job alerts',
                onTap: () {},
              ),

              const SizedBox(height: 20),

              // Log Out Button
              ElevatedButton.icon(
                onPressed: () => _confirmLogout(context, lang),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFEF2F2),
                  foregroundColor: const Color(0xFFEF4444),
                  elevation: 0,
                  side: const BorderSide(color: Color(0xFFFCA5A5)),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.logout_rounded, size: 20),
                label: Text(
                  lang.logout,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    ));
  }

  Widget _buildStat(String val, String label) {
    return Column(
      children: [
        Text(
          val,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryTeal,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.secondaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.primaryTeal, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.darkText,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 11, color: AppTheme.secondaryText),
        ),
        trailing: trailing ??
            const Icon(Icons.chevron_right_rounded, color: AppTheme.lightText, size: 20),
        onTap: onTap,
      ),
    );
  }
}
