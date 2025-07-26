import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  @override
  Future<Either<Failure, User>> signInWithEmail(
    String email,
    String password,
  ) async {
    try {
      final userModel = await _remoteDataSource.signInWithEmail(
        email,
        password,
      );
      await _localDataSource.setUserEmail(email);
      await _localDataSource.setAuthenticated(true);
      final isBiometricEnabled = await _localDataSource.isBiometricEnabled();
      final user = userModel.copyWith(
        isBiometricEnabled: isBiometricEnabled,
        lastLoginAt: DateTime.now(),
      );
      return Right(user);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> signUpWithEmail(
    String email,
    String password,
  ) async {
    try {
      final userModel = await _remoteDataSource.signUpWithEmail(
        email,
        password,
      );
      await _localDataSource.setUserEmail(email);
      await _localDataSource.setAuthenticated(true);

      return Right(userModel);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(String email) async {
    try {
      await _remoteDataSource.resetPassword(email);
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> enableBiometric() async {
    try {
      final isAvailable = await _localDataSource.authenticateWithBiometric();
      if (isAvailable) {
        await _localDataSource.setBiometricEnabled(true);
        return const Right(null);
      } else {
        return Left(BiometricFailure('Biometric authentication failed'));
      }
    } catch (e) {
      return Left(BiometricFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> authenticateWithBiometric() async {
    try {
      final isEnabled = await _localDataSource.isBiometricEnabled();
      if (!isEnabled) {
        return Left(BiometricFailure('Biometric authentication not enabled'));
      }

      final isAuthenticated = await _localDataSource
          .authenticateWithBiometric();
      if (isAuthenticated) {
        await _localDataSource.setAuthenticated(true);
        return const Right(true);
      } else {
        return const Right(false);
      }
    } catch (e) {
      return Left(BiometricFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _remoteDataSource.signOut();
      await _localDataSource.clearLocalData();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final userModel = await _remoteDataSource.getCurrentUser();
      if (userModel == null) return const Right(null);
      final isBiometricEnabled = await _localDataSource.isBiometricEnabled();
      final user = userModel.copyWith(isBiometricEnabled: isBiometricEnabled);
      return Right(user);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      final isAuthenticated = await _localDataSource.isAuthenticated();
      final currentUser = await _remoteDataSource.getCurrentUser();

      return Right(isAuthenticated && currentUser != null);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearLocalData() async {
    try {
      await _localDataSource.clearLocalData();
      return const Right(null);
    } catch (e) {
      return Left(StorageFailure(e.toString()));
    }
  }
}
