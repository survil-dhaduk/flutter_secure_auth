class AppConstants {
  // App Info
  static const String appName = 'AuthFlow';
  static const String appVersion = '1.0.0';

  // Authentication
  static const int pinLength = 4;
  static const int maxPinAttempts = 3;
  static const int sessionTimeoutMinutes = 30;

  // Validation
  static const int minPasswordLength = 8;
  static const String emailRegex = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';

  // UI
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 8.0;
  static const Duration animationDuration = Duration(milliseconds: 300);

  // Error Messages
  static const String invalidEmailMessage =
      'Please enter a valid email address';
  static const String invalidPasswordMessage =
      'Password must be at least 8 characters';
  static const String pinMismatchMessage = 'PINs do not match';
  static const String biometricNotAvailableMessage =
      'Biometric authentication not available';
  static const String biometricFailedMessage =
      'Biometric authentication failed';
  static const String tooManyAttemptsMessage =
      'Too many failed attempts. Please try again later';
}
