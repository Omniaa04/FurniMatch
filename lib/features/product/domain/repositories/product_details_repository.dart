abstract class ProductDetailsRepository {
  Future<bool> checkFavorite({
    required int userId,
    required int productId,
  });

  Future<bool> toggleFavorite({
    required int userId,
    required int productId,
  });

  Future<void> buyProduct({
    required int productId,
    required int customerId,
    required String customerName,
  });
}