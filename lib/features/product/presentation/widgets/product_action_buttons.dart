import 'package:flutter/material.dart';

class ProductActionButtons extends StatelessWidget {
  final bool isFavorite;
  final bool isCheckingFavorite;
  final VoidCallback onAddToCart;
  final VoidCallback onToggleFavorite;

  const ProductActionButtons({
    super.key,
    required this.isFavorite,
    required this.isCheckingFavorite,
    required this.onAddToCart,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _squareIconButton(
          icon: Icons.shopping_cart_outlined,
          onTap: onAddToCart,
        ),
        const SizedBox(width: 8),
        _squareIconButton(
          icon: isFavorite ? Icons.favorite : Icons.favorite_border,
          onTap: isCheckingFavorite ? () {} : onToggleFavorite,
        ),
      ],
    );
  }

  Widget _squareIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF8B5E3C), width: 1.6),
        ),
        child: Icon(
          icon,
          color: const Color(0xFF8B5E3C),
          size: 26,
        ),
      ),
    );
  }
}
