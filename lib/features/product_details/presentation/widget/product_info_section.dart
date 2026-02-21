import 'package:flutter/material.dart';

class ProductInfoSection extends StatelessWidget {
  final String productName;
  final double rating;
  final String price;

  const ProductInfoSection({
    super.key,
    this.productName = 'Brown Comfy Mini Sofa',
    this.rating = 4.5,
    this.price = '\$80.0', 
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
 
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start, 
            children: [
          
              Expanded( 
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fluffy Sofa', 
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      productName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              Row(
                mainAxisSize: MainAxisSize.min, 
                children: [
            
                  _buildIconContainer(Icons.shopping_bag_outlined, isSelected: false),

                  const SizedBox(width: 10),

                  _buildIconContainer(Icons.favorite_border, isSelected: true),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 15),

          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 18),
              const SizedBox(width: 4),
              Text(
                '$rating',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          
         
          Text(
            price,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFFC7986B), 
            ),
          ),
          const SizedBox(height: 15),

          const Text(
            'A formal comfy and fluffy sofa for the affordable and luxurious feel. Perfect for long chats or quick snuggles for just the perfect occasions.',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: const Text(
              '',
              style: TextStyle(
                color: Color(0xFFC7986B),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  

  Widget _buildIconContainer(IconData icon, {required bool isSelected}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFF0EAE1) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Icon(
        icon,
        color: isSelected ? const Color(0xFFC7986B) : Colors.black87,
        size: 20,
      ),
    );
  }
}