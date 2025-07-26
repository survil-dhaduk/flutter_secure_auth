import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_secure_auth/features/auth/presentation/providers/biometric_provider.dart';
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
import 'package:dartz/dartz.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final app_user.User? user;
  final String? errorMessage;
  final bool isBiometricEnabled;

  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
    this.isBiometricEnabled = true,
  });

  factory AuthState.initial() {
    return const AuthState(status: AuthStatus.initial);
  }

  AuthState copyWith({
    AuthStatus? status,
    app_user.User? user,
    String? errorMessage,
    bool? isBiometricEnabled,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage, isBiometricEnabled];
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

final authLocalDataSourceProvider = FutureProvider<AuthLocalDataSource>((
  ref,
) async {
  final secureStorage = ref.read(secureStorageProvider);
  final localAuth = ref.read(localAuthProvider);
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return AuthLocalDataSourceImpl(
    secureStorage: secureStorage,
    localAuth: localAuth,
    prefs: prefs,
  );
});

final authRepositoryProvider = FutureProvider<AuthRepository>((ref) async {
  final remoteDataSource = ref.read(authRemoteDataSourceProvider);
  final localDataSource = await ref.watch(authLocalDataSourceProvider.future);
  return AuthRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );
});

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;
  AuthRepository? _repository;

  AuthNotifier(this.ref) : super(AuthState.initial()) {
    _init();
  }

  Future<void> _init() async {
    final repoAsync = await ref.watch(authRepositoryProvider.future);
    _repository = repoAsync;
    await _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    if (_repository == null) return;
    final result = await _repository!.isAuthenticated();
    ref.read(biometricStateProvider.notifier).checkBiometricAvailability();
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
    if (_repository == null) return;
    final result = await _repository!.getCurrentUser();
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
            isBiometricEnabled: user.isBiometricEnabled,
          );
        } else {
          state = state.copyWith(status: AuthStatus.unauthenticated);
        }
      },
    );
  }

  Future<void> signIn(String email, String password) async {
    if (_repository == null) return;
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _repository?.signInWithEmail(email, password);

    result?.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (user) => state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        isBiometricEnabled: user.isBiometricEnabled,
      ),
    );
  }

  Future<void> signUp(String email, String password) async {
    if (_repository == null) return;
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _repository!.signUpWithEmail(email, password);

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
    if (_repository == null) return;
    final result = await _repository!.resetPassword(email);

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(status: AuthStatus.unauthenticated),
    );
  }

  Future<void> enableBiometric(bool enabled) async {
    if (_repository == null) return;
    final result = await _repository!.enableBiometric();

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(isBiometricEnabled: enabled),
    );
  }

  Future<Either<Failure, bool>> authenticateWithBiometric() async {
    if (_repository == null) {
      return left(AuthFailure('Repository not initialized'));
    }
    return await _repository!.authenticateWithBiometric();
  }

  Future<void> signOut() async {
    if (_repository == null) return;
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _repository?.signOut();

    result?.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,

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
