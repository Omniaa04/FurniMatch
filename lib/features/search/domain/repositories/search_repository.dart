import '../entities/search_product.dart';

abstract class SearchRepository {
  Future<List<SearchProduct>> searchProducts(String query);
}