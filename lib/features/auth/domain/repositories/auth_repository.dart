import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> signInWithEmail(String email, String password);
  Future<Either<Failure, User>> signUpWithEmail(String email, String password);
  Future<Either<Failure, void>> resetPassword(String email);
  Future<Either<Failure, void>> setPin(String pin);
  Future<Either<Failure, bool>> verifyPin(String pin);
  Future<Either<Failure, void>> enableBiometric();
  Future<Either<Failure, bool>> authenticateWithBiometric();
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, User?>> getCurrentUser();
  Future<Either<Failure, bool>> isAuthenticated();
  Future<Either<Failure, void>> clearLocalData();
}
