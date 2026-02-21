import 'package:flutter/material.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _fullNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _phoneController = TextEditingController();

  int _selectedNavIndex = 4; // Cart is selected

  @override
  void dispose() {
    _fullNameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    super.dispose();
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
          "Checkout",
          style: TextStyle(
            color: Color(0xFF6B4423),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Shipping Information Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE8D5C4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Shipping Information",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B4423),
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  // Full Name
                  TextField(
                    controller: _fullNameController,
                    decoration: InputDecoration(
                      hintText: "Full Name",
                      hintStyle: const TextStyle(
                        color: Color(0xFF9B8471),
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFD4C0AD),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Address
                  TextField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      hintText: "Address",
                      hintStyle: const TextStyle(
                        color: Color(0xFF9B8471),
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFD4C0AD),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // City
                  TextField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      hintText: "City",
                      hintStyle: const TextStyle(
                        color: Color(0xFF9B8471),
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFD4C0AD),
                      suffixIcon: const Icon(
                        Icons.tune,
                        color: Color(0xFF6B4423),
                        size: 20,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Phone Number
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: "Phone Number",
                      hintStyle: const TextStyle(
                        color: Color(0xFF9B8471),
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFD4C0AD),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  // Buttons Row
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, "/payment_method");
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7D533D),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            "Save Address",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xFF7D533D),
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            "Use location",
                            style: TextStyle(
                              color: Color(0xFF7D533D),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Payment Method Card
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, "/payment_method");
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8D5C4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      "Payment Method",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFB8764D),
                      ),
                    ),
                    Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Color(0xFF6B4423),
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Order Summary Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE8D5C4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Order Summary",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B4423),
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  // Item Value
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "ItemValue",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B4423),
                        ),
                      ),
                      Text(
                        "\$240.00",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B4423),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Sub-Total (Combined with ItemValue in design)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "Sub-Total:",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B4423),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Delivery Fee
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "Delivery Fee:",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B4423),
                        ),
                      ),
                      Text(
                        "\$25.00",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B4423),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Discount
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "Discount:",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B4423),
                        ),
                      ),
                      Text(
                        "-\$50.00",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B4423),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  
                  const Divider(color: Color(0xFFD4C0AD), thickness: 1),
                  const SizedBox(height: 10),
                  
                  // Total Cost
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "Total Cost:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B4423),
                        ),
                      ),
                      Text(
                        "\$190.00",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6B4423),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedNavIndex,
          onTap: (index) {
            setState(() {
              _selectedNavIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFFD4924D),
          unselectedItemColor: const Color(0xFFB8A99A),
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              activeIcon: Icon(Icons.favorite),
              label: 'Favorites',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_outlined),
              activeIcon: Icon(Icons.notifications),
              label: 'Notifications',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.view_in_ar_outlined),
              activeIcon: Icon(Icons.view_in_ar),
              label: '3D model',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              activeIcon: Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}