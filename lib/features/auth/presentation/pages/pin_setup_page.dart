import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_auth/core/router/app_router.dart';
import 'package:go_router/go_router.dart';
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
    Future.microtask(() {
      ref.read(pinStateProvider.notifier).startPinSetup();
    });
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

    final isVerifying = pinState.status == PinStatus.verifying;
    final isSetting = pinState.status == PinStatus.setting;
    final pinLength = AppConstants.pinLength;
    final enteredPin = pinState.pin;
    final confirmPin = pinState.confirmPin;
    final isContinueEnabled = isVerifying
        ? confirmPin.length == pinLength
        : enteredPin.length == pinLength;

    return LoadingOverlay(
      isLoading: authState.status == AuthStatus.loading,
      message: 'Setting up PIN...',
      child: Scaffold(
        backgroundColor: context.colorScheme.background,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      color: context.colorScheme.onSurface,
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    Expanded(
                      child: Text(
                        AppConstants.pinSetupTitle,
                        textAlign: TextAlign.center,
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // To balance the back button
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          AppConstants.pinSetupHeader,
                          style: context.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppConstants.pinSetupDesc,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        // PIN Entry
                        _PinEntrySection(
                          label: AppConstants.pinSetupEnterPin,
                          pin: enteredPin,
                          pinLength: pinLength,
                          isActive: isSetting,
                        ),
                        const SizedBox(height: 16),
                        // PIN Confirm
                        _PinEntrySection(
                          label: AppConstants.pinSetupConfirmPin,
                          pin: confirmPin,
                          pinLength: pinLength,
                          isActive: isVerifying,
                        ),
                        const SizedBox(height: 32),
                        // Keypad
                        _PinKeypad(
                          onPressed: (val) {
                            ref.read(pinStateProvider.notifier).addDigit(val);
                          },
                          onBackspace: () {
                            ref.read(pinStateProvider.notifier).removeDigit();
                          },
                          isEnabled: authState.status != AuthStatus.loading,
                        ),
                        const SizedBox(height: 32),
                        // Continue Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: isContinueEnabled
                                ? () async {
                                    ref
                                        .read(pinStateProvider.notifier)
                                        .submitPin();
                                    if (pinState.status == PinStatus.success) {
                                      await _savePin();
                                    }
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              textStyle: context.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            child: Text(AppConstants.pinSetupContinue),
                          ),
                        ),
                        // if (isSetting)
                        //   TextButton(
                        //     onPressed: () => _skipPinSetup,
                        //     child: Text(
                        //       AppConstants.pinSetupSkip,
                        //       style: context.textTheme.bodyMedium?.copyWith(
                        //         color: context.colorScheme.primary,
                        //       ),
                        //     ),
                        //   ),
                        const SizedBox(height: 16),
                      ],
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
    GoRouter.of(context).go(homeRoute);
  }

  void _proceedToNext() {
    context.showSnackBar('PIN setup completed!');
    ref.read(authStateProvider).copyWith(isPinSet: true);
  }
}

class _PinEntrySection extends StatelessWidget {
  final String label;
  final String pin;
  final int pinLength;
  final bool isActive;

  const _PinEntrySection({
    required this.label,
    required this.pin,
    required this.pinLength,
    required this.isActive,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(pinLength, (index) {
            final filled = index < pin.length;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: filled
                    ? context.colorScheme.primary
                    : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _PinKeypad extends StatelessWidget {
  final void Function(String) onPressed;
  final VoidCallback onBackspace;
  final bool isEnabled;

  const _PinKeypad({
    required this.onPressed,
    required this.onBackspace,
    required this.isEnabled,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'back'],
    ];
    return Column(
      children: keys.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: row.map((key) {
            if (key == '') {
              return const SizedBox(width: 72, height: 72);
            } else if (key == 'back') {
              return IconButton(
                icon: const Icon(Icons.backspace_outlined, size: 32),
                onPressed: isEnabled ? onBackspace : null,
                color: context.colorScheme.onSurface,
                iconSize: 48,
                padding: const EdgeInsets.all(0),
                constraints: const BoxConstraints(minWidth: 72, minHeight: 72),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: ElevatedButton(
                    onPressed: isEnabled ? () => onPressed(key) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: context.colorScheme.onSurface,
                      shape: const CircleBorder(),
                      elevation: 0,
                      textStyle: context.textTheme.titleLarge,
                    ),
                    child: Text(key, style: const TextStyle(fontSize: 24)),
                  ),
                ),
              );
            }
          }).toList(),
        );
      }).toList(),
    );
  }
}
