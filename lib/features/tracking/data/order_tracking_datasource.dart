import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:furnimatch/api_config.dart';

class OrderTrackingDataSource {
  Future<Map<String, dynamic>> getTracking(String orderId) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/tracking/$orderId");

    print("TRACKING URL: $url");

    final response = await http.get(
      url,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    print("TRACKING STATUS: ${response.statusCode}");
    print("TRACKING RESPONSE: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load tracking: ${response.body}");
    }
  }
}