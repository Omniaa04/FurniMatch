// import 'package:uuid/uuid.dart';
// import '../../domain/models/points_model.dart';
// import '../../domain/repository/points_repository.dart';
// import '../datasource/points_local_datasource.dart';

// class PointsRepositoryImpl implements PointsRepository {
//   final PointsLocalDataSource dataSource;
//   PointsRepositoryImpl(this.dataSource);

//   @override
//   Future<PointsModel> getPoints() => dataSource.getPoints();

//   @override
//   Future<PointsModel> savePoints(PointsModel points) =>
//       dataSource.savePoints(points);

//   @override
//   Future<PointsModel> earnPoints(double purchaseAmount, String orderId) async {
//     final current = await dataSource.getPoints();
//     final earned = PointsModel.calculatePoints(purchaseAmount);

//     final transaction = PointsTransaction(
//       id: const Uuid().v4(),
//       points: earned,
//       description: 'Order #$orderId',
//       date: DateTime.now(),
//       isEarned: true,
//     );

//     final updated = current.copyWith(
//       totalPoints: current.totalPoints + earned,
//       transactions: [transaction, ...current.transactions],
//     );

//     return dataSource.savePoints(updated);
//   }

//   @override
//   Future<PointsModel> redeemPoints(int pointsToRedeem, String orderId) async {
//     final current = await dataSource.getPoints();

//     if (pointsToRedeem > current.totalPoints) {
//       throw Exception('Not enough points');
//     }

//     // دايماً خصم واحد = 10 جنيه مقابل 100 نقطة
//     final discountEGP = PointsModel.discountValue;

//     final transaction = PointsTransaction(
//       id: const Uuid().v4(),
//       points: pointsToRedeem,
//       description: 'Redeemed → EGP $discountEGP discount on Order #$orderId',
//       date: DateTime.now(),
//       isEarned: false,
//     );

//     final updated = current.copyWith(
//       totalPoints: current.totalPoints - pointsToRedeem,
//       transactions: [transaction, ...current.transactions],
//     );

//     return dataSource.savePoints(updated);
//   }
// }

import '../../domain/models/points_model.dart';
import '../../domain/repository/points_repository.dart';
import '../datasource/points_remote_datasource.dart';

class PointsRepositoryImpl implements PointsRepository {
  final PointsRemoteDataSource remoteDataSource;
  final int userId;

  PointsRepositoryImpl({
    required this.remoteDataSource,
    required this.userId,
  });

  @override
  Future<PointsModel> getPoints() {
    return remoteDataSource.getPoints(userId);
  }

  @override
  Future<PointsModel> savePoints(PointsModel points) async {
    return points;
  }

  @override
  Future<PointsModel> earnPoints(double purchaseAmount, String orderId) {
    return remoteDataSource.earnPoints(
      userId: userId,
      purchaseAmount: purchaseAmount,
      orderId: orderId,
    );
  }

  @override
  Future<PointsModel> redeemPoints(int pointsToRedeem, String orderId) {
    return remoteDataSource.redeemPoints(
      userId: userId,
      orderId: orderId,
    );
  }
}

