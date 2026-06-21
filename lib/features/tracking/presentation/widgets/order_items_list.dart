// import 'package:flutter/material.dart';

// class OrderItemsList extends StatelessWidget {
//   final List<Map<String, dynamic>> items;

//   const OrderItemsList({
//     super.key,
//     required this.items,
//   });

//   @override
//   Widget build(BuildContext context) {
//     if (items.isEmpty) {
//       return const SizedBox();
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: items.map((item) {
//         return Padding(
//           padding: const EdgeInsets.only(bottom: 12),
//           child: _buildOrderItemCard(
//             name: item['product_name']?.toString() ?? 'Product',
//             price: item['price']?.toString() ?? '0',
//             imageUrl: item['image_url']?.toString() ?? '',
//           ),
//         );
//       }).toList(),
//     );
//   }

//   Widget _buildOrderItemCard({
//     required String name,
//     required String price,
//     required String imageUrl,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             spreadRadius: 1,
//             blurRadius: 5,
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(10),
//             child: imageUrl.isNotEmpty
//                 ? Image.network(
//                     imageUrl,
//                     width: 74,
//                     height: 74,
//                     fit: BoxFit.cover,
//                     headers: const {
//                       'ngrok-skip-browser-warning': 'true',
//                     },
//                     errorBuilder: (_, __, ___) => _fallbackImage(),
//                   )
//                 : _fallbackImage(),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   name,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   '\$$price',
//                   style: const TextStyle(
//                     color: Color(0xFFD47222),
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _fallbackImage() {
//     return Container(
//       width: 74,
//       height: 74,
//       color: const Color(0xFFF6F0E9),
//       child: const Icon(
//         Icons.chair_outlined,
//         color: Color(0xFFEBA46E),
//         size: 34,
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

class OrderItemsList extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const OrderItemsList({
    super.key,
    required this.items,
  });

  static const Color darkBrown = Color(0xFF7D533D);
  static const Color bgColor = Color(0xFFF6F0E9);
  static const Color accent = Color(0xFFEBA46E);

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildOrderItemCard(
            name: item['product_name']?.toString() ?? 'Product',
            price: item['price']?.toString() ?? '0',
            imageUrl: item['image_url']?.toString() ?? '',
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOrderItemCard({
    required String name,
    required String price,
    required String imageUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    width: 82,
                    height: 82,
                    fit: BoxFit.cover,
                    headers: const {
                      'ngrok-skip-browser-warning': 'true',
                    },
                    errorBuilder: (_, __, ___) => _fallbackImage(),
                  )
                : _fallbackImage(),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: darkBrown,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$$price',
                  style: const TextStyle(
                    color: accent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallbackImage() {
    return Container(
      width: 82,
      height: 82,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(
        Icons.chair_outlined,
        color: accent,
        size: 36,
      ),
    );
  }
}