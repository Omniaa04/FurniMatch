abstract class CartEvent {}

class LoadCartEvent extends CartEvent {}

class UpdateQuantityEvent extends CartEvent {
  final String itemId;
  final int quantity;
  UpdateQuantityEvent(this.itemId, this.quantity);
}

class RemoveItemEvent extends CartEvent {
  final String itemId;
  RemoveItemEvent(this.itemId);
}

class ApplyPromoCodeEvent extends CartEvent {
  final String code;
  ApplyPromoCodeEvent(this.code);
}

class ShareCartEvent extends CartEvent {}
