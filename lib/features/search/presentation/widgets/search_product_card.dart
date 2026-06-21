import 'package:flutter/material.dart';
import '../../domain/entities/search_product.dart';

class SearchProductCard extends StatelessWidget {
  final SearchProduct product;
  final VoidCallback onTap;

  const SearchProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color darkBrown = Color(0xFF7D533D);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    color: const Color(0xFFF4EFE5),
                    child: product.imageUrl.isNotEmpty
                        ? Image.network(
                            product.imageUrl,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            headers: const {
                              "ngrok-skip-browser-warning": "true",
                            },
                            errorBuilder: (c, e, s) => const Center(
                              child: Icon(
                                Icons.image,
                                color: Colors.brown,
                                size: 40,
                              ),
                            ),
                          )
                        : const Center(
                            child: Icon(
                              Icons.image,
                              color: Colors.brown,
                              size: 40,
                            ),
                          ),
                  ),
                  if (product.stock <= 0)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: _tag(
                        text: "Out",
                        bgColor: Colors.red.shade100,
                        textColor: Colors.red,
                      ),
                    )
                  else if (product.stock <= 5)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: _tag(
                        text: "Low",
                        bgColor: Colors.white,
                        textColor: Colors.grey,
                      ),
                    ),
                  if (product.salePrice != null)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: _tag(
                        text: "SALE",
                        bgColor: Colors.orange,
                        textColor: Colors.white,
                      ),
                    ),
                ],
              ),
            ),

            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      product.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.2,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const Spacer(),
                    if (product.salePrice != null)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${product.salePrice!.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
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

  Widget _tag({
    required String text,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }
}