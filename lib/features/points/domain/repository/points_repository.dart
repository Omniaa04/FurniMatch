import '../models/points_model.dart';

abstract class PointsRepository {
  Future<PointsModel> getPoints();
  Future<PointsModel> earnPoints(double purchaseAmount, String orderId);
  Future<PointsModel> redeemPoints(int pointsToRedeem, String orderId);
  Future<PointsModel> savePoints(PointsModel points);
}