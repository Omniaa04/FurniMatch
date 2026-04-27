import '../../domain/entities/ar_model.dart';
import '../../domain/repositories/ar_repository.dart';
import '../datasources/ar_remote_datasource.dart';

class ArRepositoryImpl implements ArRepository {
  final ArRemoteDataSource remoteDataSource;

  ArRepositoryImpl(this.remoteDataSource);

  @override
  Future<ArModel> getArModel(int productId) =>
      remoteDataSource.getArModel(productId);
}