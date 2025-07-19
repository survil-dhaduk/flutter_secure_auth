import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/extensions.dart';
import '../providers/auth_provider.dart';
import '../providers/biometric_provider.dart';
import '../widgets/loading_overlay.dart';

class BiometricSetupPage extends ConsumerStatefulWidget {
  const BiometricSetupPage({super.key});

  @override
  ConsumerState<BiometricSetupPage> createState() => _BiometricSetupPageState();
}

class _BiometricSetupPageState extends ConsumerState<BiometricSetupPage> {
  @override
  void initState() {
    super.initState();
    ref.read(biometricStateProvider.notifier).checkBiometricAvailability();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final biometricState = ref.watch(biometricStateProvider);

    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (next.status == AuthStatus.error) {
        context.showSnackBar(
          next.errorMessage ?? 'An error occurred',
          isError: true,
        );
        ref.read(authStateProvider.notifier).clearError();
      }
    });

    return LoadingOverlay(
      isLoading: authState.status == AuthStatus.loading,
      message: 'Setting up biometric authentication...',
      child: Scaffold(
        backgroundColor: context.colorScheme.background,
        appBar: AppBar(
          title: const Text('Biometric Setup'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Header
                      Icon(
                        Icons.fingerprint,
                        size: 64,
                        color: context.colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Enable Biometric Authentication',
                        style: context.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Use your ${biometricState.biometricType.toLowerCase()} for quick and secure access',
                        style: context.textTheme.bodyLarge?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Status content
                      if (biometricState.status == BiometricStatus.checking)
                        const CircularProgressIndicator()
                      else if (biometricState.status ==
                          BiometricStatus.available)
                        _buildAvailableContent()
                      else if (biometricState.status ==
                          BiometricStatus.unavailable)
                        _buildUnavailableContent()
                      else if (biometricState.status == BiometricStatus.error)
                        _buildErrorContent()
                      else if (biometricState.status == BiometricStatus.success)
                        _buildSuccessContent(),
                    ],
                  ),
                ),

                // Action buttons
                if (biometricState.status == BiometricStatus.available)
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _enableBiometric,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.colorScheme.primary,
                            foregroundColor: context.colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppConstants.defaultRadius,
                              ),
                            ),
                          ),
                          child: Text(
                            'Enable ${biometricState.biometricType}',
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _skipBiometric,
                        child: Text(
                          'Skip for now',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvailableContent() {
    return Column(
      children: [
        Icon(Icons.check_circle_outline, size: 48, color: Colors.green),
        const SizedBox(height: 16),
        Text(
          'Biometric authentication is available',
          style: context.textTheme.titleMedium?.copyWith(color: Colors.green),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildUnavailableContent() {
    return Column(
      children: [
        Icon(Icons.error_outline, size: 48, color: context.colorScheme.error),
        const SizedBox(height: 16),
        Text(
          'Biometric authentication is not available on this device',
          style: context.textTheme.titleMedium?.copyWith(
            color: context.colorScheme.error,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildErrorContent() {
    final biometricState = ref.watch(biometricStateProvider);
    return Column(
      children: [
        Icon(Icons.error_outline, size: 48, color: context.colorScheme.error),
        const SizedBox(height: 16),
        Text(
          'Failed to check biometric availability',
          style: context.textTheme.titleMedium?.copyWith(
            color: context.colorScheme.error,
          ),
          textAlign: TextAlign.center,
        ),
        if (biometricState.errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            biometricState.errorMessage!,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildSuccessContent() {
    return Column(
      children: [
        Icon(Icons.check_circle, size: 48, color: Colors.green),
        const SizedBox(height: 16),
        Text(
          'Biometric authentication enabled!',
          style: context.textTheme.titleMedium?.copyWith(color: Colors.green),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Future<void> _enableBiometric() async {
    await ref.read(authStateProvider.notifier).enableBiometric();
    ref.read(biometricStateProvider.notifier).setEnabled(true);
  }

  void _skipBiometric() {
    // Navigate to home
    _proceedToHome();
  }

  void _proceedToHome() {
    // This will be handled by the router
    context.showSnackBar('Setup completed!');
  }
}
