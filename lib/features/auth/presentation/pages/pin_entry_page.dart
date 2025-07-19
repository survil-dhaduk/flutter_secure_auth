import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/extensions.dart';
import '../providers/auth_provider.dart';
import '../providers/pin_provider.dart';
import '../widgets/pin_input.dart';
import '../widgets/loading_overlay.dart';

class PinEntryPage extends ConsumerStatefulWidget {
  const PinEntryPage({super.key});

  @override
  ConsumerState<PinEntryPage> createState() => _PinEntryPageState();
}

class _PinEntryPageState extends ConsumerState<PinEntryPage> {
  @override
  void initState() {
    super.initState();
    ref.read(pinStateProvider.notifier).startPinVerification();
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
      message: 'Verifying PIN...',
      child: Scaffold(
        backgroundColor: context.colorScheme.background,
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
                        Icons.lock_outline,
                        size: 64,
                        color: context.colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Enter Your PIN',
                        style: context.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter your ${AppConstants.pinLength}-digit PIN to continue',
                        style: context.textTheme.bodyLarge?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // PIN Input
                      PinInput(
                        title: 'PIN',
                        subtitle:
                            'Enter your ${AppConstants.pinLength}-digit PIN',
                        onPinComplete: () async {
                          await _verifyPin();
                        },
                        isVerification: true,
                      ),
                    ],
                  ),
                ),

                // Alternative options
                Column(
                  children: [
                    TextButton(
                      onPressed: () {
                        // Try biometric authentication
                        _tryBiometric();
                      },
                      child: Text(
                        'Use Biometric',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.primary,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Sign out and go back to login
                        _signOut();
                      },
                      child: Text(
                        'Sign Out',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.error,
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

  Future<void> _verifyPin() async {
    final pinState = ref.read(pinStateProvider);
    if (pinState.isConfirmPinComplete) {
      await ref.read(authStateProvider.notifier).verifyPin(pinState.confirmPin);
      ref.read(pinStateProvider.notifier).reset();
    }
  }

  Future<void> _tryBiometric() async {
    await ref.read(authStateProvider.notifier).authenticateWithBiometric();
  }

  Future<void> _signOut() async {
    await ref.read(authStateProvider.notifier).signOut();
  }
}
