import 'package:flutter/material.dart';
import 'dart:async';

class ProcessingPaypalScreen extends StatefulWidget {
  const ProcessingPaypalScreen({super.key});

  @override
  State<ProcessingPaypalScreen> createState() => _ProcessingPaypalScreenState();
}

class _ProcessingPaypalScreenState extends State<ProcessingPaypalScreen> {
  @override
  void initState() {
    super.initState();
    // Automatically navigate to PayPal confirmed screen after 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, "/paypal_confirmed");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F0E9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF6F0E9),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6B4423)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Payment",
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
            // Loading Spinner with PayPal color
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                strokeWidth: 6,
                valueColor: AlwaysStoppedAnimation<Color>(
                  const Color(0xFF0070BA),
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Processing Text
            const Text(
              "Processing your PayPal payment..",
              style: TextStyle(
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