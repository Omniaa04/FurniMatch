import '../entities/search_product.dart';
import '../repositories/search_repository.dart';

class SearchProductsUseCase {
  final SearchRepository repository;

  SearchProductsUseCase(this.repository);

  Future<List<SearchProduct>> call(String query) =>
      repository.searchProducts(query);
}