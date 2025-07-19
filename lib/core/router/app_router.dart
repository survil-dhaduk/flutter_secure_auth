import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_constants.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/pin_setup_page.dart';
import '../../features/auth/presentation/pages/pin_entry_page.dart';
import '../../features/auth/presentation/pages/biometric_setup_page.dart';
import '../../features/auth/presentation/pages/home_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isAuthenticated = authState.status == AuthStatus.authenticated;
      final isPinSet = authState.isPinSet;
      final isBiometricEnabled = authState.isBiometricEnabled;
      final isLoading = authState.status == AuthStatus.loading;
      final isInitial = authState.status == AuthStatus.initial;

      // Don't redirect while loading or initial
      if (isLoading || isInitial) {
        return null;
      }

      // If not authenticated, go to login
      if (!isAuthenticated) {
        return '/login';
      }

      // If authenticated but PIN not set, go to PIN setup
      if (isAuthenticated && !isPinSet) {
        return '/pin-setup';
      }

      // If authenticated and PIN set but biometric not enabled, go to biometric setup
      if (isAuthenticated && isPinSet && !isBiometricEnabled) {
        return '/biometric-setup';
      }

      // If authenticated and everything is set up, go to home
      if (isAuthenticated && isPinSet) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/pin-setup',
        builder: (context, state) => const PinSetupPage(),
      ),
      GoRoute(
        path: '/pin-entry',
        builder: (context, state) => const PinEntryPage(),
      ),
      GoRoute(
        path: '/biometric-setup',
        builder: (context, state) => const BiometricSetupPage(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomePage()),
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
