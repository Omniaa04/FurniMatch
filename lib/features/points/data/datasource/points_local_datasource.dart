// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../domain/models/points_model.dart';

// abstract class PointsLocalDataSource {
//   Future<PointsModel> getPoints();
//   Future<PointsModel> savePoints(PointsModel points);
// }

// class PointsLocalDataSourceImpl implements PointsLocalDataSource {
//   static const _key = 'user_points';

//   @override
//   Future<PointsModel> getPoints() async {
//     final prefs = await SharedPreferences.getInstance();
//     final json = prefs.getString(_key);
//     if (json == null) return const PointsModel();
//     return PointsModel.fromJson(jsonDecode(json));
//   }

//   @override
//   Future<PointsModel> savePoints(PointsModel points) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_key, jsonEncode(points.toJson()));
//     return points;
//   }
// }