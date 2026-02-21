import 'package:flutter/material.dart';

class OrderCardScreen extends StatelessWidget {
  const OrderCardScreen({super.key});

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
          "Order",
          style: TextStyle(
            color: Color(0xFF6B4423),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Color(0xFF6B4423)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Credit Card Display
            Center(
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Bank Name and Chip
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "BANK NAME",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              letterSpacing: 1.5,
                            ),
                          ),
                          Container(
                            width: 45,
                            height: 35,
                            decoration: BoxDecoration(
                              color: Colors.amber.shade200,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      
                      // Card Number
                      const Text(
                        "1234 5678 9012 3456",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 15),
                      
                      // Card Holder and Expiry
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "VALID THRU",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 8,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                "05/25",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "CARDHOLDER NAME",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 8,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                "CARDHOLDER NAME",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          // Card Logo
                          Container(
                            width: 40,
                            height: 25,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.credit_card,
                                color: Colors.blue[900],
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Your Order Section
            const Text(
              "Your order",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B4423),
              ),
            ),
            const SizedBox(height: 10),
            
            _buildOrderItem("Brown comfy mini sofa"),
            _buildOrderItem("Blue study sofa"),
            _buildOrderItem("Green casual sofa"),

            const SizedBox(height: 25),

            // Address Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Address",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B4423),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Anas Mia",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFFB8764D),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Sylet City Residence B - 15 Lakhai",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFFB8764D),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "675538",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFFB8764D),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7D533D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: const Text(
                    "Change Address",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // Shipping to Section
            const Text(
              "Shipping to",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B4423),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Cairo",
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFFB8764D),
              ),
            ),

            const SizedBox(height: 25),

            // Total Payment
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "Total Payment",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B4423),
                  ),
                ),
                Text(
                  "190.00\$",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB8764D),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Confirm Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to processing screen
                  Navigator.pushNamed(context, "/processing_order");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7D533D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  "Confirm",
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
    );
  }

  Widget _buildOrderItem(String itemName) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFFB8764D),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            itemName,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFFB8764D),
            ),
          ),
        ],
      ),
    );
  }
}