class CartSummary {
  final double subTotal;
  final double deliveryFee;
  final double discount;

  const CartSummary({
    required this.subTotal,
    required this.deliveryFee,
    required this.discount,
  });

  double get totalCost => subTotal + deliveryFee - discount;
}
