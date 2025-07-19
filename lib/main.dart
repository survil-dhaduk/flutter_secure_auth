import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_secure_auth/firebase_options.dart';
import 'package:go_router/go_router.dart';
import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ProviderScope(child: AuthFlowApp()));
}

class AuthFlowApp extends ConsumerWidget {
  const AuthFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      theme: ThemeData(
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFF5D5FEF),
          onPrimary: Colors.white,
          secondary: Color(0xFFFFD166),
          onSecondary: Color(0xFF1A1A1A),
          error: Color(0xFFEF476F),
          onError: Colors.white,

          surface: Color(0xFFF6F9FC),
          onSurface: Color(0xFF1A1A1A),
          surfaceContainerHighest: Color(0xFFF6F9FC),
          onSurfaceVariant: Color(0xFF637488),
          outline: Color(0xFF5D5FEF),
          outlineVariant: Color(0xFFE0E3EB),
          tertiary: Color(0xFFEF476F),
          onTertiary: Colors.white,
          shadow: Color(0x335D5FEF),
          inverseSurface: Color(0xFF1A1A1A),
          onInverseSurface: Colors.white,
          inversePrimary: Color(0xFF5D5FEF),
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: Color(0xFF5D5FEF),
          onPrimary: Colors.white,
          secondary: Color(0xFFFFD166),
          onSecondary: Color(0xFF1A1A1A),
          error: Color(0xFFEF476F),
          onError: Colors.white,
          surface: Color(0xFF181A20),
          onSurface: Colors.white,

          surfaceContainerHighest: Color(0xFF23262F),
          onSurfaceVariant: Color(0xFFB0B8C1),
          outline: Color(0xFF5D5FEF),
          outlineVariant: Color(0xFF23262F),
          tertiary: Color(0xFFEF476F),
          onTertiary: Colors.white,
          shadow: Color(0x335D5FEF),
          inverseSurface: Color(0xFFF6F9FC),
          onInverseSurface: Color(0xFF1A1A1A),
          inversePrimary: Color(0xFF5D5FEF),
        ),
        useMaterial3: true,
      ),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
