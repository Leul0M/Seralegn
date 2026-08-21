import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onGetStarted;
  final VoidCallback? onLogin;

  const WelcomeScreen({
    super.key,
    required this.onGetStarted,
    this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20.0),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Logo
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.handyman_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Seralegn',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkText,
                  letterSpacing: -0.5,
                ),
              ),

              const Spacer(),

              // Headline & description
              const Text(
                'Get things done, together',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.darkText,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Connect with verified service providers in Addis Ababa. Quick, secure, and hassle-free tasks.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.secondaryText,
                  height: 1.5,
                ),
              ),

              const Spacer(flex: 2),

              // Buttons
              ElevatedButton(
                onPressed: onGetStarted,
                child: const Text('Create Account'),
              ),
              if (onLogin != null) ...[
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: onLogin,
                  child: const Text('I already have an account / Log In'),
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
