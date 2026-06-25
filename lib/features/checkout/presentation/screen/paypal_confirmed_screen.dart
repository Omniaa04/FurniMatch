import 'package:flutter/material.dart';
import 'package:furnimatch/features/tracking/presentation/screen/order_tracking_screen.dart';

class PaypalConfirmedScreen extends StatelessWidget {
  final String orderId;
  final int? userId;
  final String? userName;

  const PaypalConfirmedScreen({
    super.key,
    required this.orderId,
    this.userId,
    this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F0E9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF6F0E9),
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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF0070BA), width: 4),
                ),
                child: const Icon(
                  Icons.check,
                  size: 60,
                  color: Color(0xFF0070BA),
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                "Your order has been Placed!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6B4423),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Paid via PayPal",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF0070BA),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Order ID: #$orderId",
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFFB8764D),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 80),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderTrackingScreen(
                          orderId: orderId,
                          userId: userId,
                          userName: userName,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7D533D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    "View Order",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}