import 'package:dartz/dartz.dart';
import '../constants/app_constants.dart';
import '../errors/failures.dart';

class Validators {
  static Either<ValidationFailure, String> validateEmail(String email) {
    if (email.isEmpty) {
      return const Left(ValidationFailure('Email is required'));
    }

    final emailRegex = RegExp(AppConstants.emailRegex);
    if (!emailRegex.hasMatch(email)) {
      return const Left(ValidationFailure(AppConstants.invalidEmailMessage));
    }

    return Right(email.trim());
  }

  static Either<ValidationFailure, String> validatePassword(String password) {
    if (password.isEmpty) {
      return const Left(ValidationFailure('Password is required'));
    }

    if (password.length < AppConstants.minPasswordLength) {
      return const Left(ValidationFailure(AppConstants.invalidPasswordMessage));
    }

    return Right(password);
  }

  static bool isValidEmail(String email) {
    final emailRegex = RegExp(AppConstants.emailRegex);
    return emailRegex.hasMatch(email.trim());
  }

  static bool isValidPassword(String password) {
    return password.length >= AppConstants.minPasswordLength;
  }
}
