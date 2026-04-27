import '../../domain/entities/search_product.dart';

abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<SearchProduct> products;
  final String query;

  SearchLoaded({required this.products, required this.query});
}

class SearchEmpty extends SearchState {
  final String query;
  SearchEmpty({required this.query});
}

class SearchError extends SearchState {
  final String message;
  SearchError(this.message);
}