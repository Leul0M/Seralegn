import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/onboarding_data.dart';
import 'models/user_role.dart';
import 'providers/language_provider.dart';
import 'screens/account_creation_screen.dart';
import 'screens/category_selection_screen.dart';
import 'screens/client/client_main_screen.dart';
import 'screens/completion_screen.dart';
import 'screens/journey_selection_screen.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/worker/worker_main_screen.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (_) {
    // Gracefully handle if .env file is missing in test environments
  }

  // Register LanguageController for app-wide access via Get.find()
  Get.put(LanguageController());

  final supabaseUrl = dotenv.env['SUPABASE_URL'] ??
      const String.fromEnvironment('SUPABASE_URL');
  final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'] ??
      const String.fromEnvironment('SUPABASE_ANON_KEY');

  // Initialize Supabase Client dynamically from environment variables
  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabaseKey,
  );

  runApp(const SeralegnApp());
}

class SeralegnApp extends StatelessWidget {
  const SeralegnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
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

  Future<void> _handleSplashNext() async {
    final restoredRole = await AuthService.instance.restoreSession();
    if (!mounted) return;

    if (restoredRole != null) {
      setState(() {
        _onboardingData.role = restoredRole;
        _currentPageIndex = 6; // Route directly to Main App screen
      });
    } else {
      _goToPage(1); // Route to Welcome Screen
    }
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

  Future<void> _logout() async {
    await AuthService.instance.logout();
    if (!mounted) return;
    setState(() {
      _onboardingData.resetForRole(UserRole.client);
      _currentPageIndex = 1; // Return to Welcome Screen
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
          onNext: _handleSplashNext,
        );
      case 1:
        return WelcomeScreen(
          key: const ValueKey('welcome'),
          onGetStarted: () => _goToPage(2),
          onLogin: () => _goToPage(7),
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
            onLogout: _logout,
          );
        } else {
          return WorkerMainScreen(
            key: const ValueKey('worker_main'),
            onSwitchRole: _switchRoleFromMainApp,
            onLogout: _logout,
          );
        }
      case 7:
        return LoginScreen(
          key: const ValueKey('login'),
          onBack: () => _goToPage(1),
          onGoToSignUp: () => _goToPage(2),
          onLoginSuccess: (role) {
            setState(() {
              _onboardingData.role = role;
              _currentPageIndex = 6;
            });
          },
        );
      default:
        return WelcomeScreen(
          key: const ValueKey('default'),
          onGetStarted: () => _goToPage(2),
          onLogin: () => _goToPage(7),
        );
    }
  }
}
