import 'package:flutter/material.dart';
import 'package:furnimatch/features/home/data/models/home_repository.dart';
import 'package:furnimatch/providers/cart_provider.dart';

class HomeController extends ChangeNotifier {
  final HomeRepository repo;

  HomeController({required this.repo});

  bool _disposed = false;
  int unreadNotifCount = 0;

  int? userId;
  String? userName;
  bool isLoggedIn = false;

  List<Product> products = [];
  bool isLoadingProducts = true;
  String? productsErrorMessage; // null = مفيش مشكلة، فيه نص = فشل اتصال فعلي
  Set<int> favoriteIds = {};
  int unreadCount = 0;

  //  Override notifyListeners to check disposed
  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  Future<void> loadUnreadNotifCount() async {
    if (userId == null) return;
    unreadNotifCount = await repo.fetchUnreadNotifCount(userId!);
    notifyListeners();
  }

  // Override dispose
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void init({int? id, String? name, required CartProvider cartProvider}) {
    userId = id;
    userName = name;
    isLoggedIn = id != null;
    loadInitialData(cartProvider);
  }

  Future<void> loadInitialData(CartProvider cartProvider) async {
    final futures = <Future>[
      loadProducts(),
      loadUserData(cartProvider),
    ];
    await Future.wait(futures);
  }

  Future<void> loadUserData(CartProvider cartProvider) async {
    if (userId == null) return;

    await Future.wait([
      loadFavorites(),
      loadUnreadCount(),
      loadUnreadNotifCount(),
      cartProvider.fetchCartCount(userId!),
    ]);
  }

  Future<void> loadProducts() async {
    isLoadingProducts = true;
    productsErrorMessage = null;
    notifyListeners();

    try {
      products = await repo.fetchAllProducts();
    } on NetworkTimeoutException catch (e) {
      productsErrorMessage = e.message;
      products = [];
    } on NetworkUnavailableException catch (e) {
      productsErrorMessage = e.message;
      products = [];
    } catch (_) {
      productsErrorMessage = 'حصل خطأ غير متوقع';
      products = [];
    }

    isLoadingProducts = false;
    notifyListeners();
  }

  Future<void> loadFavorites() async {
    if (userId == null) {
      favoriteIds = {};
      notifyListeners();
      return;
    }

    favoriteIds = await repo.fetchFavoriteIds(userId!);
    notifyListeners();
  }

  Future<void> loadUnreadCount() async {
    if (userId == null) return;

    unreadCount = await repo.fetchUnreadCount(userId!);
    notifyListeners();
  }

  Future<String> toggleFavorite(Product product) async {
    if (userId == null) return "Please log in first!";

    try {
      final result = await repo.toggleFavorite(
        userId: userId!,
        productId: product.id,
      );

      final isFav = result.$1;
      final message = result.$2;

      if (isFav) {
        favoriteIds.add(product.id);
      } else {
        favoriteIds.remove(product.id);
      }

      notifyListeners();
      return message;
    } catch (_) {
      return "Something went wrong";
    }
  }

  Future<String> addProductToCart(
    Product product,
    CartProvider cartProvider,
  ) async {
    if (userId == null) return "Please log in first!";
    if (product.isOutOfStock) return "Sorry, this product is out of stock!";

    final success = await cartProvider.addToCart(userId!, product.id, 1);

    return success
        ? "Added to cart successfully ✅"
        : "Could not add item to cart";
  }

  void login(Map result, CartProvider cartProvider) {
    userId = int.tryParse('${result['user_id']}');
    userName = result['name'];
    isLoggedIn = true;
    notifyListeners();

    loadUserData(cartProvider);
  }

  void updateName(String name) {
    userName = name;
    notifyListeners();
  }

  void logout(CartProvider cartProvider) {
    final currentUserId = userId;
    userId = null;
    userName = null;
    isLoggedIn = false;
    unreadCount = 0;
    favoriteIds.clear();
    if (currentUserId != null) {
      cartProvider.resetCartCount(currentUserId);
    }
    notifyListeners();
  }
}