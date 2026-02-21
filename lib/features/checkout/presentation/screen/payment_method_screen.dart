import 'package:flutter/material.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F0E9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF6F0E9),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF381F02)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Payment Method",
          style: TextStyle(color: Color(0xFF381F02)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Credit & Debit Card",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            /// Clickable arrow
            PaymentOptionTile(
              title: "Add Card",
              icon: Icons.credit_card,
              onTap: () {
                Navigator.pushNamed(context, "/add_card");
              },
            ),

            const SizedBox(height: 25),
            const Text(
              "UPI Options",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            /// Make arrows clickable
            PaymentOptionTile(
              title: "Paypal",
              image: "lib/assets/images/paypal.png",
              onTap: () {
                Navigator.pushNamed(context, "/paypal");
              },
            ),
            PaymentOptionTile(
              title: "Apple Pay",
              image: "lib/assets/images/apple_pay.png",
              onTap: () {
                Navigator.pushNamed(context, "/apple_pay");
              },
            ),

            const SizedBox(height: 25),
            const Text(
              "Other Options",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            PaymentOptionTile(
              title: "Cash On Delivery (COD)",
              image: "lib/assets/images/cod_truck.png",
              onTap: () {
                Navigator.pushNamed(context, "/order_cod");
              },
            ),

            const SizedBox(height: 15),
            Row(
              children: const [
                Icon(Icons.lock, size: 16, color: Colors.grey),
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    "All transactions are secure and encrypted",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentOptionTile extends StatelessWidget {
  final String title;
  final IconData? icon;
  final String? image;
  final VoidCallback? onTap;

  const PaymentOptionTile({
    super.key,
    required this.title,
    this.icon,
    this.image,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: icon != null
          ? Icon(icon, size: 30)
          : image != null
              ? Image.asset(image!, width: 30, height: 30)
              : null,
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap, // <-- Makes arrow clickable
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
    );
  }
}