import '../entities/ar_model.dart';

abstract class ArRepository {
  Future<ArModel> getArModel(int productId);
}