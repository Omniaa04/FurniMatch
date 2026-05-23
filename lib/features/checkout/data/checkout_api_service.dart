import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:furnimatch/api_config.dart';

class CheckoutApiService {
  Future<String> createOrder({
    required int userId,
    required double totalPrice,
    required String paymentMethod,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/checkout');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'total_price': totalPrice,
        'payment_method': paymentMethod,
      }),
    );

    print('CHECKOUT URL: $url');
    print('CHECKOUT STATUS: ${response.statusCode}');
    print('CHECKOUT BODY: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);

      final orderId = data['orderId'] ?? data['order_id'] ?? data['id'];

      if (orderId == null) {
        throw Exception('Order created but orderId is missing');
      }

      return orderId.toString().replaceAll('#', '');
    }

    throw Exception('Failed to create order');
  }
}