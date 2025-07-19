import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/extensions.dart';
import '../providers/auth_provider.dart';
import '../providers/biometric_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _maybeAuthenticate();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _maybeAuthenticate() async {
    final authState = ref.read(authStateProvider);
    final biometricState = ref.read(biometricStateProvider);
    if (authState.status == AuthStatus.authenticated &&
        authState.isBiometricEnabled) {
      final result = await ref
          .read(authStateProvider.notifier)
          .authenticateWithBiometric();
      result.fold(
        (failure) {
          // If authentication fails, log out or restrict access
          // Here, we log out
          _signOut(context, ref);
        },
        (isAuthenticated) {
          if (!isAuthenticated) {
            _signOut(context, ref);
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final biometricState = ref.watch(biometricStateProvider);
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(AppConstants.appName),
        backgroundColor: colorScheme.background,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar and Welcome
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD166),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.person,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppConstants.loginWelcomeBack,
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        authState.user?.email ?? '',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Biometric toggle card
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            AppConstants.biometricNotAvailableMessage
                                .replaceFirst(
                                  'not available',
                                  'Enable Biometric Authentication',
                                ),
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        Switch(
                          value: biometricState.isEnabled,
                          onChanged: (value) {
                            ref
                                .read(biometricStateProvider.notifier)
                                .setEnabled(value);
                          },
                          activeColor: colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Change PIN UI and references removed
                const SizedBox(height: 32),

                // Logout button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _signOut(context, ref),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF476F),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      AppConstants.loginButtonSignIn.replaceFirst(
                        'Login',
                        'Logout',
                      ),
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isEnabled,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: isEnabled
              ? Colors.green
              : context.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colorScheme.onSurface,
                ),
              ),
              Text(
                subtitle,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Icon(
          isEnabled ? Icons.check_circle : Icons.circle_outlined,
          color: isEnabled
              ? Colors.green
              : context.colorScheme.onSurfaceVariant,
        ),
      ],
    );
  }

  void _showSettings(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.pin),
              title: const Text('Change PIN'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to PIN change page
              },
            ),
            ListTile(
              leading: const Icon(Icons.fingerprint),
              title: const Text('Biometric Settings'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to biometric settings
              },
            ),
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Security Settings'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to security settings
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colorScheme.error,
              foregroundColor: context.colorScheme.onError,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Removed or updated call to signOut on AuthNotifier
    }
  }
}
