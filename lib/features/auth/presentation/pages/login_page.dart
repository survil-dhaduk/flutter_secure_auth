import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/loading_overlay.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        context.showSnackBar('Welcome back!');
        // Navigation will be handled by router
      } else if (next.status == AuthStatus.error) {
        context.showSnackBar(
          next.errorMessage ?? 'An error occurred',
          isError: true,
        );
      }
    });

    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return LoadingOverlay(
      isLoading: authState.status == AuthStatus.loading,
      message: _isSignUp
          ? AppConstants.loginCreatingAccount
          : AppConstants.loginSigningIn,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Main card
                  Container(
                    width: 400,
                    constraints: const BoxConstraints(maxWidth: 400),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 32,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.08),
                          blurRadius: 32,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header
                          Column(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: colorScheme.primary.withOpacity(
                                        0.18,
                                      ),
                                      blurRadius: 24,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.lock_outline,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                _isSignUp
                                    ? AppConstants.loginCreateAccount
                                    : AppConstants.loginWelcomeBack,
                                style: textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _isSignUp
                                    ? AppConstants.loginSignUpHeader
                                    : AppConstants.loginSignInHeader,
                                style: textTheme.bodyLarge?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          // Email field
                          CustomTextField(
                            label: AppConstants.loginEmailLabel,
                            hint: AppConstants.loginEmailHint,
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              final result = Validators.validateEmail(
                                value ?? '',
                              );
                              return result.fold(
                                (failure) => failure.message,
                                (_) => null,
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          // Password field
                          CustomTextField(
                            label: AppConstants.loginPasswordLabel,
                            hint: AppConstants.loginPasswordHint,
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            validator: (value) {
                              final result = Validators.validatePassword(
                                value ?? '',
                              );
                              return result.fold(
                                (failure) => failure.message,
                                (_) => null,
                              );
                            },
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Forgot password
                          if (!_isSignUp)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _showForgotPasswordDialog,
                                style: TextButton.styleFrom(
                                  foregroundColor: colorScheme.primary,
                                  textStyle: textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                child: const Text(
                                  AppConstants.loginForgotPassword,
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),
                          // Submit button
                          SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                textStyle: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                                elevation: 4,
                                shadowColor: colorScheme.primary.withOpacity(
                                  0.2,
                                ),
                              ),
                              child: Text(
                                _isSignUp
                                    ? AppConstants.loginButtonSignUp
                                    : AppConstants.loginButtonSignIn,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // OR divider
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: colorScheme.outlineVariant,
                                  thickness: 1,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Text(
                                  AppConstants.loginOr,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: colorScheme.outlineVariant,
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Toggle sign up/sign in
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isSignUp = !_isSignUp;
                                });
                              },
                              child: Text.rich(
                                TextSpan(
                                  text: _isSignUp
                                      ? AppConstants.loginFooterToSignIn
                                      : AppConstants.loginFooterToSignUp,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: _isSignUp
                                          ? AppConstants.loginFooterSignIn
                                          : AppConstants.loginFooterSignUp,
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      recognizer:
                                          null, // Could add gesture recognizer for navigation
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Footer
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (_isSignUp) {
        ref.read(authStateProvider.notifier).signUp(email, password);
      } else {
        ref.read(authStateProvider.notifier).signIn(email, password);
      }
    }
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter your email address to receive a password reset link.',
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Email',
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                final result = Validators.validateEmail(value ?? '');
                return result.fold((failure) => failure.message, (_) => null);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final email = emailController.text.trim();
              if (Validators.isValidEmail(email)) {
                ref.read(authStateProvider.notifier).resetPassword(email);
                Navigator.of(context).pop();
                context.showSnackBar('Password reset email sent!');
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}
