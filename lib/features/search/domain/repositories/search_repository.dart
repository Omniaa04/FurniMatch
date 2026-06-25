import '../entities/search_product.dart';

abstract class SearchRepository {
  Future<List<SearchProduct>> searchProducts(String query);
  Future<List<SearchProduct>> searchProductsByImage(String imagePath);
}