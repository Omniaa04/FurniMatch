import '../../domain/repositories/product_details_repository.dart';
import '../datasources/product_details_remote_datasource.dart';

class ProductDetailsRepositoryImpl implements ProductDetailsRepository {
  final ProductDetailsRemoteDataSource remoteDataSource;

  ProductDetailsRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<bool> checkFavorite({
    required int userId,
    required int productId,
  }) {
    return remoteDataSource.checkFavorite(
      userId: userId,
      productId: productId,
    );
  }

  @override
  Future<bool> toggleFavorite({
    required int userId,
    required int productId,
  }) {
    return remoteDataSource.toggleFavorite(
      userId: userId,
      productId: productId,
    );
  }

  @override
  Future<void> buyProduct({
    required int productId,
    required int customerId,
    required String customerName,
  }) {
    return remoteDataSource.buyProduct(
      productId: productId,
      customerId: customerId,
      customerName: customerName,
    );
  }
}