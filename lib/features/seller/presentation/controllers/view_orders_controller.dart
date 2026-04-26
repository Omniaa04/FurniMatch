import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:furnimatch/api_config.dart';

class ViewOrdersController extends ChangeNotifier {
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;

  Future<void> loadOrders(int storeId) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/store/$storeId/orders'),
        headers: {'ngrok-skip-browser-warning': 'true'},
      );

      final data = jsonDecode(response.body);
      orders = data['success'] == true
          ? List<Map<String, dynamic>>.from(data['orders'] ?? [])
          : [];
    } catch (_) {
      orders = [];
    }

    isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> updateOrderStatus({
    required int orderId,
    required String status,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/order/update-status'),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({
          'order_id': orderId,
          'status': status,
        }),
      );

      final data = jsonDecode(response.body);
      return {
        'ok': response.statusCode == 200 && data['success'] == true,
        'message': data['message'] ?? 'Done',
      };
    } catch (e) {
      return {
        'ok': false,
        'message': e.toString(),
      };
    }
  }
}
