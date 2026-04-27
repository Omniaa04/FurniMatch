import '../entities/ar_model.dart';
import '../repositories/ar_repository.dart';

class GetArModelUseCase {
  final ArRepository repository;

  GetArModelUseCase(this.repository);

  Future<ArModel> call(int productId) => repository.getArModel(productId);
}