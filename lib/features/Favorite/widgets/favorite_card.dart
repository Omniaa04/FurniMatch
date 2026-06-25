import 'package:flutter/material.dart';

class FavoriteCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final VoidCallback onAddToCart;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const FavoriteCard({
    super.key,
    required this.item,
    required this.onAddToCart,
    required this.onRemove,
    required this.onTap,
  });

  @override
  State<FavoriteCard> createState() => _FavoriteCardState();
}

class _FavoriteCardState extends State<FavoriteCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  final Color darkBrown = const Color(0xFF7D533D);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      lowerBound: 0.85,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = _animController;
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleRemove() async {
    await _animController.reverse();
    widget.onRemove();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final hasSale = _hasSalePrice(item);

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 6,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(22),
                      topRight: Radius.circular(22),
                    ),
                    child: SizedBox.expand(
                      child: item['image_url'] != null &&
                              item['image_url'].toString().isNotEmpty
                          ? Image.network(
                              item['image_url'],
                              fit: BoxFit.cover,
                              headers: const {
                                "ngrok-skip-browser-warning": "true"
                              },
                              errorBuilder: (_, __, ___) => Container(
                                color: const Color(0xFFF0EAE3),
                                child: const Icon(
                                  Icons.image_not_supported_outlined,
                                  color: Colors.brown,
                                  size: 32,
                                ),
                              ),
                            )
                          : Container(
                              color: const Color(0xFFF0EAE3),
                              child: const Icon(
                                Icons.image_not_supported_outlined,
                                color: Colors.brown,
                                size: 32,
                              ),
                            ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: _handleRemove,
                      child: ScaleTransition(
                        scale: _scaleAnim,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFF1F1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.favorite,
                            size: 18,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (hasSale)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE7D4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'SALE',
                          style: TextStyle(
                            color: Color(0xFFEBA46E),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['description']?.toString() ??
                          item['category']?.toString() ??
                          '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(child: _PriceText(item: item)),
                        GestureDetector(
                          onTap: widget.onAddToCart,
                          child: Container(
                            height: 34,
                            width: 34,
                            decoration: const BoxDecoration(
                              color: Color(0xFF7D533D),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add_shopping_cart,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasSalePrice(Map<String, dynamic> item) {
    final salePrice = item['sale_price'];
    if (salePrice == null) return false;
    final value = double.tryParse(salePrice.toString());
    return value != null && value > 0;
  }
}

class _PriceText extends StatelessWidget {
  final Map<String, dynamic> item;

  const _PriceText({required this.item});

  @override
  Widget build(BuildContext context) {
    final salePrice = double.tryParse(item['sale_price']?.toString() ?? '');
    if (salePrice == null || salePrice <= 0) {
      return Text(
        '\$ ${_formatPrice(item['price'])}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Color(0xFF7D533D),
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '\$ ${_formatPrice(item['price'])}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
            decoration: TextDecoration.lineThrough,
            decorationThickness: 2,
          ),
        ),
        Text(
          '\$ ${_formatPrice(item['sale_price'])}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.orange,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _formatPrice(dynamic price) {
    final value = double.tryParse(price?.toString() ?? '');
    if (value == null) return '${price ?? ''}';
    if (value == value.roundToDouble()) return value.toStringAsFixed(0);
    return value.toStringAsFixed(2);
  }
}
