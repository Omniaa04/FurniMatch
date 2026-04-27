import '../../domain/entities/cart_item.dart';
import '../../domain/entities/cart_summary.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_local_datasource.dart';

class CartRepositoryImpl implements CartRepository {
  final CartLocalDataSource localDataSource;

  CartRepositoryImpl(this.localDataSource);

  @override
  Future<List<CartItem>> getCartItems() => localDataSource.getCartItems();

  @override
  Future<void> updateQuantity(String itemId, int quantity) =>
      localDataSource.updateQuantity(itemId, quantity);

  @override
  Future<void> removeItem(String itemId) =>
      localDataSource.removeItem(itemId);

  @override
  Future<CartSummary> getCartSummary(String? promoCode) async {
    final items = await localDataSource.getCartItems();
    final subTotal = items.fold<double>(
        0, (sum, item) => sum + item.price * item.quantity);
    const deliveryFee = 25.0;
    final discount = (promoCode == 'SAVE50') ? 50.0 : 0.0;
    return CartSummary(
        subTotal: subTotal, deliveryFee: deliveryFee, discount: discount);
  }

  @override
  Future<bool> applyPromoCode(String code) async {
    return code == 'SAVE50';
  }
}
