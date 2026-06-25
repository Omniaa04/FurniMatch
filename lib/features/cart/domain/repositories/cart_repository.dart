import '../entities/cart_item.dart';
import '../entities/cart_summary.dart';

abstract class CartRepository {
  Future<List<CartItem>> getCartItems();
  Future<void> updateQuantity(String itemId, int quantity);
  Future<void> removeItem(String itemId);
  Future<CartSummary> getCartSummary(String? promoCode);
  Future<bool> applyPromoCode(String code);
}
