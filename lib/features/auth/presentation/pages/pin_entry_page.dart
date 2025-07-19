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
    Future.delayed(Duration.zero, () {
      ref.read(pinStateProvider.notifier).startPinVerification();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final pinState = ref.watch(pinStateProvider);

    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (next.status == AuthStatus.error) {
        context.showSnackBar(
          next.errorMessage ?? AppConstants.loginErrorSnack,
          isError: true,
        );
        ref.read(authStateProvider.notifier).clearError();
      }
    });

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final pinLength = AppConstants.pinLength;
    final attemptsLeft = AppConstants.maxPinAttempts - (pinState.attempts);

    return LoadingOverlay(
      isLoading: authState.status == AuthStatus.loading,
      message: 'Verifying PIN...',
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F9FC),
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      color: const Color(0xFF1A1A1A),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Text(
                        AppConstants.appName,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 40), // To balance the row
                  ],
                ),
              ),
              // Main
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 24),
                        // Lock Icon in colored circle
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFF5D5FEF).withOpacity(0.1),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: const Color(0xFF5D5FEF).withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.lock_outline,
                                  size: 36,
                                  color: Color(0xFF5D5FEF),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Title
                        Text(
                          AppConstants.pinSetupEnterPin, // 'Enter your PIN'
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1A1A1A),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        // Subtitle
                        Text(
                          'Enter your $pinLength-digit PIN to continue.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        // PIN Dots
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(pinLength, (index) {
                            final isFilled =
                                (pinState.confirmPin.length > index);
                            return Container(
                              margin: EdgeInsets.symmetric(horizontal: 8),
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: isFilled
                                    ? const Color(0xFF5D5FEF)
                                    : Colors.grey[300],
                                shape: BoxShape.circle,
                              ),
                            );
                          }),
                        ),
                        // const SizedBox(height: 16),
                        // Attempts remaining
                        if (authState.status == AuthStatus.error &&
                            attemptsLeft > 0)
                          Text(
                            '$attemptsLeft attempts remaining',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFFEF476F),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        if (authState.status != AuthStatus.error ||
                            attemptsLeft <= 0)
                          const SizedBox(height: 20),
                        // const SizedBox(height: 24),
                        // PIN Input (hidden, but triggers onPinComplete)
                        PinInput(
                          title: '',
                          subtitle: '',
                          onPinComplete: () async {
                            await _verifyPin();
                          },
                          isVerification: true,
                        ),
                        const SizedBox(height: 16),
                        // Links
                        Column(
                          children: [
                            TextButton(
                              onPressed: () {
                                // TODO: Implement Forgot PIN
                              },
                              child: Text(
                                'Forgot PIN?',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xFF5D5FEF),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                // TODO: Implement Login with Email
                              },
                              child: Text(
                                'Login with Email',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xFF5D5FEF),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
              // Footer
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Container(
                    width: 134,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _verifyPin() async {
    final pinState = ref.read(pinStateProvider);

    await ref.read(pinStateProvider.notifier).submitPin();
    if (pinState.status == PinStatus.success) {
      if (pinState.isConfirmPinComplete) {
        await ref
            .read(authStateProvider.notifier)
            .verifyPin(pinState.confirmPin);
        ref.read(pinStateProvider.notifier).reset();
      }
    }
  }

  Future<void> _tryBiometric() async {
    await ref.read(authStateProvider.notifier).authenticateWithBiometric();
  }

  Future<void> _signOut() async {
    await ref.read(authStateProvider.notifier).signOut();
  }
}
