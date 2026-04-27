import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/cart_usecases.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final GetCartItemsUseCase getCartItems;
  final UpdateQuantityUseCase updateQuantity;
  final RemoveItemUseCase removeItem;
  final GetCartSummaryUseCase getCartSummary;
  final ApplyPromoCodeUseCase applyPromoCode;

  String? _appliedPromoCode;

  CartBloc({
    required this.getCartItems,
    required this.updateQuantity,
    required this.removeItem,
    required this.getCartSummary,
    required this.applyPromoCode,
  }) : super(CartInitial()) {
    on<LoadCartEvent>(_onLoadCart);
    on<UpdateQuantityEvent>(_onUpdateQuantity);
    on<RemoveItemEvent>(_onRemoveItem);
    on<ApplyPromoCodeEvent>(_onApplyPromoCode);
    on<ShareCartEvent>(_onShareCart);
  }

  Future<void> _onLoadCart(LoadCartEvent event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final items = await getCartItems();
      final summary = await getCartSummary(_appliedPromoCode);
      emit(CartLoaded(
        items: items,
        summary: summary,
        appliedPromoCode: _appliedPromoCode,
      ));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onUpdateQuantity(
      UpdateQuantityEvent event, Emitter<CartState> emit) async {
    if (event.quantity < 1) return;
    await updateQuantity(event.itemId, event.quantity);
    add(LoadCartEvent());
  }

  Future<void> _onRemoveItem(
      RemoveItemEvent event, Emitter<CartState> emit) async {
    await removeItem(event.itemId);
    add(LoadCartEvent());
  }

  Future<void> _onApplyPromoCode(
      ApplyPromoCodeEvent event, Emitter<CartState> emit) async {
    final success = await applyPromoCode(event.code);
    if (success) _appliedPromoCode = event.code;
    add(LoadCartEvent());
  }

  void _onShareCart(ShareCartEvent event, Emitter<CartState> emit) {
    if (state is CartLoaded) {
      final current = state as CartLoaded;
      emit(current.copyWith(isShareVisible: !current.isShareVisible));
    }
  }
}
