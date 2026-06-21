import 'dart:convert';

import 'package:furnimatch/api_config.dart';
import 'package:http/http.dart' as http;

class ProductDetailsRemoteDataSource {
  Future<Map<String, dynamic>> _post({
    required String endpoint,
    required Map<String, dynamic> body,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
      body: jsonEncode(body),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    throw Exception(data['message'] ?? 'Something went wrong');
  }

  Future<bool> checkFavorite({
    required int userId,
    required int productId,
  }) async {
    final data = await _post(
      endpoint: '/favorite/check',
      body: {
        'user_id': userId,
        'product_id': productId,
      },
    );

    if (data['success'] == true) {
      return data['is_favorite'] ?? false;
    }

    return false;
  }

  Future<bool> toggleFavorite({
    required int userId,
    required int productId,
  }) async {
    final data = await _post(
      endpoint: '/favorite/toggle',
      body: {
        'user_id': userId,
        'product_id': productId,
      },
    );

    if (data['success'] == true) {
      return data['is_favorite'] ?? false;
    }

    throw Exception(data['message'] ?? 'Could not update favorite');
  }

  Future<void> buyProduct({
    required int productId,
    required int customerId,
    required String customerName,
  }) async {
    final data = await _post(
      endpoint: '/product/buy',
      body: {
        'product_id': productId,
        'customer_id': customerId,
        'customer_name': customerName,
      },
    );

    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'Something went wrong');
    }
  }
}