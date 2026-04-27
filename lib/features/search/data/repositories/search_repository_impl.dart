import 'package:furnimatch/features/search/data/datasource/search_remote_datasource.dart';

import '../../domain/entities/search_product.dart';
import '../../domain/repositories/search_repository.dart';


class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource remoteDataSource;

  SearchRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<SearchProduct>> searchProducts(String query) =>
      remoteDataSource.searchProducts(query);
}