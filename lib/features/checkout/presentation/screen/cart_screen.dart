import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> cartItems = [
    CartItem(
      id: '1',
      name: 'Brown Comfy Mini Sofa',
      category: 'Sofa',
      price: 80.00,
      image: 'lib/assets/images/brown_sofa.png',
      quantity: 1,
    ),
    CartItem(
      id: '2',
      name: 'Blue Study Sofa',
      category: 'Sofa',
      price: 65.00,
      image: 'lib/assets/images/blue_sofa.png',
      quantity: 1,
    ),
    CartItem(
      id: '3',
      name: 'Green Casual Sofa',
      category: 'Sofa',
      price: 95.00,
      image: 'lib/assets/images/green_sofa.png',
      quantity: 1,
    ),
  ];

  double deliveryFee = 25;
  double discount = 50;

  double get subtotal =>
      cartItems.fold(0, (sum, i) => sum + i.price * i.quantity);

  double get totalCost => subtotal + deliveryFee - discount;

  void _removeItem(CartItem item) {
    setState(() => cartItems.remove(item));
  }

  void _shareCart() {
    final text = cartItems
        .map((e) => '${e.name} x${e.quantity} - \$${e.price}')
        .join('\n');

    Share.share(
      'My Cart:\n\n$text\n\nTotal: \$${totalCost.toStringAsFixed(2)}',
    );
  }

  void _showRemoveDialog(CartItem item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                const Text(
                  'Remove from Cart?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B4423),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Product Card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F0E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      // Product Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          item.image,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 70,
                              height: 70,
                              color: const Color(0xFFE8D5C4),
                              child: const Icon(
                                Icons.chair,
                                size: 30,
                                color: Color(0xFF6B4423),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Product Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6B4423),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.category,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9B8471),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$ ${item.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6B4423),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 25),
                
                // Buttons Row
                Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFE8D5C4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Color(0xFF6B4423),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Yes, Remove Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _removeItem(item);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7D533D),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Yes, Remove',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F0E9),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF6F0E9),
        leading: const BackButton(color: Color(0xFF6B4423)),
        title: const Text(
          'My Cart',
          style: TextStyle(
            color: Color(0xFF6B4423),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Color(0xFF6B4423)),
            onPressed: _shareCart,
          ),
        ],
      ),

      body: Column(
        children: [
          /// CART LIST
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: cartItems.length,
              itemBuilder: (_, index) {
                final item = cartItems[index];

                return Dismissible(
                  key: ValueKey(item.id),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (_) async {
                    _showRemoveDialog(item);
                    return false;
                  },
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD6B8A2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: _cartItem(item),
                );
              },
            ),
          ),

          /// BOTTOM SECTION
          Container(
            padding: const EdgeInsets.fromLTRB(25, 30, 25, 40),
            decoration: const BoxDecoration(
              color: Color(0xFFE8D5C4),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(40),
              ),
            ),
            child: Column(
              children: [
                _summaryRow('Subtotal', subtotal),
                _summaryRow('Delivery', deliveryFee),
                _summaryRow('Discount', -discount),
                const Divider(height: 30),
                _summaryRow('Total', totalCost, isTotal: true),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 65,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B4423),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(35),
                      ),
                    ),
                    onPressed: () =>
                        Navigator.pushNamed(context, '/checkout'),
                    child: const Text(
                      'Proceed to Checkout',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cartItem(CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              item.image,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 80,
                  height: 80,
                  color: const Color(0xFFE8D5C4),
                  child: const Icon(Icons.chair, size: 40),
                );
              },
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6B4423),
                    )),
                Text(item.category,
                    style: const TextStyle(color: Color(0xFF9B8471))),
                Text('\$${item.price}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.add, size: 18),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF7D533D),
                  foregroundColor: Colors.white,
                ),
                onPressed: () => setState(() => item.quantity++),
              ),
              Text('${item.quantity}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.remove, size: 18),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFE8D5C4),
                ),
                onPressed: () {
                  if (item.quantity > 1) {
                    setState(() => item.quantity--);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, double value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: const Color(0xFF6B4423),
            ),
          ),
          Text(
            '\$${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: const Color(0xFF6B4423),
            ),
          ),
        ],
      ),
    );
  }
}

class CartItem {
  final String id;
  final String name;
  final String category;
  final double price;
  final String image;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.image,
    required this.quantity,
  });
}