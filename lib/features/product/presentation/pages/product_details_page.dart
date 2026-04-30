import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:furnimatch/providers/cart_provider.dart';
import 'package:furnimatch/features/ar/presentation/pages/ar_view_page.dart';
import 'package:furnimatch/features/buttom_nav/CustomBottomNav.dart';
import 'package:furnimatch/features/buttom_nav/main_shell.dart';

import '../../data/datasources/product_details_remote_datasource.dart';
import '../../data/repositories/product_details_repository_impl.dart';
import '../../domain/usecases/buy_product_usecase.dart';
import '../../domain/usecases/check_favorite_usecase.dart';
import '../../domain/usecases/toggle_favorite_usecase.dart';
import '../widgets/color_selector.dart';
import '../widgets/product_action_buttons.dart';
import '../widgets/product_image_header.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:furnimatch/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:furnimatch/features/cart/presentation/bloc/cart_event.dart';
import 'package:furnimatch/features/cart/injection_container.dart';
import 'package:furnimatch/features/cart/data/datasources/cart_local_datasource.dart';
// import 'package:furnimatch/features/cart/presentation/bloc/cart_bloc.dart';
// import 'package:furnimatch/features/cart/presentation/bloc/cart_event.dart';

class ProductDetailsPage extends StatefulWidget {
  final Map<String, dynamic> product;
  final int? userId;
  final String? userName;

  const ProductDetailsPage({
    super.key,
    required this.product,
    this.userId,
    this.userName,
  });

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int selectedColorIndex = 0;
  bool isFavorite = false;
  bool isCheckingFavorite = true;
  int currentIndex = 0;

  late final CheckFavoriteUseCase checkFavoriteUseCase;
  late final ToggleFavoriteUseCase toggleFavoriteUseCase;
  late final BuyProductUseCase buyProductUseCase;

  int get productId => int.tryParse('${widget.product['id']}') ?? 0;
  bool get isOutOfStock =>
      (int.tryParse('${widget.product['stock']}') ?? 0) <= 0;
  bool get hasSalePrice {
    final salePrice = widget.product['sale_price'];
    return salePrice != null && salePrice.toString().trim().isNotEmpty;
  }

  @override
  void initState() {
    super.initState();

    final repository = ProductDetailsRepositoryImpl(
      remoteDataSource: ProductDetailsRemoteDataSource(),
    );

    checkFavoriteUseCase = CheckFavoriteUseCase(repository);
    toggleFavoriteUseCase = ToggleFavoriteUseCase(repository);
    buyProductUseCase = BuyProductUseCase(repository);

    checkFavoriteStatus();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.userId != null) {
        context.read<CartProvider>().fetchCartCount(widget.userId!);
      }
    });
  }

  void showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> checkFavoriteStatus() async {
    if (widget.userId == null) {
      setState(() {
        isFavorite = false;
        isCheckingFavorite = false;
      });
      return;
    }

    try {
      final result = await checkFavoriteUseCase(
        userId: widget.userId!,
        productId: productId,
      );

      if (!mounted) return;

      setState(() {
        isFavorite = result;
        isCheckingFavorite = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isCheckingFavorite = false);
    }
  }

  Future<void> toggleFavorite() async {
    if (widget.userId == null) {
      showMessage("Please log in first!");
      return;
    }

    try {
      final result = await toggleFavoriteUseCase(
        userId: widget.userId!,
        productId: productId,
      );

      if (!mounted) return;

      setState(() => isFavorite = result);

      showMessage(isFavorite ? "Added to favorites" : "Removed from favorites");
    } catch (e) {
      if (!mounted) return;
      showMessage(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> buyProduct() async {
    if (widget.userId == null) {
      showMessage("Please log in first!");
      return;
    }

    if (isOutOfStock) {
      showMessage("Sorry, this product is out of stock!");
      return;
    }

    try {
      await buyProductUseCase(
        productId: productId,
        customerId: widget.userId!,
        customerName: widget.userName ?? 'Customer',
      );

      if (!mounted) return;

      showMessage("Order placed successfully! ✅");
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      showMessage(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> addToCartAndOpenCart() async {
  if (widget.userId == null) {
    showMessage("Please log in first!");
    return;
  }

  if (isOutOfStock) {
    showMessage("Sorry, this product is out of stock!");
    return;
  }

  try {
    final cartProvider = context.read<CartProvider>();

    final success = await cartProvider.addToCart(
      widget.userId!,
      productId,
      1,
    );

    if (!mounted) return;

    if (success) {
  await cartProvider.fetchCartCount(widget.userId!);

  sl<CartLocalDataSource>().setUserId(widget.userId!);
  context.read<CartBloc>().add(LoadCartEvent());

  showMessage("Added to cart successfully ✅");

  MainShell.openTab(
    context,
    index: 4,
    userId: widget.userId,
    userName: widget.userName,
  );
} else {
      showMessage("Could not add item to cart");
    }
  } catch (_) {
    if (!mounted) return;
    showMessage("Could not add item to cart");
  }
}

  void onBottomNavTap(int index) {
    MainShell.openTab(
      context,
      index: index,
      userId: widget.userId,
      userName: widget.userName,
    );
  }

  void openArPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ArViewPage(
          productId: productId,
          productName: widget.product['name']?.toString() ?? 'Product',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    const darkBrown = Color(0xFF8B5E3C);
    const bgColor = Color(0xFFF6F0E9);

    final List<dynamic> productColors =
        product['colors'] is List ? product['colors'] : [];

    if (productColors.isNotEmpty &&
        selectedColorIndex >= productColors.length) {
      selectedColorIndex = 0;
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProductImageHeader(
                      imageUrl: product['image_url']?.toString(),
                      onBack: () => Navigator.pop(context),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product['category']?.toString().isNotEmpty == true
                                ? product['category'].toString()
                                : "Furniture",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  product['name']?.toString() ?? '',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Row(
                                children: [
                                  Icon(Icons.star,
                                      color: Colors.amber, size: 22),
                                  SizedBox(width: 4),
                                  Text(
                                    "4.5",
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: _productPrice(product),
                              ),
                              ProductActionButtons(
                                isFavorite: isFavorite,
                                isCheckingFavorite: isCheckingFavorite,
                                onAddToCart: addToCartAndOpenCart,
                                onToggleFavorite: toggleFavorite,
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _stockBadge(product),
                          const SizedBox(height: 20),
                          const Text(
                            "Product Details",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            product['description']?.toString().isNotEmpty ==
                                    true
                                ? product['description'].toString()
                                : "No description available",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 28),
                          Row(
                            children: [
                              const Text(
                                "Select Color : ",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  productColors.isNotEmpty
                                      ? productColors[selectedColorIndex]
                                          .toString()
                                          .toUpperCase()
                                      : "No color",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: darkBrown,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ColorSelector(
                            colors: productColors,
                            selectedColorIndex: selectedColorIndex,
                            onColorSelected: (index) {
                              setState(() => selectedColorIndex = index);
                            },
                          ),
                          const SizedBox(height: 26),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: ElevatedButton(
                              onPressed: openArPage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: darkBrown,
                                elevation: 0,
                                minimumSize: const Size(double.infinity, 58),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(35),
                                ),
                              ),
                              child: const Text(
                                "Try in My Room",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, cartProvider, _) {
          return CustomBottomNav(
            currentIndex: currentIndex,
            notifCount: 0,
            cartCount: cartProvider.cartCount,
            onTap: onBottomNavTap,
          );
        },
      ),
    );
  }

  Widget _stockBadge(Map<String, dynamic> product) {
    final stock = int.tryParse('${product['stock']}') ?? 0;
    final inStock = stock > 0;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: inStock ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              inStock ? Icons.check_circle : Icons.cancel,
              color: inStock ? Colors.green : Colors.red,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              inStock ? "In Stock ($stock left)" : "Out of Stock",
              style: TextStyle(
                color: inStock ? Colors.green : Colors.red,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _productPrice(Map<String, dynamic> product) {
    if (!hasSalePrice) {
      return Text(
        "\$ ${product['price']}",
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "\$ ${product['price']}",
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
            decoration: TextDecoration.lineThrough,
            decorationThickness: 2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          "\$ ${product['sale_price']}",
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }
}
