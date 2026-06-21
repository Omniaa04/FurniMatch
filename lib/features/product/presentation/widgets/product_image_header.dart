import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductImageHeader extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback onBack;

  const ProductImageHeader({
    super.key,
    required this.imageUrl,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(26),
            bottomRight: Radius.circular(26),
          ),
          child: hasImage
              ? CachedNetworkImage(
                  imageUrl: imageUrl!,
                  width: double.infinity,
                  height: 370,
                  fit: BoxFit.cover,
                  memCacheWidth: 800, // الصورة دي أكبر فحجم الكاش أكبر شوية
                  httpHeaders: const {
                    "ngrok-skip-browser-warning": "true",
                  },
                  placeholder: (_, __) => Container(
                    width: double.infinity,
                    height: 370,
                    color: const Color(0xffe8cdb8),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.brown),
                    ),
                  ),
                  errorWidget: (_, __, ___) => _placeholder(),
                )
              : _placeholder(),
        ),
        Positioned(
          top: 18,
          left: 18,
          child: InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(30),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black12),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
            ),
          ),
        ),
      ],
    );
  }

  Widget _placeholder() {
    return Container(
      width: double.infinity,
      height: 370,
      color: const Color(0xffe8cdb8),
      child: const Center(
        child: Icon(Icons.image, size: 80, color: Colors.brown),
      ),
    );
  }
}