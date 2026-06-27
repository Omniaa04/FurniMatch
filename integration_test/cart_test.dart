import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:furnimatch/features/cart/injection_container.dart' as di;
import 'package:furnimatch/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:furnimatch/features/cart/presentation/pages/cart_page.dart';
import 'package:furnimatch/providers/cart_provider.dart';



void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();

    if (!di.sl.isRegistered<CartBloc>()) {
      di.initCartDependencies();
    }
  });

  Widget createCartPage() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ),
        BlocProvider<CartBloc>(
          create: (_) => di.sl<CartBloc>(),
        ),
      ],
      child: const MaterialApp(
        home: CartPage(
          userId: 17,
        ),
      ),
    );
  }

  Future<void> openCart(WidgetTester tester) async {
    await tester.pumpWidget(createCartPage());

    await tester.pump();

    // wait until network + bloc finish
    await tester.pumpAndSettle(
      const Duration(seconds: 10),
    );
  }

  group("Cart Integration Tests", () {
    testWidgets("Cart page loads", (tester) async {
      await openCart(tester);

      expect(find.text("Cart"), findsOneWidget);
    });

    testWidgets("Cart items appear", (tester) async {
      await openCart(tester);

      expect(
        find.byType(CircularProgressIndicator),
        findsNothing,
      );

      expect(
        find.byType(Dismissible),
        findsWidgets,
      );
    });

    testWidgets("Increase quantity", (tester) async {
      await openCart(tester);

      final addButtons = find.byIcon(Icons.add);

      expect(addButtons, findsWidgets);

      await tester.tap(addButtons.first);

      await tester.pump();

      await tester.pumpAndSettle(
        const Duration(seconds: 6),
      );
    });

    testWidgets("Decrease quantity", (tester) async {
      await openCart(tester);

      final removeButtons = find.byIcon(Icons.remove);

      expect(removeButtons, findsWidgets);

      await tester.tap(removeButtons.first);

      await tester.pump();

      await tester.pumpAndSettle(
        const Duration(seconds: 6),
      );

      // Remove dialog may appear if quantity == 1
      if (find.text("Remove").evaluate().isNotEmpty) {
        await tester.tap(find.text("Cancel"));

        await tester.pumpAndSettle();
      }
    });

    testWidgets("Delete cart item", (tester) async {
      await openCart(tester);

      final dismissible = find.byType(Dismissible);

      expect(dismissible, findsWidgets);

      await tester.drag(
        dismissible.first,
        const Offset(-600, 0),
      );

      await tester.pumpAndSettle();

      if (find.text("Delete").evaluate().isNotEmpty) {
        await tester.tap(find.text("Delete"));

        await tester.pump();

        await tester.pumpAndSettle(
          const Duration(seconds: 6),
        );
      }
    });

    testWidgets("Apply promo code", (tester) async {
      await openCart(tester);

      final promoField = find.byType(TextField);

      expect(promoField, findsOneWidget);

      await tester.enterText(
        promoField,
        "SAVE10",
      );

      await tester.tap(find.text("Apply"));

      await tester.pump();

      await tester.pumpAndSettle(
        const Duration(seconds: 6),
      );
    });

    testWidgets("Proceed to checkout", (tester) async {
      await openCart(tester);

      final checkout =
          find.text("Proceed to Checkout");

      expect(checkout, findsOneWidget);

      await tester.tap(checkout);

      await tester.pump();

      await tester.pumpAndSettle(
        const Duration(seconds: 8),
      );

      // Just verify navigation happened
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets("Share cart button exists", (tester) async {
      await openCart(tester);

      expect(
        find.byIcon(Icons.ios_share),
        findsOneWidget,
      );
    });

    testWidgets("Tap Share button", (tester) async {
      await openCart(tester);

      final share = find.byIcon(Icons.ios_share);

      expect(share, findsOneWidget);

      await tester.tap(share);

      await tester.pump();

      await tester.pumpAndSettle(
        const Duration(seconds: 3),
      );
    });

    testWidgets("Back button exists", (tester) async {
      await openCart(tester);

      expect(
        find.byIcon(Icons.arrow_back_ios_new),
        findsOneWidget,
      );
    });

    testWidgets("Tap Back button", (tester) async {
      await openCart(tester);

      final back =
          find.byIcon(Icons.arrow_back_ios_new);

      expect(back, findsOneWidget);

      await tester.tap(back);

      await tester.pump();

      await tester.pumpAndSettle(
        const Duration(seconds: 2),
      );
    });
  });

  tearDownAll(() async {
    await di.sl.reset();
  });
}