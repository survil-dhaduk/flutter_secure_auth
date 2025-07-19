import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';
import 'package:local_auth/local_auth.dart';

enum BiometricStatus {
  initial,
  checking,
  available,
  unavailable,
  authenticating,
  success,
  error,
}

class BiometricState extends Equatable {
  final BiometricStatus status;
  final bool isAvailable;
  final bool isEnabled;
  final String? errorMessage;
  final List<BiometricType> availableBiometrics;

  const BiometricState({
    required this.status,
    this.isAvailable = false,
    this.isEnabled = false,
    this.errorMessage,
    this.availableBiometrics = const [],
  });

  factory BiometricState.initial() {
    return const BiometricState(status: BiometricStatus.initial);
  }

  BiometricState copyWith({
    BiometricStatus? status,
    bool? isAvailable,
    bool? isEnabled,
    String? errorMessage,
    List<BiometricType>? availableBiometrics,
  }) {
    return BiometricState(
      status: status ?? this.status,
      isAvailable: isAvailable ?? this.isAvailable,
      isEnabled: isEnabled ?? this.isEnabled,
      errorMessage: errorMessage,
      availableBiometrics: availableBiometrics ?? this.availableBiometrics,
    );
  }

  String get biometricType {
    if (availableBiometrics.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    } else if (availableBiometrics.contains(BiometricType.iris)) {
      return 'Iris';
    }
    return 'Biometric';
  }

  @override
  List<Object?> get props => [
    status,
    isAvailable,
    isEnabled,
    errorMessage,
    availableBiometrics,
  ];
}

final biometricStateProvider =
    StateNotifierProvider<BiometricNotifier, BiometricState>((ref) {
      return BiometricNotifier();
    });

class BiometricNotifier extends StateNotifier<BiometricState> {
  final LocalAuthentication _localAuth = LocalAuthentication();

  BiometricNotifier() : super(BiometricState.initial());

  Future<void> checkBiometricAvailability() async {
    state = state.copyWith(status: BiometricStatus.checking);

    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();

      if (!isAvailable || !isDeviceSupported) {
        state = state.copyWith(
          status: BiometricStatus.unavailable,
          isAvailable: false,
          errorMessage: 'Biometric authentication not available on this device',
        );
        return;
      }

      final availableBiometrics = await _localAuth.getAvailableBiometrics();

      if (availableBiometrics.isEmpty) {
        state = state.copyWith(
          status: BiometricStatus.unavailable,
          isAvailable: false,
          errorMessage: 'No biometric authentication available',
        );
        return;
      }

      state = state.copyWith(
        status: BiometricStatus.available,
        isAvailable: true,
        availableBiometrics: availableBiometrics,
      );
    } catch (e) {
      state = state.copyWith(
        status: BiometricStatus.error,
        errorMessage: 'Failed to check biometric availability: ${e.toString()}',
      );
    }
  }

  Future<void> authenticateWithBiometric() async {
    state = state.copyWith(status: BiometricStatus.authenticating);

    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access the app',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (authenticated) {
        state = state.copyWith(
          status: BiometricStatus.success,
          isEnabled: true,
        );
      } else {
        state = state.copyWith(
          status: BiometricStatus.error,
          errorMessage: 'Biometric authentication failed',
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: BiometricStatus.error,
        errorMessage: 'Biometric authentication error: ${e.toString()}',
      );
    }
  }

  void setEnabled(bool enabled) {
    state = state.copyWith(isEnabled: enabled);
  }

  void setError(String error) {
    state = state.copyWith(status: BiometricStatus.error, errorMessage: error);
  }

  void clearError() {
    state = state.copyWith(status: BiometricStatus.initial, errorMessage: null);
  }

  void reset() {
    state = BiometricState.initial();
  }
}
