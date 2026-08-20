import 'package:flutter/material.dart';
import 'models/onboarding_data.dart';
import 'models/user_role.dart';
import 'screens/account_creation_screen.dart';
import 'screens/category_selection_screen.dart';
import 'screens/client/client_main_screen.dart';
import 'screens/completion_screen.dart';
import 'screens/journey_selection_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/worker/worker_main_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const SeralegnApp());
}

class SeralegnApp extends StatelessWidget {
  const SeralegnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Seralegn',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const MainAppFlow(),
    );
  }
}

class MainAppFlow extends StatefulWidget {
  const MainAppFlow({super.key});

  @override
  State<MainAppFlow> createState() => _MainAppFlowState();
}

class _MainAppFlowState extends State<MainAppFlow> {
  int _currentPageIndex = 0;
  late OnboardingData _onboardingData;

  @override
  void initState() {
    super.initState();
    _onboardingData = OnboardingData(role: UserRole.client);
    _onboardingData.resetForRole(UserRole.client);
  }

  void _goToPage(int pageIndex) {
    setState(() {
      _currentPageIndex = pageIndex;
    });
  }

  void _onRoleSelected(UserRole role) {
    setState(() {
      _onboardingData.resetForRole(role);
    });
  }

  void _restartOnboarding() {
    setState(() {
      _onboardingData.resetForRole(UserRole.client);
      _currentPageIndex = 2; // Return to Journey Selection
    });
  }

  void _switchRoleFromMainApp() {
    setState(() {
      final newRole = _onboardingData.role == UserRole.client
          ? UserRole.worker
          : UserRole.client;
      _onboardingData.resetForRole(newRole);
      _currentPageIndex = 6; // Stay in main app view with toggled role
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _buildCurrentScreen(),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentPageIndex) {
      case 0:
        return SplashScreen(
          key: const ValueKey('splash'),
          onNext: () => _goToPage(1),
        );
      case 1:
        return WelcomeScreen(
          key: const ValueKey('welcome'),
          onGetStarted: () => _goToPage(2),
        );
      case 2:
        return JourneySelectionScreen(
          key: const ValueKey('journey'),
          selectedRole: _onboardingData.role,
          onRoleChanged: _onRoleSelected,
          onContinue: () => _goToPage(3),
        );
      case 3:
        return AccountCreationScreen(
          key: ValueKey('account_${_onboardingData.role}'),
          onboardingData: _onboardingData,
          onBack: () => _goToPage(2),
          onNext: () => _goToPage(4),
        );
      case 4:
        return CategorySelectionScreen(
          key: ValueKey('category_${_onboardingData.role}'),
          onboardingData: _onboardingData,
          onBack: () => _goToPage(3),
          onNext: () => _goToPage(5),
        );
      case 5:
        return CompletionScreen(
          key: ValueKey('completion_${_onboardingData.role}'),
          onboardingData: _onboardingData,
          onRestart: _restartOnboarding,
          onFinishOnboarding: () => _goToPage(6),
        );
      case 6:
        if (_onboardingData.role == UserRole.client) {
          return ClientMainScreen(
            key: const ValueKey('client_main'),
            onSwitchRole: _switchRoleFromMainApp,
          );
        } else {
          return WorkerMainScreen(
            key: const ValueKey('worker_main'),
            onSwitchRole: _switchRoleFromMainApp,
          );
        }
      default:
        return WelcomeScreen(
          key: const ValueKey('default'),
          onGetStarted: () => _goToPage(2),
        );
    }
  }
}
