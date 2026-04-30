// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:furnimatch/api_config.dart';
// import '../../domain/models/points_model.dart';

// class PointsRemoteDataSource {
//   Future<PointsModel> getPoints(int userId) async {
//     final response = await http.get(
//       Uri.parse('${ApiConfig.baseUrl}/points/$userId'),
//     );

//     print('POINTS GET: ${response.body}');

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);

//       return PointsModel.fromJson({
//         'totalPoints': data['totalPoints'] ?? 0,
//         'transactions': data['transactions'] ?? [],
//       });
//     }

//     throw Exception('Failed to get points');
//   }

//   Future<PointsModel> earnPoints({
//     required int userId,
//     required double purchaseAmount,
//     required String orderId,
//   }) async {
//     final response = await http.post(
//       Uri.parse('${ApiConfig.baseUrl}/points/$userId/earn'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({
//         'purchaseAmount': purchaseAmount,
//         'orderId': orderId,
//       }),
//     );

//     print('POINTS EARN: ${response.body}');

//     if (response.statusCode == 200) {
//       return getPoints(userId);
//     }

//     throw Exception('Failed to earn points');
//   }

//   Future<PointsModel> redeemPoints({
//     required int userId,
//     required String orderId,
//   }) async {
//     final response = await http.post(
//       Uri.parse('${ApiConfig.baseUrl}/points/$userId/redeem'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({
//         'orderId': orderId,
//       }),
//     );

//     print('POINTS REDEEM: ${response.body}');

//     if (response.statusCode == 200) {
//       return getPoints(userId);
//     }

//     throw Exception('Failed to redeem points');
//   }
// }

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:furnimatch/api_config.dart';
import '../../domain/models/points_model.dart';

class PointsRemoteDataSource {
  Future<PointsModel> getPoints(int userId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/points/$userId'),
    );

    print('POINTS GET STATUS: ${response.statusCode}');
    print('POINTS GET BODY: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return PointsModel.fromJson({
        'totalPoints': data['totalPoints'] ?? 0,
        'transactions': data['transactions'] ?? [],
      });
    }

    throw Exception('Failed to get points');
  }

  Future<PointsModel> earnPoints({
    required int userId,
    required double purchaseAmount,
    required String orderId,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/points/$userId/earn'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'purchaseAmount': purchaseAmount,
        'orderId': orderId,
      }),
    );

    print('POINTS EARN STATUS: ${response.statusCode}');
    print('POINTS EARN BODY: ${response.body}');

    if (response.statusCode == 200) {
      return getPoints(userId);
    }

    throw Exception('Failed to earn points');
  }

  Future<PointsModel> redeemPoints({
    required int userId,
    required String orderId,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/points/$userId/redeem'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'orderId': orderId,
      }),
    );

    print('POINTS REDEEM STATUS: ${response.statusCode}');
    print('POINTS REDEEM BODY: ${response.body}');

    if (response.statusCode == 200) {
      return getPoints(userId);
    }

    throw Exception('Failed to redeem points');
  }
}