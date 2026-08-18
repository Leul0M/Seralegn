import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/services/supabase_service.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/database_repository.dart';
import 'ui/core/theme.dart';
import 'ui/features/auth/phone_login_screen.dart';
import 'ui/features/auth/role_selection_screen.dart';
import 'ui/features/home_owner/home_owner_dashboard.dart';
import 'ui/features/worker/worker_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase (detects if keys are empty and falls back to mock mode)
  await SupabaseService.instance.initialize();
  
  runApp(const SeralgnApp());
}

class SeralgnApp extends StatelessWidget {
  const SeralgnApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isMock = SupabaseService.instance.mockMode;

    return MultiProvider(
      providers: [
        // Register Auth Repository (either Mock or Supabase)
        ChangeNotifierProvider<AuthRepository>(
          create: (_) => isMock ? MockAuthRepository() : SupabaseAuthRepository(),
        ),
        // Register Database Repository (either Mock or Supabase)
        Provider<DatabaseRepository>(
          create: (_) => isMock ? MockDatabaseRepository() : SupabaseDatabaseRepository(),
        ),
      ],
      child: MaterialApp(
        title: 'ስራልኝ (Seralgn)',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const AuthRoleGate(),
      ),
    );
  }
}

class AuthRoleGate extends StatelessWidget {
  const AuthRoleGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthRepository>(
      builder: (context, authRepo, _) {
        // 1. Loading State
        if (authRepo.isLoading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Configuring profile secure session...',
                    style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black54),
                  ),
                ],
              ),
            ),
          );
        }

        // 2. Auth Gate: Check if user is authenticated
        final userId = authRepo.currentUserId;
        if (userId == null) {
          return const PhoneLoginScreen();
        }

        // 3. Role Gate: Check if user has registered their profile role
        if (!authRepo.hasProfile) {
          return const RoleSelectionScreen();
        }

        // 4. Role Routing: Route to HomeOwner or Worker dashboard
        if (authRepo.currentRole == UserRole.homeOwner) {
          return const HomeOwnerDashboard();
        } else if (authRepo.currentRole == UserRole.worker) {
          return const WorkerDashboard();
        }

        // Fallback for role mismatch (failsafe to onboarding)
        return const RoleSelectionScreen();
      },
    );
  }
}
