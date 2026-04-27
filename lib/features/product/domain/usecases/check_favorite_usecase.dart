import '../repositories/product_details_repository.dart';

class CheckFavoriteUseCase {
  final ProductDetailsRepository repository;

  CheckFavoriteUseCase(this.repository);

  Future<bool> call({
    required int userId,
    required int productId,
  }) {
    return repository.checkFavorite(
      userId: userId,
      productId: productId,
    );
  }
}