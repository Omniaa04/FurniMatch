import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/checkout/presentation/screen/checkout_screen.dart';
import 'features/checkout/presentation/screen/payment_method_screen.dart';
import 'features/checkout/presentation/screen/add_card_screen.dart';
import 'features/checkout/presentation/screen/paypal_screen.dart';
import 'features/checkout/presentation/screen/apple_pay_screen.dart';
import 'features/checkout/presentation/screen/order_card_screen.dart';
import 'features/checkout/presentation/screen/order_paypal_screen.dart';
import 'features/checkout/presentation/screen/order_applepay_screen.dart';
import 'features/checkout/presentation/screen/order_cod_screen.dart';
import 'features/checkout/presentation/screen/processing_order_screen.dart';
import 'features/checkout/presentation/screen/order_confirmed_screen.dart';
import 'features/checkout/presentation/screen/processing_paypal_screen.dart';
import 'features/checkout/presentation/screen/paypal_confirmed_screen.dart';
import 'features/checkout/presentation/screen/processing_applepay_screen.dart';
import 'features/checkout/presentation/screen/applepay_confirmed_screen.dart';
import 'features/checkout/presentation/screen/processing_cod_screen.dart';
import 'features/checkout/presentation/screen/cod_confirmed_screen.dart';
import 'features/checkout/presentation/screen/cart_screen.dart';

void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
      textTheme: GoogleFonts.baloo2TextTheme(), // Baloo 2 everywhere
),

      debugShowCheckedModeBanner: false,
      title: 'Payment App',

      // Start on your Checkout screen
      home: const CartScreen(), //home: const BuyOrSellScreen(), Instead of CheckoutScreen

      // Add routes
      routes: {
        "/checkout": (context) => const CheckoutScreen(),
        "/payment_method": (context) => const PaymentMethodScreen(),
        "/add_card": (context) => const AddCardScreen(),
        "/paypal": (context) => const PaypalScreen(),
        "/apple_pay": (context) => const ApplePayScreen(),
        "/order_card": (context) => const OrderCardScreen(),
        "/order_paypal": (context) => const OrderPaypalScreen(),
        "/order_applepay": (context) => const OrderApplePayScreen(),
        "/order_cod": (context) => const OrderCodScreen(),
        "/processing_order": (context) => const ProcessingOrderScreen(),
        "/order_confirmed": (context) => const OrderConfirmedScreen(),
        "/processing_paypal": (context) => const ProcessingPaypalScreen(),
        "/paypal_confirmed": (context) => const PaypalConfirmedScreen(),
        "/processing_applepay": (context) => const ProcessingApplePayScreen(),
        "/applepay_confirmed": (context) => const ApplePayConfirmedScreen(),
        "/processing_cod": (context) => const ProcessingCodScreen(),
        "/cod_confirmed": (context) => const CodConfirmedScreen(),
        "/cart": (context) => const CartScreen(),
  
      },
    );
  }
}