// import 'dart:convert';
// import 'package:http/http.dart' as http;

// import 'package:furnimatch/api_config.dart';
// import '../../domain/models/settings_model.dart';

// class SettingsRemoteDataSource {
//   Future<SettingsModel> getSettings(int userId) async {
//     final response = await http.get(
//       Uri.parse('${ApiConfig.baseUrl}/settings/$userId'),
//     );

//     print('SETTINGS GET STATUS: ${response.statusCode}');
//     print('SETTINGS GET BODY: ${response.body}');

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       return SettingsModel.fromJson(data['settings']);
//     }

//     throw Exception('Failed to get settings');
//   }

//   Future<void> saveSettings({
//     required int userId,
//     required SettingsModel settings,
//   }) async {
//     final response = await http.put(
//       Uri.parse('${ApiConfig.baseUrl}/settings/$userId'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode(settings.toJson()),
//     );

//     print('SETTINGS SAVE STATUS: ${response.statusCode}');
//     print('SETTINGS SAVE BODY: ${response.body}');

//     if (response.statusCode != 200) {
//       throw Exception('Failed to save settings');
//     }
//   }

//   Future<void> clearCache(int userId) async {
//     final response = await http.delete(
//       Uri.parse('${ApiConfig.baseUrl}/settings/$userId/clear-cache'),
//     );

//     print('SETTINGS CLEAR STATUS: ${response.statusCode}');
//     print('SETTINGS CLEAR BODY: ${response.body}');

//     if (response.statusCode != 200) {
//       throw Exception('Failed to clear cache');
//     }
//   }
// }

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:furnimatch/api_config.dart';
import '../../domain/models/settings_model.dart';

class SettingsRemoteDataSource {
  static const _headers = {
    'Content-Type': 'application/json',
    'ngrok-skip-browser-warning': 'true', // ✅
  };

  Future<SettingsModel> getSettings(int userId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/settings/$userId'),
      headers: {'ngrok-skip-browser-warning': 'true'}, // ✅
    );

    print('SETTINGS GET STATUS: ${response.statusCode}');
    print('SETTINGS GET BODY: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return SettingsModel.fromJson(data['settings']);
    }

    throw Exception('Failed to get settings');
  }

  Future<void> saveSettings({
    required int userId,
    required SettingsModel settings,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/settings/$userId'),
      headers: _headers, // ✅
      body: jsonEncode(settings.toJson()),
    );

    print('SETTINGS SAVE STATUS: ${response.statusCode}');
    print('SETTINGS SAVE BODY: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to save settings');
    }
  }

  Future<void> clearCache(int userId) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/settings/$userId/clear-cache'),
      headers: {'ngrok-skip-browser-warning': 'true'}, // ✅
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to clear cache');
    }
  }
}