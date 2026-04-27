import '../models/points_model.dart';
import '../repository/points_repository.dart';

class GetPointsUseCase {
  final PointsRepository repository;
  GetPointsUseCase(this.repository);
  Future<PointsModel> call() => repository.getPoints();
}

class EarnPointsUseCase {
  final PointsRepository repository;
  EarnPointsUseCase(this.repository);
  Future<PointsModel> call(double amount, String orderId) =>
      repository.earnPoints(amount, orderId);
}

class RedeemPointsUseCase {
  final PointsRepository repository;
  RedeemPointsUseCase(this.repository);
  Future<PointsModel> call(int points, String orderId) =>
      repository.redeemPoints(points, orderId);
}

class SavePointsUseCase {
  final PointsRepository repository;
  SavePointsUseCase(this.repository);
  Future<PointsModel> call(PointsModel points) =>
      repository.savePoints(points);
}