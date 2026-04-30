// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:furnimatch/api_config.dart';

// class LocationRemoteDataSource {
//   Future<void> saveAddress({
//     required int userId,
//     required String locationName,
//     required double latitude,
//     required double longitude,
//   }) async {
//     final url = Uri.parse('${ApiConfig.baseUrl}/address/save');

//     final response = await http.post(
//       url,
//       headers: {
//         'Content-Type': 'application/json',
//         'ngrok-skip-browser-warning': 'true',
//         },
//       body: jsonEncode({
//         'user_id': userId,
//         'locationName': locationName,
//         'latitude': latitude,
//         'longitude': longitude,
//       }),
//     );

//     print('SAVE ADDRESS STATUS: ${response.statusCode}');
//     print('SAVE ADDRESS BODY: ${response.body}');

//     if (response.statusCode != 200 && response.statusCode != 201) {
//       throw Exception('Failed to save address');
//     }
//   }
// }
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:furnimatch/api_config.dart';

class LocationRemoteDataSource {
  Future<void> saveAddress({
    required int userId,
    required String locationName,
    required double latitude,
    required double longitude,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/address/save');

    try {
      final response = await http
          .post(
            url,
            headers: const {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'user_id': userId,
              'locationName': locationName,
              'latitude': latitude,
              'longitude': longitude,
            }),
          )
          .timeout(const Duration(seconds: 20));

      print('SAVE ADDRESS URL: $url');
      print('SAVE ADDRESS STATUS: ${response.statusCode}');
      print('SAVE ADDRESS BODY: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(response.body);
      }
    } catch (e) {
      print('SAVE ADDRESS ERROR: $e');
      rethrow;
    }
  }
}