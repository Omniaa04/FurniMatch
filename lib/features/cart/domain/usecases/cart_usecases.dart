import '../entities/cart_item.dart';
import '../entities/cart_summary.dart';
import '../repositories/cart_repository.dart';

class GetCartItemsUseCase {
  final CartRepository repository;
  GetCartItemsUseCase(this.repository);
  Future<List<CartItem>> call() => repository.getCartItems();
}

class UpdateQuantityUseCase {
  final CartRepository repository;
  UpdateQuantityUseCase(this.repository);
  Future<void> call(String itemId, int quantity) =>
      repository.updateQuantity(itemId, quantity);
}

class RemoveItemUseCase {
  final CartRepository repository;
  RemoveItemUseCase(this.repository);
  Future<void> call(String itemId) => repository.removeItem(itemId);
}

class GetCartSummaryUseCase {
  final CartRepository repository;
  GetCartSummaryUseCase(this.repository);
  Future<CartSummary> call(String? promoCode) =>
      repository.getCartSummary(promoCode);
}

class ApplyPromoCodeUseCase {
  final CartRepository repository;
  ApplyPromoCodeUseCase(this.repository);
  Future<bool> call(String code) => repository.applyPromoCode(code);
}
