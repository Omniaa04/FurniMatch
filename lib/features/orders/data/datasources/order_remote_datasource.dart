// lib/features/orders/data/datasources/order_remote_datasource.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../api_config.dart';
import '../models/order_model.dart';

abstract class OrderRemoteDataSource {
  Future<List<OrderModel>> getCustomerOrders(int customerId);
  Future<void> updateOrderStatus(int orderId, String status);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final http.Client client;
  OrderRemoteDataSourceImpl({required this.client});

  static const _headers = {
    'Content-Type': 'application/json',
    'ngrok-skip-browser-warning': 'true',
  };

  // GET /customer/<customer_id>/orders
  @override
  Future<List<OrderModel>> getCustomerOrders(int customerId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/customer/$customerId/orders');
    final response = await client.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final list = body['orders'] as List;
      return list
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to fetch orders [${response.statusCode}]');
    }
  }

  // POST /order/update-status
  @override
  Future<void> updateOrderStatus(int orderId, String status) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/order/update-status');
    final response = await client.post(
      uri,
      headers: _headers,
      body: jsonEncode({'order_id': orderId, 'status': status}),
    );

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(body['message'] ?? 'Failed to update status');
    }
  }
}