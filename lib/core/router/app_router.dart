import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_auth/features/auth/presentation/providers/biometric_provider.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_constants.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/pin_setup_page.dart';
import '../../features/auth/presentation/pages/pin_entry_page.dart';
import '../../features/auth/presentation/pages/biometric_setup_page.dart';
import '../../features/auth/presentation/pages/home_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

// Constants for route names
const String loginRoute = '/login';
const String pinSetupRoute = '/pin-setup';
const String pinEntryRoute = '/pin-entry';
const String biometricSetupRoute = '/biometric-setup';
const String homeRoute = '/home';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final bioStatus = ref.watch(biometricStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isAuthenticated = authState.status == AuthStatus.authenticated;
      final bool isBiomteric = (bioStatus.status == BiometricStatus.available);
      final isPinSet = authState.isPinSet;
      final isPinVerify = authState.isPinVerify;
      final isBiometricEnabled = authState.isBiometricEnabled;

      // If not authenticated, go to login
      if (!isAuthenticated) {
        return loginRoute;
      }

      // If authenticated but PIN not set, go to PIN setup
      if (isAuthenticated && !isPinSet) {
        return pinSetupRoute;
      }

      // If authenticated and PIN set but biometric not enabled, go to biometric setup
      if (isAuthenticated && isPinSet && !isBiometricEnabled && isBiomteric) {
        return biometricSetupRoute;
      }
      if (isAuthenticated && isPinSet) {
        return isPinVerify ? homeRoute : pinEntryRoute;
      }

      return null;
    },
    routes: [
      GoRoute(path: loginRoute, builder: (context, state) => const LoginPage()),
      GoRoute(
        path: pinSetupRoute,
        builder: (context, state) => const PinSetupPage(),
      ),
      GoRoute(
        path: pinEntryRoute,
        builder: (context, state) => const PinEntryPage(),
      ),
      GoRoute(
        path: biometricSetupRoute,
        builder: (context, state) => const BiometricSetupPage(),
      ),
      GoRoute(path: homeRoute, builder: (context, state) => const HomePage()),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'The page you are looking for does not exist.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
