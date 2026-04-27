import 'package:flutter/material.dart';
import 'package:furnimatch/features/buttom_nav/CustomBottomNav.dart';
import 'package:furnimatch/features/buttom_nav/main_shell.dart';
import 'package:furnimatch/features/home/data/models/home_repository.dart';
import 'package:furnimatch/features/product/presentation/pages/product_details_page.dart';

class CategoryProductsPage extends StatefulWidget {
  final String categoryName;
  final int? userId;
  final String? userName;

  const CategoryProductsPage({
    super.key,
    required this.categoryName,
    this.userId,
    this.userName,
  });

  @override
  State<CategoryProductsPage> createState() => _CategoryProductsPageState();
}

class _CategoryProductsPageState extends State<CategoryProductsPage> {
  // ── Colors ──
  static const Color _darkBrown = Color(0xFF7D533D);
  static const Color _bgColor = Color(0xFFF6F0E9);
  // ── State ──
  final _repo = HomeRepository();
  List<Product> _products = [];
  Set<int> _favoriteIds = {};
  bool _isLoading = true;
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ── Data ──

  Future<void> _loadData() async {
    await Future.wait([
      _loadProducts(),
      if (widget.userId != null) _loadFavorites(),
    ]);
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    final products = await _repo.fetchCategoryProducts(widget.categoryName);
    if (mounted)
      setState(() {
        _products = products;
        _isLoading = false;
      });
  }

  Future<void> _loadFavorites() async {
    if (widget.userId == null) {
      setState(() => _favoriteIds = {});
      return;
    }
    final ids = await _repo.fetchFavoriteIds(widget.userId!);
    if (mounted) setState(() => _favoriteIds = ids);
  }

  Future<void> _toggleFavorite(Product product) async {
    if (widget.userId == null) {
      _showSnack("Please log in first!");
      return;
    }
    try {
      final (isFav, msg) = await _repo.toggleFavorite(
        userId: widget.userId!,
        productId: product.id,
      );
      if (mounted) {
        setState(() {
          if (isFav) {
            _favoriteIds.add(product.id);
          } else {
            _favoriteIds.remove(product.id);
          }
        });
        _showSnack(msg);
      }
    } catch (_) {
      _showSnack("Something went wrong");
    }
  }

  // ── Navigation ──

  void _onBottomNavTap(int index) {
    setState(() => _currentNavIndex = index);
    MainShell.openTab(
      context,
      index: index,
      userId: widget.userId,
      userName: widget.userName,
    );
  }

  // ── Helpers ──

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: _darkBrown, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.categoryName,
          style: const TextStyle(
            color: _darkBrown,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.brown));
    }
    if (_products.isEmpty) {
      return Center(
        child: Text(
          'No products found',
          style: const TextStyle(color: _darkBrown, fontSize: 16),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      child: GridView.builder(
        itemCount: _products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 18,
          childAspectRatio: 0.56,
        ),
        itemBuilder: (_, i) {
          final product = _products[i];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetailsPage(
                    product: product.raw,
                    userId: widget.userId,
                    userName: widget.userName,
                  ),
                ),
              ).then((_) => _loadFavorites());
            },
            child: _CategoryProductCard(
              product: product,
              isFavorite: _favoriteIds.contains(product.id),
              onFavoriteTap: () => _toggleFavorite(product),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomNav() {
    return CustomBottomNav(
      currentIndex: _currentNavIndex,
       notifCount: 0,
      onTap: _onBottomNavTap,
    );
  }
}

// ─── Private Widget ──────────────────────────────────────────

class _CategoryProductCard extends StatelessWidget {
  final Product product;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;

  const _CategoryProductCard({
    required this.product,
    required this.isFavorite,
    required this.onFavoriteTap,
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
          Expanded(flex: 6, child: _buildImageSection()),
          Expanded(flex: 5, child: _buildInfoSection()),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
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
                        child:
                            Icon(Icons.image, color: Colors.brown, size: 40)),
                  )
                : const Center(
                    child: Icon(Icons.image, color: Colors.brown, size: 40)),
          ),
        ),
        if (product.isOutOfStock)
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(18)),
              child: const Text("Out of Stock",
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w700,
                      fontSize: 12)),
            ),
          )
        else if (product.isLowStock)
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(18)),
              child: const Text("Low Stock",
                  style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w700,
                      fontSize: 12)),
            ),
          ),
        if (product.onSale)
          Positioned(
            top: 12,
            right: 12,
            child: Container(
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
            ),
          ),
      ],
    );
  }

  Widget _buildInfoSection() {
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
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(
            product.description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: 13, height: 1.3, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: product.onSale
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '\$${product.price}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                              decorationThickness: 2,
                            ),
                          ),
                          Text(
                            '\$${product.salePrice}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      )
                    : Text('\$${product.price}',
                        style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
              ),
              GestureDetector(
                onTap: onFavoriteTap,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                      color: Color(0xFFFFF1F1), shape: BoxShape.circle),
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: product.isOutOfStock
                      ? Colors.grey.shade300
                      : const Color(0xFF7D533D),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add_shopping_cart,
                  color: product.isOutOfStock ? Colors.white : Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
