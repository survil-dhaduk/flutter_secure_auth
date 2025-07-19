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

  static Either<ValidationFailure, String> validatePin(String pin) {
    if (pin.isEmpty) {
      return const Left(ValidationFailure('PIN is required'));
    }

    if (pin.length != AppConstants.pinLength) {
      return const Left(
        ValidationFailure('PIN must be ${AppConstants.pinLength} digits'),
      );
    }

    if (!RegExp(r'^\d+$').hasMatch(pin)) {
      return const Left(ValidationFailure('PIN must contain only digits'));
    }

    return Right(pin);
  }

  static Either<ValidationFailure, String> validatePinConfirmation(
    String pin,
    String confirmation,
  ) {
    final pinValidation = validatePin(pin);
    final confirmationValidation = validatePin(confirmation);

    if (pinValidation.isLeft()) {
      return pinValidation;
    }

    if (confirmationValidation.isLeft()) {
      return confirmationValidation;
    }

    if (pin != confirmation) {
      return const Left(ValidationFailure(AppConstants.pinMismatchMessage));
    }

    return Right(pin);
  }

  static bool isValidEmail(String email) {
    final emailRegex = RegExp(AppConstants.emailRegex);
    return emailRegex.hasMatch(email.trim());
  }

  static bool isValidPassword(String password) {
    return password.length >= AppConstants.minPasswordLength;
  }

  static bool isValidPin(String pin) {
    return pin.length == AppConstants.pinLength &&
        RegExp(r'^\d+$').hasMatch(pin);
  }
}
