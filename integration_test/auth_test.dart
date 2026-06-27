import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:furnimatch/features/auth/presentation/pages/login_page.dart';
import 'package:furnimatch/features/auth/presentation/pages/signup_page.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Integration Tests', () {

    testWidgets('Login page loads correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginPage(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text("Login to your Account"), findsOneWidget);
      expect(find.text("Log In"), findsOneWidget);
      expect(find.text("Email*"), findsOneWidget);
      expect(find.text("Password*"), findsOneWidget);
    });

    testWidgets('Empty fields validation', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginPage(),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text("Log In"));
      await tester.pump();

      expect(find.text("Email can't be empty"), findsOneWidget);
      expect(find.text("Password can't be empty"), findsOneWidget);
    });

    testWidgets('Invalid email validation', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginPage(),
        ),
      );

      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).at(0),
        "invalidEmail",
      );

      await tester.enterText(
        find.byType(TextFormField).at(1),
        "12345678",
      );

      await tester.tap(find.text("Log In"));
      await tester.pump();

      expect(find.text("Enter valid email"), findsOneWidget);
    });

    testWidgets('Short password validation', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginPage(),
        ),
      );

      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).at(0),
        "test@test.com",
      );

      await tester.enterText(
        find.byType(TextFormField).at(1),
        "123",
      );

      await tester.tap(find.text("Log In"));
      await tester.pump();

      expect(
        find.text("Password must be at least 8 characters"),
        findsOneWidget,
      );
    });

    testWidgets('Navigate to Sign Up page', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginPage(),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text("Sign Up"));
      await tester.pumpAndSettle();

      expect(find.byType(SignUpPage), findsOneWidget);
    });

    testWidgets('Back from Sign Up returns to Login', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginPage(),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text("Sign Up"));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text("Login to your Account"), findsOneWidget);
    });

    testWidgets('Successful login using real API', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginPage(),
        ),
      );

      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).at(0),
        "shahyshosha888@gmail.com",
      );

      await tester.enterText(
        find.byType(TextFormField).at(1),
        "meow12345",
      );

      await tester.tap(find.text("Log In"));

      await tester.pump();

      await tester.pumpAndSettle(
        const Duration(seconds: 8),
      );

      // Login succeeded (no error SnackBar)
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('Login fails with wrong password', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginPage(),
        ),
      );

      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).at(0),
        "shahyshosha888@gmail.com",
      );

      await tester.enterText(
        find.byType(TextFormField).at(1),
        "wrongpassword",
      );

      await tester.tap(find.text("Log In"));

      await tester.pump();

      await tester.pumpAndSettle(
        const Duration(seconds: 8),
      );

      expect(find.byType(SnackBar), findsOneWidget);
    });

  });
}