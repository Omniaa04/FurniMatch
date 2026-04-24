import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/room_dimensions.dart';

class RoomApiService {
  // ← update this every time you restart ngrok
  static const String _baseUrl = 'https://pout-tavern-refuse.ngrok-free.dev';

  // ── Auth ──────────────────────────────────────────────────────────────────

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
      // Save token locally
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

  // ── Rooms ─────────────────────────────────────────────────────────────────

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