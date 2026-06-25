import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  static const String baseUrl = 'https://chance-impeding-curable.ngrok-free.dev';

  static Future<List<dynamic>> fetchNotifications(int userId) async {
  try {
    final url = '$baseUrl/notifications/$userId';
    print(' Fetching notifications from: $url');

    final response = await http.get(
      Uri.parse(url),
      headers: {'ngrok-skip-browser-warning': 'true'},
    );

    print(' Status code: ${response.statusCode}'); 
    print(' Response body: ${response.body}'); 

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  } catch (e) {
    print(' ERROR: $e'); 
    return [];
  }
}

  static Future<void> markAsRead(int notifId) async {
    await http.put(
      Uri.parse('$baseUrl/notifications/$notifId/read'),
    );
  }

static Future<void> markAllAsRead(int userId) async {
  try {
    await http.put(
      Uri.parse('$baseUrl/notifications/$userId/read-all'),
      headers: {
        'ngrok-skip-browser-warning': 'true',
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 10)); 
  } catch (e) {
    debugPrint('markAllAsRead error: $e');
  }
}



}