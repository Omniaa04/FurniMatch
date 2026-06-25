// import 'dart:convert';
// import 'package:furnimatch/api_config.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter/foundation.dart';
// import '../../domain/models/room_dimensions.dart';

// class RoomApiService {
//   static String get _baseUrl => ApiConfig.baseUrl;

//   // ✅ بدل getToken — بنجيب user_id
//   Future<int?> getUserId() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getInt('user_id');
//   }

//   Future<bool> saveRoom({
//     required String name,
//     required RoomDimensions dimensions,
//     required List<Map<String, dynamic>> furniture,
//     required String source3D,
//   }) async {
//     final userId = await getUserId();
//     if (userId == null) return false;

//     final res = await http.post(
//       Uri.parse('$_baseUrl/rooms/save'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({
//         'user_id': userId,  // ✅ بنبعته في الـ body
//         'name': name,
//         'width': dimensions.width,
//         'length': dimensions.length,
//         'height': dimensions.height,
//         'furniture': furniture,
//         'source_3d': source3D,
//       }),
//     );
//     debugPrint('SAVE STATUS: ${res.statusCode}');
//     debugPrint('SAVE BODY: ${res.body}');
//     return res.statusCode == 201;
//   }

//   Future<List<Map<String, dynamic>>> loadRooms() async {
//     final userId = await getUserId();
//     if (userId == null) return [];

//     final res = await http.get(
//       Uri.parse('$_baseUrl/rooms/list?user_id=$userId'), // ✅ في الـ query
//       headers: {'Content-Type': 'application/json'},
//     );

//     if (res.statusCode == 200) {
//       final data = jsonDecode(res.body);
//       final List rooms = data['rooms'] ?? data ?? [];
//       return rooms.cast<Map<String, dynamic>>();
//     }
//     return [];
//   }

//   Future<bool> deleteRoom(int roomId) async {
//     final userId = await getUserId();
//     if (userId == null) return false;

//     final res = await http.delete(
//       Uri.parse('$_baseUrl/rooms/$roomId'),
//       headers: {'Content-Type': 'application/json'},
//     );
//     return res.statusCode == 200;
//   }
// }
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/room_dimensions.dart';

class RoomApiService {
  static const String _baseUrl = 'https://pout-tavern-refuse.ngrok-free.dev';

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      await prefs.setString('user_name', data['name']);
    }
    return data;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user_name');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  Future<bool> saveRoom({
    required String name,
    required RoomDimensions dimensions,
    required List<Map<String, dynamic>> furniture,
  }) async {
    final token = await getToken();
    if (token == null) return false;
    final res = await http.post(
      Uri.parse('$_baseUrl/rooms/save'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'width': dimensions.width,
        'length': dimensions.length,
        'height': dimensions.height,
        'furniture': furniture,
      }),
    );
    return res.statusCode == 201;
  }

  Future<List<Map<String, dynamic>>> loadRooms() async {
    final token = await getToken();
    if (token == null) return [];
    final res = await http.get(
      Uri.parse('$_baseUrl/rooms/list'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<bool> deleteRoom(int roomId) async {
    final token = await getToken();
    if (token == null) return false;
    final res = await http.delete(
      Uri.parse('$_baseUrl/rooms/$roomId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return res.statusCode == 200;
  }
}