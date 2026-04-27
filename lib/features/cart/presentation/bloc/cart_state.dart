import '../../domain/entities/cart_item.dart';
import '../../domain/entities/cart_summary.dart';

abstract class CartState {}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<CartItem> items;
  final CartSummary summary;
  final String? appliedPromoCode;
  final bool isShareVisible;

  CartLoaded({
    required this.items,
    required this.summary,
    this.appliedPromoCode,
    this.isShareVisible = false,
  });

  CartLoaded copyWith({
    List<CartItem>? items,
    CartSummary? summary,
    String? appliedPromoCode,
    bool? isShareVisible,
  }) {
    return CartLoaded(
      items: items ?? this.items,
      summary: summary ?? this.summary,
      appliedPromoCode: appliedPromoCode ?? this.appliedPromoCode,
      isShareVisible: isShareVisible ?? this.isShareVisible,
    );
  }
}

class CartError extends CartState {
  final String message;
  CartError(this.message);
}

class PromoCodeApplied extends CartState {
  final bool success;
  PromoCodeApplied(this.success);
}
