import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/constants/app_constants.dart';

enum PinStatus { initial, setting, verifying, success, error }

class PinState extends Equatable {
  final PinStatus status;
  final String pin;
  final String confirmPin;
  final String? errorMessage;
  final int attempts;

  const PinState({
    required this.status,
    this.pin = '',
    this.confirmPin = '',
    this.errorMessage,
    this.attempts = 0,
  });

  factory PinState.initial() {
    return const PinState(status: PinStatus.initial);
  }

  PinState copyWith({
    PinStatus? status,
    String? pin,
    String? confirmPin,
    String? errorMessage,
    int? attempts,
  }) {
    return PinState(
      status: status ?? this.status,
      pin: pin ?? this.pin,
      confirmPin: confirmPin ?? this.confirmPin,
      errorMessage: errorMessage,
      attempts: attempts ?? this.attempts,
    );
  }

  bool get isPinComplete => pin.length == AppConstants.pinLength;
  bool get isConfirmPinComplete => confirmPin.length == AppConstants.pinLength;
  bool get canSubmit => isPinComplete && isConfirmPinComplete;
  bool get doPinsMatch => pin == confirmPin;

  @override
  List<Object?> get props => [status, pin, confirmPin, errorMessage, attempts];
}

final pinStateProvider = StateNotifierProvider<PinNotifier, PinState>((ref) {
  return PinNotifier();
});

class PinNotifier extends StateNotifier<PinState> {
  PinNotifier() : super(PinState.initial());

  void addDigit(String digit) {
    if (state.status == PinStatus.setting) {
      if (state.pin.length < AppConstants.pinLength) {
        state = state.copyWith(pin: state.pin + digit, errorMessage: null);
      }
    } else if (state.status == PinStatus.verifying) {
      if (state.confirmPin.length < AppConstants.pinLength) {
        state = state.copyWith(
          confirmPin: state.confirmPin + digit,
          errorMessage: null,
        );
      }
    }
  }

  void removeDigit() {
    if (state.status == PinStatus.setting) {
      if (state.pin.isNotEmpty) {
        state = state.copyWith(
          pin: state.pin.substring(0, state.pin.length - 1),
          errorMessage: null,
        );
      }
    } else if (state.status == PinStatus.verifying) {
      if (state.confirmPin.isNotEmpty) {
        state = state.copyWith(
          confirmPin: state.confirmPin.substring(
            0,
            state.confirmPin.length - 1,
          ),
          errorMessage: null,
        );
      }
    }
  }

  void startPinSetup() {
    state = PinState.initial().copyWith(status: PinStatus.setting);
  }

  void startPinVerification() {
    state = PinState.initial().copyWith(status: PinStatus.verifying);
  }

  Future<void> submitPin() async {
    if (state.status == PinStatus.setting) {
      if (state.pin.length != AppConstants.pinLength) {
        state = state.copyWith(
          errorMessage: 'PIN must be  {AppConstants.pinLength} digits',
        );
        return;
      }

      // Move to confirmation, clear confirmPin
      state = state.copyWith(status: PinStatus.verifying, confirmPin: '');
    } else if (state.status == PinStatus.verifying) {
      if (state.confirmPin.length != AppConstants.pinLength) {
        state = state.copyWith(errorMessage: 'Please enter the complete PIN');
        return;
      }

      if (!state.doPinsMatch) {
        state = state.copyWith(
          errorMessage: AppConstants.pinMismatchMessage,
          confirmPin: '',
        );
        return;
      }

      state = state.copyWith(status: PinStatus.success);
    }
  }

  void setError(String error) {
    state = state.copyWith(status: PinStatus.error, errorMessage: error);
  }

  void clearError() {
    state = state.copyWith(status: PinStatus.initial, errorMessage: null);
  }

  void reset() {
    state = PinState.initial();
  }
}
