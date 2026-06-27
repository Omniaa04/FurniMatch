import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:furnimatch/features/orders/presentation/pages/orders_page.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Widget createOrdersPage() {
    return const MaterialApp(
      home: OrdersPage(
        customerId: 17,
      ),
    );
  }

  group("Orders Integration Tests", () {

    testWidgets("Orders page loads", (tester) async {
      await tester.pumpWidget(createOrdersPage());

      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 8));

      expect(find.text("My Orders"), findsOneWidget);
    });

    testWidgets("Orders finish loading", (tester) async {
      await tester.pumpWidget(createOrdersPage());

      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 8));

      expect(
        find.byType(CircularProgressIndicator),
        findsNothing,
      );
    });

    testWidgets("Refresh button works", (tester) async {
      await tester.pumpWidget(createOrdersPage());

      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 8));

      final refreshButton =
          find.byIcon(Icons.refresh_rounded);

      expect(refreshButton, findsOneWidget);

      await tester.tap(refreshButton);

      await tester.pump();

      await tester.pumpAndSettle(
        const Duration(seconds: 8),
      );

      expect(
        find.byType(CircularProgressIndicator),
        findsNothing,
      );
    });

    testWidgets("Orders are displayed", (tester) async {
      await tester.pumpWidget(createOrdersPage());

      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 8));

      expect(
        find.textContaining("Order #"),
        findsWidgets,
      );
    });

    testWidgets("Status badge appears", (tester) async {
      await tester.pumpWidget(createOrdersPage());

      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 8));

      final possibleStatuses = [
        "Preparing",
        "Out for delivery",
        "Shipped",
        "Cancelled",
      ];

      bool found = false;

      for (final status in possibleStatuses) {
        if (find.text(status).evaluate().isNotEmpty) {
          found = true;
          break;
        }
      }

      expect(found, isTrue);
    });

  });
}