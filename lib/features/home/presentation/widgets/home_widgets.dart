import 'package:flutter/material.dart';
import 'package:furnimatch/features/home/data/models/home_repository.dart';
import 'package:furnimatch/features/home/presentation/pages/category_products_page.dart';

class SearchBarWidget extends StatelessWidget {
  final VoidCallback onFavPressed;
  final VoidCallback onSearchPressed;

  const SearchBarWidget({
    super.key,
    required this.onFavPressed,
    required this.onSearchPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onSearchPressed,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFEFE9E2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const AbsorbPointer(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Chair, desk, lamp, etc",
                    prefixIcon:
                        Icon(Icons.search, size: 22, color: Colors.black54),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        InkWell(
          onTap: onFavPressed,
          child: Container(
            height: 50,
            width: 50,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_border,
              color: Color(0xFF7D533D),
              size: 22,
            ),
          ),
        ),
      ],
    );
  }
}

class CategoryBox extends StatelessWidget {
  final String title;
  final String imgPath;
  final Color color;
  final int? userId;
  final String? userName;

  const CategoryBox({
    super.key,
    required this.title,
    required this.imgPath,
    required this.color,
    this.userId,
    this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CategoryProductsPage(
            categoryName: title,
            userId: userId,
            userName: userName,
          ),
        ),
      ),
      child: Container(
        width: 185,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 15,
              top: 0,
              bottom: 0,
              child: SizedBox(
                width: 95,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF7D533D),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              top: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
                child: Image.asset(
                  imgPath,
                  width: 75,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(width: 75, color: Colors.black12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SliderItem extends StatelessWidget {
  final String title;
  final String btnText;
  final String imgPath;
  final VoidCallback onPressed;

  const SliderItem({
    super.key,
    required this.title,
    required this.btnText,
    required this.imgPath,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: AssetImage(imgPath),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.05),
            BlendMode.darken,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF7D533D),
              fontSize: 18,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFAD8B73),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              btnText,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class ProductCardWidget extends StatelessWidget {
  final Product product;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;
  final VoidCallback onAddToCart;
  final Color Function(String) hexToColor;

  const ProductCardWidget({
    super.key,
    required this.product,
    required this.isFavorite,
    required this.onFavoriteTap,
    required this.onAddToCart,
    required this.hexToColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Expanded(flex: 6, child: buildImageSection()),
          Expanded(flex: 6, child: buildInfoSection()),
        ],
      ),
    );
  }

  Widget buildImageSection() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(22),
            topRight: Radius.circular(22),
          ),
          child: Container(
            width: double.infinity,
            color: const Color(0xFFF4EFE5),
            child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                ? Image.network(
                    product.imageUrl!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    headers: const {"ngrok-skip-browser-warning": "true"},
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(Icons.image, color: Colors.brown, size: 40),
                    ),
                  )
                : const Center(
                    child: Icon(Icons.image, color: Colors.brown, size: 40),
                  ),
          ),
        ),
        if (product.isOutOfStock)
          const StockBadge(
            label: "Out of Stock",
            bg: Color(0xFFFFE0E0),
            textColor: Colors.red,
          ),
        if (product.isLowStock)
          const StockBadge(
            label: "Low Stock",
            bg: Colors.white,
            textColor: Colors.grey,
          ),
        if (product.onSale)
          const Positioned(
            top: 12,
            right: 12,
            child: SaleBadge(),
          ),
        Positioned(
          bottom: 10,
          left: 12,
          child: Row(
            children: product.colors.take(5).map((colorHex) {
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ColorDot(color: hexToColor(colorHex)),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget buildInfoSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF2C2C2C),
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            product.description,
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
              Expanded(
                child: ProductPriceText(product: product),
              ),
              GestureDetector(
                onTap: onAddToCart,
                child: Container(
                  height: 34,
                  width: 34,
                  decoration: BoxDecoration(
                    color: product.isOutOfStock
                        ? Colors.grey.shade300
                        : const Color(0xFF7D533D),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_shopping_cart,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onFavoriteTap,
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : const Color(0xFF7D533D),
                  size: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ProductPriceText extends StatelessWidget {
  final Product product;

  const ProductPriceText({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    if (!product.onSale) {
      return Text(
        "\$ ${product.price}",
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
          "\$ ${product.price}",
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
            decoration: TextDecoration.lineThrough,
            decorationThickness: 2,
          ),
        ),
        Text(
          "\$ ${product.salePrice}",
          style: const TextStyle(
            color: Colors.orange,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class StockBadge extends StatelessWidget {
  final String label;
  final Color bg;
  final Color textColor;

  const StockBadge({
    super.key,
    required this.label,
    required this.bg,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 12,
      left: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}

class SaleBadge extends StatelessWidget {
  const SaleBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Text(
        "SALE",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }
}

class ColorDot extends StatelessWidget {
  final Color color;

  const ColorDot({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 13,
      height: 13,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
    );
  }
}

class DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color iconColor;
  final Color textColor;

  const DrawerItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor = const Color(0xFF7D533D),
    this.textColor = const Color(0xFF7D533D),
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: textColor),
      onTap: onTap,
    );
  }
}

class TopButton extends StatelessWidget {
  final String label;
  final Color bg;
  final Color textColor;
  final bool isOutlined;
  final VoidCallback onPressed;

  const TopButton({
    super.key,
    required this.label,
    required this.bg,
    required this.textColor,
    this.isOutlined = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        elevation: 0,
        minimumSize: const Size(58, 36),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        side: isOutlined ? const BorderSide(color: Color(0xFF7D533D)) : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.visible,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
