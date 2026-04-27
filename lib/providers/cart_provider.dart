import 'package:flutter/material.dart';
import 'package:furnimatch/features/cart/services/cart_services.dart';


class CartProvider with ChangeNotifier {
  final CartService _cartService = CartService();
  int _cartCount = 0;
  bool _isLoading = false;

  int get cartCount => _cartCount;
  bool get isLoading => _isLoading;

  // Fetch cart count from backend
  Future<void> fetchCartCount(int userId) async {
    if (userId == 0) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      _cartCount = await _cartService.getCartCount(userId);
    } catch (e) {
      print('Error fetching cart count: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add to cart and update count
  Future<bool> addToCart(int userId, int productId, int quantity) async {
    try {
      bool success = await _cartService.addToCart(userId, productId, quantity);
      
      if (success) {
        // Refresh cart count
        await fetchCartCount(userId);
        return true;
      }
      return false;
    } catch (e) {
      print('Error in addToCart: $e');
      return false;
    }
  }

  // Remove from cart and update count
  Future<bool> removeFromCart(int userId, int cartId) async {
    try {
      bool success = await _cartService.removeFromCart(cartId);
      
      if (success) {
        await fetchCartCount(userId);
        return true;
      }
      return false;
    } catch (e) {
      print('Error in removeFromCart: $e');
      return false;
    }
  }

  // Update quantity and refresh count
  Future<bool> updateQuantity(int userId, int cartId, int quantity) async {
    try {
      bool success = await _cartService.updateQuantity(cartId, quantity);
      
      if (success) {
        await fetchCartCount(userId);
        return true;
      }
      return false;
    } catch (e) {
      print('Error in updateQuantity: $e');
      return false;
    }
  }

  // Reset cart count (for logout)
  void resetCartCount() {
    _cartCount = 0;
    notifyListeners();
  }
}