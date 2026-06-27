import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:furnimatch/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Home Screen Integration Test', () {
    testWidgets('Complete Home Flow', (WidgetTester tester) async {
      // Launch the application
      app.main();

      // Give Flutter time to build the first screen
      await tester.pump();
      await tester.pump(const Duration(seconds: 5));

      // Close the measure popup if it appears
      final closeButton = find.byIcon(Icons.close);
      if (closeButton.evaluate().isNotEmpty) {
        await tester.tap(closeButton);
        await tester.pump(const Duration(milliseconds: 500));
      }

     
      // Verify app launched
      

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.text("FurniMatch"), findsOneWidget);

     
      // Verify login/signup buttons OR greeting
     

      final login = find.text("Log In");
      final signup = find.text("Sign Up");
      final greeting = find.textContaining("Hi,");

      expect(
        login.evaluate().isNotEmpty ||
            signup.evaluate().isNotEmpty ||
            greeting.evaluate().isNotEmpty,
        true,
      );

     
      // Categories section
    

      expect(find.text("Categories"), findsOneWidget);

      
      // Scroll down
      

      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -600),
      );

      await tester.pump(const Duration(seconds: 1));

      expect(find.text("Furniture in Unique Style"), findsOneWidget);

     
      // Bottom navigation
      

      expect(find.byIcon(Icons.home_filled), findsOneWidget);
      expect(find.byIcon(Icons.chat_outlined), findsOneWidget);
      expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);

    
      // Camera button
      

      expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);

      
      // Tap Home tab
    

      await tester.tap(find.byIcon(Icons.home_filled));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text("FurniMatch"), findsOneWidget);
    });
  });
}