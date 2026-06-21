import 'package:flutter/material.dart';

class SellerHelpPage extends StatelessWidget {
  const SellerHelpPage({super.key});

  final Color brown = const Color(0xFF875A42);
  final Color background = const Color(0xFFF6F0E9);
  final Color accent = const Color(0xFFEBA46E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: brown,
        elevation: 0,
        title: const Text(
          "Help",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _headerCard(),
            const SizedBox(height: 22),

            _title("FAQ"),
            _faqItem(
              "How can I add a product?",
              "Go to Dashboard, choose Add Product, fill product details, upload image, then press Save.",
            ),
            _faqItem(
              "How can I edit product price?",
              "Open Product List, press the menu beside the product, choose Edit, then update the price.",
            ),
            _faqItem(
              "How can I add sale price?",
              "Open Edit Product, write the sale price, then save. The old price will appear crossed out.",
            ),
            _faqItem(
              "How can I track orders?",
              "Go to Orders section from your dashboard. You can see order status and update it.",
            ),

            const SizedBox(height: 22),

            _title("Contact Support"),
            _supportButton(
              context,
              Icons.chat,
              "Chat with Support",
              "We will reply as soon as possible",
            ),
            const SizedBox(height: 12),
            _supportButton(
              context,
              Icons.email,
              "Email Support",
              "support@furnimatch.com",
            ),

            const SizedBox(height: 22),

            _title("Seller Guide"),
            _guideCard(
              Icons.local_offer,
              "Use sales and discounts to attract more buyers.",
            ),
            _guideCard(
              Icons.image,
              "Upload clear product images with good lighting.",
            ),
            _guideCard(
              Icons.inventory,
              "Keep product stock updated to avoid cancelled orders.",
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: brown,
        borderRadius: BorderRadius.circular(26),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.help_outline, color: Colors.white, size: 42),
          SizedBox(height: 12),
          Text(
            "How can we help you?",
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Find answers and support for your seller dashboard.",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _title(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: TextStyle(
          color: brown,
          fontSize: 21,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _faqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        iconColor: brown,
        collapsedIconColor: brown,
        title: Text(
          question,
          style: TextStyle(
            color: brown,
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              answer,
              style: const TextStyle(
                color: Colors.black54,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _supportButton(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$title clicked")),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: accent.withOpacity(0.25),
              child: Icon(icon, color: brown),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: brown,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: brown, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _guideCard(IconData icon, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: brown),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: brown,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
