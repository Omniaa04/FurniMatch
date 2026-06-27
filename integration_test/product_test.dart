import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

import 'package:furnimatch/providers/cart_provider.dart';
import 'package:furnimatch/features/product/presentation/pages/product_details_page.dart';
import 'package:furnimatch/features/ar/presentation/pages/ar_view_page.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final product = {
    'id': 1,
    'name': 'Office Chair',
    'category': 'Furniture',
    'description': 'Comfortable office chair for everyday use.',
    'price': 1000,
    'sale_price': 800,
    'stock': 10,
    'image_url': '',
    'colors': ['#000000', '#FFFFFF'],
  };

  Widget createPage({
    int? userId,
    String? userName,
    Map<String, dynamic>? customProduct,
  }) {
    return ChangeNotifierProvider(
      create: (_) => CartProvider(),
      child: MaterialApp(
        home: ProductDetailsPage(
          product: customProduct ?? product,
          userId: userId,
          userName: userName,
        ),
      ),
    );
  }

  group("Product Details Integration Tests", () {

   
    testWidgets("Product page loads correctly", (tester) async {
      await tester.pumpWidget(createPage());

      await tester.pumpAndSettle();

      expect(find.text("Office Chair"), findsAtLeastNWidgets(1));
      expect(find.text("Furniture"), findsAtLeastNWidgets(1));
      expect(find.text("Product Details"), findsAtLeastNWidgets(1));
      expect(find.text("Try in My Room"), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.favorite_border), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.shopping_cart_outlined).first, findsAtLeastNWidgets(1));
    });


    testWidgets("Guest cannot favorite", (tester) async {
      await tester.pumpWidget(createPage());

      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.favorite_border));

      await tester.pump();

      expect(find.text("Please log in first!"), findsOneWidget);
    });

    
    testWidgets("Guest cannot add to cart", (tester) async {
      await tester.pumpWidget(createPage());

      await tester.pumpAndSettle();

      await tester.tap(
      find.byIcon(Icons.shopping_cart_outlined).first,
);

      await tester.pump();

      expect(find.text("Please log in first!"), findsOneWidget);
    });

    
    testWidgets("Open AR page", (tester) async {
      await tester.pumpWidget(createPage());

      await tester.pumpAndSettle();

      await tester.tap(find.text("Try in My Room"));

      await tester.pumpAndSettle();

      expect(find.byType(ArViewPage), findsOneWidget);
    });

    
    testWidgets("Sale price is displayed", (tester) async {
      await tester.pumpWidget(createPage());

      await tester.pumpAndSettle();

      expect(find.text("\$ 1000"), findsOneWidget);
      expect(find.text("\$ 800"), findsOneWidget);
    });

   
    testWidgets("Out of stock badge appears", (tester) async {

      final outProduct = Map<String, dynamic>.from(product);
      outProduct["stock"] = 0;

      await tester.pumpWidget(
        createPage(customProduct: outProduct),
      );

      await tester.pumpAndSettle();

      expect(find.text("Out of Stock"), findsOneWidget);
    });

   
    testWidgets("In stock badge appears", (tester) async {
      await tester.pumpWidget(createPage());

      await tester.pumpAndSettle();

      expect(find.textContaining("In Stock"), findsOneWidget);
    });

    
    testWidgets("Toggle favorite using real API", (tester) async {

      await tester.pumpWidget(
        createPage(
          userId: 17,       // <-- replace with your user id
          userName: "Shahd",
        ),
      );

      await tester.tap(find.byIcon(Icons.favorite_border).first);

       await tester.pump();
       await tester.pump(const Duration(seconds: 5));
    });

    
    testWidgets("Add product to cart using real API", (tester) async {

      await tester.pumpWidget(
        createPage(
          userId: 17,
          userName: "Shahd",
        ),
      );

      await tester.pumpAndSettle();

      find.byIcon(Icons.shopping_cart_outlined).first;

      await tester.pump();

      await tester.pumpAndSettle(
        const Duration(seconds: 8),
      );

    });

   
   
  
  });
}