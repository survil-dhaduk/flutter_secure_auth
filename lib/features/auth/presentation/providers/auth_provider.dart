import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart' as app_user;
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/datasources/auth_local_data_source.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final app_user.User? user;
  final String? errorMessage;
  final bool isPinSet;
  final bool isBiometricEnabled;

  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
    this.isPinSet = false,
    this.isBiometricEnabled = false,
  });

  factory AuthState.initial() {
    return const AuthState(status: AuthStatus.initial);
  }

  AuthState copyWith({
    AuthStatus? status,
    app_user.User? user,
    String? errorMessage,
    bool? isPinSet,
    bool? isBiometricEnabled,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
      isPinSet: isPinSet ?? this.isPinSet,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
    );
  }

  @override
  List<Object?> get props => [
    status,
    user,
    errorMessage,
    isPinSet,
    isBiometricEnabled,
  ];
}

// Providers
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final localAuthProvider = Provider<LocalAuthentication>((ref) {
  return LocalAuthentication();
});

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((
  ref,
) async {
  return await SharedPreferences.getInstance();
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final firebaseAuth = ref.read(firebaseAuthProvider);
  return AuthRemoteDataSourceImpl(firebaseAuth);
});

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  final secureStorage = ref.read(secureStorageProvider);
  final localAuth = ref.read(localAuthProvider);
  final prefs = ref.read(sharedPreferencesProvider).value;

  if (prefs == null) {
    throw Exception('SharedPreferences not initialized');
  }

  return AuthLocalDataSourceImpl(
    secureStorage: secureStorage,
    localAuth: localAuth,
    prefs: prefs,
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.read(authRemoteDataSourceProvider);
  final localDataSource = ref.read(authLocalDataSourceProvider);

  return AuthRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );
});

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return AuthNotifier(repository);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(AuthState.initial()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final result = await _repository.isAuthenticated();
    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (isAuthenticated) {
        if (isAuthenticated) {
          _getCurrentUser();
        } else {
          state = state.copyWith(status: AuthStatus.unauthenticated);
        }
      },
    );
  }

  Future<void> _getCurrentUser() async {
    final result = await _repository.getCurrentUser();
    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (user) {
        if (user != null) {
          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
            isPinSet: user.isPinSet,
            isBiometricEnabled: user.isBiometricEnabled,
          );
        } else {
          state = state.copyWith(status: AuthStatus.unauthenticated);
        }
      },
    );
  }

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _repository.signInWithEmail(email, password);

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (user) => state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        isPinSet: user.isPinSet,
        isBiometricEnabled: user.isBiometricEnabled,
      ),
    );
  }

  Future<void> signUp(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _repository.signUpWithEmail(email, password);

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (user) =>
          state = state.copyWith(status: AuthStatus.authenticated, user: user),
    );
  }

  Future<void> resetPassword(String email) async {
    final result = await _repository.resetPassword(email);

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(status: AuthStatus.unauthenticated),
    );
  }

  Future<void> setPin(String pin) async {
    final result = await _repository.setPin(pin);

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(isPinSet: true),
    );
  }

  Future<void> verifyPin(String pin) async {
    final result = await _repository.verifyPin(pin);

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (isValid) {
        if (isValid) {
          state = state.copyWith(status: AuthStatus.authenticated);
        } else {
          state = state.copyWith(
            status: AuthStatus.error,
            errorMessage: 'Invalid PIN',
          );
        }
      },
    );
  }

  Future<void> enableBiometric() async {
    final result = await _repository.enableBiometric();

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(isBiometricEnabled: true),
    );
  }

  Future<void> authenticateWithBiometric() async {
    final result = await _repository.authenticateWithBiometric();

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (isAuthenticated) {
        if (isAuthenticated) {
          state = state.copyWith(status: AuthStatus.authenticated);
        } else {
          state = state.copyWith(
            status: AuthStatus.error,
            errorMessage: 'Biometric authentication failed',
          );
        }
      },
    );
  }

  Future<void> signOut() async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _repository.signOut();

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
        isPinSet: false,
        isBiometricEnabled: false,
      ),
    );
  }

  void clearError() {
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      errorMessage: null,
    );
  }
}
