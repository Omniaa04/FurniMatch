import '../repositories/product_details_repository.dart';

class BuyProductUseCase {
  final ProductDetailsRepository repository;

  BuyProductUseCase(this.repository);

  Future<void> call({
    required int productId,
    required int customerId,
    required String customerName,
  }) {
    return repository.buyProduct(
      productId: productId,
      customerId: customerId,
      customerName: customerName,
    );
  }
}