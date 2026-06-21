import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:furnimatch/api_config.dart';

class SellerApiService {
  Future<List<Map<String, dynamic>>> getProducts(int storeId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/store/$storeId/products'),
        headers: {"ngrok-skip-browser-warning": "true"},
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['products'] ?? []);
      }
    } catch (_) {}
    return [];
  }

  Future<List<Map<String, dynamic>>> getOrders(int storeId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/store/$storeId/orders'),
        headers: {"ngrok-skip-browser-warning": "true"},
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['orders'] ?? []);
      }
    } catch (_) {}
    return [];
  }

  Future<List<Map<String, dynamic>>> getChats(int storeId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/store/$storeId/chats'),
        headers: {"ngrok-skip-browser-warning": "true"},
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['chats'] ?? []);
      }
    } catch (_) {}
    return [];
  }

  Future<void> deleteProduct(int productId) async {
    await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/product/delete/$productId'),
      headers: {'ngrok-skip-browser-warning': 'true'},
    );
  }

  Future<void> updateOrderStatus(int orderId, String status) async {
    await http.post(
      Uri.parse('${ApiConfig.baseUrl}/order/update-status'),
      headers: {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
      body: jsonEncode({'order_id': orderId, 'status': status}),
    );
  }

  Future<Map<String, dynamic>> getAnalytics(int storeId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/store/$storeId/analytics'),
        headers: {"ngrok-skip-browser-warning": "true"},
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return Map<String, dynamic>.from(data);
      }
    } catch (_) {}

    return {
      'success': false,
      'summary': {
        'total_products': 0,
        'total_orders': 0,
        'total_units_sold': 0,
        'total_revenue': 0,
      },
      'top_products': <Map<String, dynamic>>[],
      'sales_over_time': <Map<String, dynamic>>[],
    };
  }
}
