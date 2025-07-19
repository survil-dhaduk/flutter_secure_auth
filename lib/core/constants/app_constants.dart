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

  // Login Page Strings
  static const String loginWelcomeBack = 'Welcome Back';
  static const String loginCreateAccount = 'Create Account';
  static const String loginSignUpHeader = 'Sign up for your AuthFlow account';
  static const String loginSignInHeader = 'Log in to your AuthFlow account';
  static const String loginEmailLabel = 'Email';
  static const String loginEmailHint = 'Enter your email';
  static const String loginPasswordLabel = 'Password';
  static const String loginPasswordHint = 'Enter your password';
  static const String loginForgotPassword = 'Forgot Password?';
  static const String loginButtonSignIn = 'Login';
  static const String loginButtonSignUp = 'Create Account';
  static const String loginOr = 'OR';
  static const String loginPinButton = 'Use your PIN';
  static const String loginToggleToSignUp = "Don't have an account? Sign Up";
  static const String loginToggleToSignIn = 'Already have an account? Sign In';
  static const String loginFooterToSignUp = "Don't have an account? ";
  static const String loginFooterToSignIn = 'Already have an account? ';
  static const String loginFooterSignUp = 'Sign Up';
  static const String loginFooterSignIn = 'Sign In';
  static const String loginResetPasswordTitle = 'Reset Password';
  static const String loginResetPasswordDesc =
      'Enter your email address to receive a password reset link.';
  static const String loginResetPasswordSend = 'Send';
  static const String loginResetPasswordCancel = 'Cancel';
  static const String loginResetPasswordSent = 'Password reset email sent!';
  static const String loginWelcomeSnack = 'Welcome back!';
  static const String loginErrorSnack = 'An error occurred';
  static const String loginCreatingAccount = 'Creating account...';
  static const String loginSigningIn = 'Signing in...';
}
