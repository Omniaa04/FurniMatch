import 'package:flutter/material.dart';

class OrderItemsList extends StatelessWidget {
  const OrderItemsList({super.key});


  final List<Map<String, String>> items = const [
    {
      'name': 'Comfort Chair Set',
      'price': '\$69.99',
      'image': 'assets/images/chair.png',
    },
    {
      'name': 'Comfort Chair Set',
      'price': '\$69.99',
      'image': 'assets/images/chair2.jpg',
    },
    {
      'name': 'Comfort Chair Set',
      'price': '\$69.99',
      'image': 'assets/images/chair3.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: items.map((item) => Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: _buildOrderItemCard(
          name: item['name']!,
          price: item['price']!,
          imagePath: item['image']!,
        ),
      )).toList(),
    );
  }

  Widget _buildOrderItemCard({
    required String name,
    required String price,
    required String imagePath,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1), 
          ),
        ],
      ),
      child: Row(
        children: [
     
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              imagePath,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            
              errorBuilder: (context, error, stackTrace) {
                print('❌ Error loading image: $imagePath');
                print('Error details: $error');
                return Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0A346).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.chair_outlined,
                    color: Color(0xFFF0A346),
                    size: 30,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: const TextStyle(
                    color: Color(0xFFD47222),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}