import 'package:flutter/material.dart';

class CodConfirmedScreen extends StatelessWidget {
  const CodConfirmedScreen({super.key});

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
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFB8764D),
                    width: 4,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.check,
                    size: 60,
                    color: Color(0xFFB8764D),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              
              // Order Placed Text
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
              
              // COD confirmation
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.local_shipping_outlined, size: 20, color: Color(0xFFB8764D)),
                  SizedBox(width: 5),
                  Text(
                    "Cash On Delivery",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFFB8764D),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              
              // Thank you message
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    "Thank you for your patience",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF9B8471),
                    ),
                  ),
                  Text(
                    "😊",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              
              const SizedBox(height: 80),
              
              // View Order Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate back to home or order history
                    Navigator.popUntil(context, (route) => route.isFirst);
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
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
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