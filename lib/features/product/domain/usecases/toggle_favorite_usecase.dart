import '../repositories/product_details_repository.dart';

class ToggleFavoriteUseCase {
  final ProductDetailsRepository repository;

  ToggleFavoriteUseCase(this.repository);

  Future<bool> call({
    required int userId,
    required int productId,
  }) {
    return repository.toggleFavorite(
      userId: userId,
      productId: productId,
    );
  }
}