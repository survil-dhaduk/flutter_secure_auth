import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/extensions.dart';
import '../providers/auth_provider.dart';
import '../providers/pin_provider.dart';
import '../widgets/pin_input.dart';
import '../widgets/loading_overlay.dart';

class PinSetupPage extends ConsumerStatefulWidget {
  const PinSetupPage({super.key});

  @override
  ConsumerState<PinSetupPage> createState() => _PinSetupPageState();
}

class _PinSetupPageState extends ConsumerState<PinSetupPage> {
  @override
  void initState() {
    super.initState();
    ref.read(pinStateProvider.notifier).startPinSetup();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final pinState = ref.watch(pinStateProvider);

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
      message: 'Setting up PIN...',
      child: Scaffold(
        backgroundColor: context.colorScheme.background,
        appBar: AppBar(
          title: const Text('Set Up PIN'),
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
                        Icons.pin_outlined,
                        size: 64,
                        color: context.colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Set Up Your PIN',
                        style: context.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create a ${AppConstants.pinLength}-digit PIN to secure your account',
                        style: context.textTheme.bodyLarge?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // PIN Input
                      if (pinState.status == PinStatus.setting)
                        PinInput(
                          title: 'Enter PIN',
                          subtitle:
                              'Create a ${AppConstants.pinLength}-digit PIN',
                          onPinComplete: () {
                            ref.read(pinStateProvider.notifier).submitPin();
                          },
                        )
                      else if (pinState.status == PinStatus.verifying)
                        PinInput(
                          title: 'Confirm PIN',
                          subtitle: 'Re-enter your PIN to confirm',
                          onPinComplete: () async {
                            ref.read(pinStateProvider.notifier).submitPin();
                            if (pinState.status == PinStatus.success) {
                              await _savePin();
                            }
                          },
                          isVerification: true,
                        ),
                    ],
                  ),
                ),

                // Skip button
                if (pinState.status == PinStatus.setting)
                  TextButton(
                    onPressed: () {
                      // Navigate to biometric setup or home
                      _skipPinSetup();
                    },
                    child: Text(
                      'Skip for now',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.primary,
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

  Future<void> _savePin() async {
    final pinState = ref.read(pinStateProvider);
    if (pinState.status == PinStatus.success) {
      await ref.read(authStateProvider.notifier).setPin(pinState.pin);
      ref.read(pinStateProvider.notifier).reset();

      // Navigate to biometric setup or home
      _proceedToNext();
    }
  }

  void _skipPinSetup() {
    // Navigate to biometric setup or home
    _proceedToNext();
  }

  void _proceedToNext() {
    // This will be handled by the router based on auth state
    // For now, we'll just show a success message
    context.showSnackBar('PIN setup completed!');
  }
}
