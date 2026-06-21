// import '../entities/search_product.dart';
// import '../repositories/search_repository.dart';

// class SearchProductsUseCase {
//   final SearchRepository repository;

//   SearchProductsUseCase(this.repository);

//   Future<List<SearchProduct>> call(String query) =>
//       repository.searchProducts(query);
// }
import '../entities/search_product.dart';
import '../repositories/search_repository.dart';

class SearchProductsUseCase {
  final SearchRepository repository;

  SearchProductsUseCase(this.repository);

  Future<List<SearchProduct>> call(String query) {
    return repository.searchProducts(query);
  }

  Future<List<SearchProduct>> callByImage(String imagePath) {
    return repository.searchProductsByImage(imagePath);
  }
}