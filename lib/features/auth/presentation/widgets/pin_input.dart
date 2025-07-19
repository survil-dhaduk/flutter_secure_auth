import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/extensions.dart';
import '../providers/pin_provider.dart';

class PinInput extends ConsumerWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onPinComplete;
  final bool isVerification;

  const PinInput({
    super.key,
    required this.title,
    required this.subtitle,
    this.onPinComplete,
    this.isVerification = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pinState = ref.watch(pinStateProvider);

    return Column(
      children: [
        // Text(
        //   title,
        //   style: context.textTheme.headlineSmall?.copyWith(
        //     fontWeight: FontWeight.bold,
        //     color: context.colorScheme.onSurface,
        //   ),
        //   textAlign: TextAlign.center,
        // ),
        // const SizedBox(height: 8),
        // Text(
        //   subtitle,
        //   style: context.textTheme.bodyMedium?.copyWith(
        //     color: context.colorScheme.onSurfaceVariant,
        //   ),
        //   textAlign: TextAlign.center,
        // ),
        // const SizedBox(height: 32),

        // // PIN dots
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: List.generate(
        //     AppConstants.pinLength,
        //     (index) => Container(
        //       margin: const EdgeInsets.symmetric(horizontal: 8),
        //       width: 20,
        //       height: 20,
        //       decoration: BoxDecoration(
        //         shape: BoxShape.circle,
        //         color:
        //             index <
        //                 (isVerification
        //                     ? pinState.confirmPin.length
        //                     : pinState.pin.length)
        //             ? context.colorScheme.primary
        //             : context.colorScheme.outline,
        //       ),
        //     ),
        //   ),
        // ),
        if (pinState.errorMessage != null) ...[
          const SizedBox(height: 16),
          Text(
            pinState.errorMessage!,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
        ],

        // const SizedBox(height: 32),

        // Number pad
        Column(
          children: [
            for (int row = 0; row < 3; row++)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int col = 1; col <= 3; col++)
                    _buildNumberButton(
                      context,
                      ref,
                      (row * 3 + col).toString(),
                    ),
                ],
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildNumberButton(context, ref, '0'),
                _buildActionButton(
                  context,
                  ref,
                  Icons.backspace,
                  () => ref.read(pinStateProvider.notifier).removeDigit(),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Submit button
        if (isVerification && pinState.isConfirmPinComplete)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPinComplete,
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
                'Verify PIN',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colorScheme.onPrimary,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNumberButton(
    BuildContext context,
    WidgetRef ref,
    String number,
  ) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: SizedBox(
        width: 80,
        height: 80,
        child: ElevatedButton(
          onPressed: () {
            ref.read(pinStateProvider.notifier).addDigit(number);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: context.colorScheme.surface,
            foregroundColor: context.colorScheme.onSurface,
            elevation: 2,
            shape: const CircleBorder(),
          ),
          child: Text(
            number,
            style: context.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    WidgetRef ref,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: SizedBox(
        width: 80,
        height: 80,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: context.colorScheme.surface,
            foregroundColor: context.colorScheme.onSurface,
            elevation: 2,
            shape: const CircleBorder(),
          ),
          child: Icon(icon, size: 28),
        ),
      ),
    );
  }
}
