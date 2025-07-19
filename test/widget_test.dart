// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter_secure_auth/main.dart';

// Mock Firebase for testing
class MockFirebaseApp extends Fake implements FirebaseApp {}

void main() {
  group('AuthFlow App Tests', () {
    testWidgets('App should start without crashing', (
      WidgetTester tester,
    ) async {
      // Mock Firebase initialization
      setupFirebaseAuthMocks();

      // Build our app and trigger a frame.
      await tester.pumpWidget(const ProviderScope(child: AuthFlowApp()));

      // Verify that the app starts without errors
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App should have proper title', (WidgetTester tester) async {
      setupFirebaseAuthMocks();

      await tester.pumpWidget(const ProviderScope(child: AuthFlowApp()));

      // Verify app title
      expect(find.text('AuthFlow'), findsOneWidget);
    });
  });
}

// Mock Firebase setup for testing
void setupFirebaseAuthMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();
}
