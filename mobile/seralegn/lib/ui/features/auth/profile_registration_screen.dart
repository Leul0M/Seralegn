import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/repositories/auth_repository.dart';
import '../client/client_dashboard.dart';
import '../worker/worker_dashboard.dart';

class ProfileRegistrationScreen extends StatefulWidget {
  final UserRole role;

  const ProfileRegistrationScreen({super.key, required this.role});

  @override
  State<ProfileRegistrationScreen> createState() =>
      _ProfileRegistrationScreenState();
}

class _ProfileRegistrationScreenState extends State<ProfileRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _faydaController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _faydaController.dispose();
    super.dispose();
  }

  void _submitProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final authRepo = Provider.of<AuthRepository>(context, listen: false);

    try {
      if (widget.role == UserRole.client) {
        await authRepo.registerClient(_nameController.text.trim());
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const ClientDashboard()),
            (route) => false,
          );
        }
      } else {
        await authRepo.registerWorker(
          _nameController.text.trim(),
          _faydaController.text.trim(),
        );
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const WorkerDashboard()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isClient = widget.role == UserRole.client;

    return Scaffold(
      appBar: AppBar(
        title: Text(isClient ? 'Client Profile' : 'Worker Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Complete Registration',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isClient
                        ? 'Register as a client to post repair tasks and find service providers.'
                        : 'Register as a worker to find nearby gigs and start earning.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Name Field
                  TextFormField(
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      hintText: 'Enter your first and last name',
                      prefixIcon: Icon(Icons.person_rounded),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your full name';
                      }
                      if (value.trim().split(' ').length < 2) {
                        return 'Please enter both your first and last name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  // Fayda Number Field (Workers only)
                  if (!isClient) ...[
                    TextFormField(
                      controller: _faydaController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: 'Fayda Number (National ID)',
                        hintText: 'ET-123456789',
                        prefixIcon: Icon(Icons.badge_rounded),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your Fayda National ID number';
                        }
                        if (value.trim().length < 8) {
                          return 'Please enter a valid Fayda ID number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your National ID (Fayda) is required to verify your worker profile and ensure client safety.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitProfile,
                    style: isClient
                        ? null
                        : ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.secondary,
                            shadowColor: theme.colorScheme.secondary.withValues(
                              alpha: 0.3,
                            ),
                          ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            isClient
                                ? 'Create Client Account'
                                : 'Create Worker Account',
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
