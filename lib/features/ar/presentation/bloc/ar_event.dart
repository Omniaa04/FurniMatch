abstract class ArEvent {}

class LoadArModelEvent extends ArEvent {
  final int productId;
  LoadArModelEvent(this.productId);
}