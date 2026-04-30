import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:furnimatch/features/checkout/data/checkout_api_service.dart';
import 'package:furnimatch/features/checkout/presentation/screen/applepay_confirmed_screen.dart';

class ProcessingApplePayScreen extends StatefulWidget {
  const ProcessingApplePayScreen({super.key});

  @override
  State<ProcessingApplePayScreen> createState() =>
      _ProcessingApplePayScreenState();
}

class _ProcessingApplePayScreenState extends State<ProcessingApplePayScreen> {
  @override
  void initState() {
    super.initState();
    _createOrder();
  }

  Future<void> _createOrder() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final userId = prefs.getInt('user_id') ?? prefs.getInt('userId');
      final userName = prefs.getString('name') ??
          prefs.getString('user_name') ??
          prefs.getString('userName');

      if (userId == null) {
        throw Exception('User ID not found. Please login again.');
      }

      final orderId = await CheckoutApiService().createOrder(
        userId: userId,
        totalPrice: 190.00,
        paymentMethod: 'Apple Pay',
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ApplePayConfirmedScreen(
            orderId: orderId,
            userId: userId,
            userName: userName,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Checkout error: $e')),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const _ProcessingBody(text: 'Processing your Apple Pay payment...');
  }
}

class _ProcessingBody extends StatelessWidget {
  final String text;

  const _ProcessingBody({required this.text});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F0E9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF6F0E9),
        title: const Text(
          'Payment',
          style: TextStyle(
            color: Color(0xFF6B4423),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                strokeWidth: 6,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black87),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              text,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B4423),
              ),
            ),
          ],
        ),
      ),
    );
  }
}