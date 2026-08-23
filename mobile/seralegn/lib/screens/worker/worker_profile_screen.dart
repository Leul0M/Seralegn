import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../providers/language_provider.dart';
import '../../services/hive_service.dart';
import '../../theme/app_theme.dart';
import 'worker_subscription_screen.dart';

class WorkerProfileScreen extends StatelessWidget {
  final VoidCallback onSwitchRole;
  final VoidCallback onLogout;

  const WorkerProfileScreen({
    super.key,
    required this.onSwitchRole,
    required this.onLogout,
  });

  String _getInitials(String name) {
    final clean = name.trim();
    if (clean.isEmpty) return 'W';
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
            const Icon(
              Icons.logout_rounded,
              color: Color(0xFFEF4444),
              size: 24,
            ),
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
            child: Text(
              lang.cancel,
              style: const TextStyle(color: AppTheme.secondaryText),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              onLogout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
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
        : 'Worker Profile';
    final phone = (userData['phoneNumber'] as String? ?? '').isNotEmpty
        ? userData['phoneNumber'] as String
        : '+251 900 000 000';
    final neighborhood = (userData['neighborhood'] as String? ?? '').isNotEmpty
        ? userData['neighborhood'] as String
        : 'Addis Ababa';
    final faydaNumber = (userData['faydaNumber'] as String? ?? '');
    final isFaydaVerified = (userData['isFaydaVerified'] as bool? ?? false);
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

              // Profile Overview Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.inputBorder),
                ),
                child: Column(
                  children: [
                    Row(
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
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEEF2FF),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'PRO WORKER',
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
                                'Preferred Area: $neighborhood',
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
                    const SizedBox(height: 14),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    const SizedBox(height: 12),

                    // Fayda Verification Badge Box
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isFaydaVerified ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isFaydaVerified ? const Color(0xFFA7F3D0) : const Color(0xFFFDE68A)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isFaydaVerified ? Icons.verified_user_rounded : Icons.pending_outlined,
                            color: isFaydaVerified ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isFaydaVerified ? 'Fayda Digital Identity Verified' : 'Fayda Verification Pending',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isFaydaVerified ? const Color(0xFF065F46) : const Color(0xFF92400E),
                                  ),
                                ),
                                Text(
                                  faydaNumber.isNotEmpty
                                      ? 'ID: $faydaNumber • ${isFaydaVerified ? "Verified PRO" : "Pending Review"}'
                                      : 'Fayda ID verified',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isFaydaVerified ? const Color(0xFF047857) : const Color(0xFFB45309),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Earnings & Performance Stats
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.inputBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat('42', 'Jobs Done'),
                    Container(
                      height: 30,
                      width: 1,
                      color: AppTheme.inputBorder,
                    ),
                    _buildStat('4.9 ★', 'Rating'),
                    Container(
                      height: 30,
                      width: 1,
                      color: AppTheme.inputBorder,
                    ),
                    _buildStat('38,500', 'Total ETB'),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Skills & Categories
              const Text(
                'VERIFIED SKILLS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: AppTheme.secondaryText,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildSkillChip('Electrical (የኤሌክትሪክ ሥራ)'),
                  _buildSkillChip('Plumbing (የቧንቧ ሥራ)'),
                  _buildSkillChip('Home Repairs'),
                ],
              ),

              const SizedBox(height: 24),

              // Settings Options
              const Text(
                'WORKER SETTINGS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: AppTheme.secondaryText,
                ),
              ),
              const SizedBox(height: 10),

              // Language Switcher Tile
              _buildOptionTile(
                icon: Icons.language_rounded,
                title: lang.languageTitle,
                subtitle: lang.isAmharic
                    ? 'አሁናዊ ቋንቋ: አማርኛ'
                    : 'Current Language: English',
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryTeal.withValues(alpha: 0.3),
                    ),
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
                title: 'Switch Role ( client mode )',
                subtitle: 'Switch to Client Portal view',
                onTap: onSwitchRole,
              ),

              _buildOptionTile(
                icon: Icons.credit_card_outlined,
                title: 'Subscription & Pro Status',
                subtitle: 'Manage daily plan (15 ETB/day) & telebirr status',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WorkerSubscriptionScreen(),
                    ),
                  );
                },
              ),
              _buildOptionTile(
                icon: Icons.notifications_outlined,
                title: 'Job Alerts & SMS',
                subtitle: 'Push notifications for instant leads',
                onTap: () {},
              ),
              _buildOptionTile(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Payout Account Settings',
                subtitle: 'Telebirr / CBE Birr bank account',
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.logout_rounded, size: 20),
                label: Text(
                  lang.logout,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    ));
  }

  Widget _buildSkillChip(String skill) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC7D2FE)),
      ),
      child: Text(
        skill,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryTeal,
        ),
      ),
    );
  }

  Widget _buildStat(String val, String label) {
    return Column(
      children: [
        Text(
          val,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppTheme.primaryTeal,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppTheme.secondaryText),
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
        trailing:
            trailing ??
            const Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.lightText,
              size: 20,
            ),
        onTap: onTap,
      ),
    );
  }
}
