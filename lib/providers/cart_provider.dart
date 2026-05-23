import 'dart:async';

import 'package:flutter/material.dart';
import 'package:furnimatch/features/cart/services/cart_services.dart';

class CartProvider with ChangeNotifier {
  final CartService _cartService = CartService();
  int _cartCount = 0;
  bool _isLoading = false;
  
  // Add these flags
  bool _isUpdating = false;
  Timer? _updateTimer;

  int get cartCount => _cartCount;
  bool get isLoading => _isLoading;

  // Safe notify method that avoids build-time updates
  void _safeNotify() {
    // Use addPostFrameCallback to schedule notification after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isUpdating) {
        notifyListeners();
      }
    });
  }

  // Fetch cart count from backend
  Future<void> fetchCartCount(int userId) async {
    if (userId == 0) return;
    
    // Prevent multiple simultaneous updates
    if (_isUpdating) return;
    
    _isUpdating = true;
    _isLoading = true;
    _safeNotify();

    try {
      _cartCount = await _cartService.getCartCount(userId);
    } catch (e) {
      print('Error fetching cart count: $e');
    } finally {
      _isLoading = false;
      _isUpdating = false;
      _safeNotify();
    }
  }

  // Add to cart and update count
  Future<bool> addToCart(int userId, int productId, int quantity) async {
    if (_isUpdating) return false;
    
    try {
      bool success = await _cartService.addToCart(userId, productId, quantity);
      
      if (success) {
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
    if (_isUpdating) return false;
    
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
    if (_isUpdating) return false;
    
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
  void resetCartCount(int i) {
    _cartCount = 0;
    _isLoading = false;
    _isUpdating = false;
    if (_updateTimer?.isActive == true) {
      _updateTimer?.cancel();
    }
    notifyListeners();
  }
  
  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }
}