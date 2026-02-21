import 'package:flutter/material.dart';
import 'dart:async';

class ProcessingApplePayScreen extends StatefulWidget {
  const ProcessingApplePayScreen({super.key});

  @override
  State<ProcessingApplePayScreen> createState() => _ProcessingApplePayScreenState();
}

class _ProcessingApplePayScreenState extends State<ProcessingApplePayScreen> {
  @override
  void initState() {
    super.initState();
    // Automatically navigate to Apple Pay confirmed screen after 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, "/applepay_confirmed");
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
            // Loading Spinner with black color for Apple
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                strokeWidth: 6,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Processing Text
            const Text(
              "Processing your Apple Pay payment..",
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