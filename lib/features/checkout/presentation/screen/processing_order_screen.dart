import 'package:flutter/material.dart';
import 'dart:async';

class ProcessingOrderScreen extends StatefulWidget {
  const ProcessingOrderScreen({super.key});

  @override
  State<ProcessingOrderScreen> createState() => _ProcessingOrderScreenState();
}

class _ProcessingOrderScreenState extends State<ProcessingOrderScreen> {
  @override
  void initState() {
    super.initState();
    // Automatically navigate to order confirmed screen after 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, "/order_confirmed");
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
            // Loading Spinner
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                strokeWidth: 6,
                valueColor: AlwaysStoppedAnimation<Color>(
                  const Color(0xFFB8764D),
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Processing Text
            const Text(
              "Processing your order..",
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