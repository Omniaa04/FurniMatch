import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:furnimatch/api_config.dart';

class CartService {
  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'ngrok-skip-browser-warning': 'true',
  };

Future<bool> addToCart(int userId, int productId, int quantity) async {
  try {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/cart/add'),
      headers: _headers,
      body: jsonEncode({
        'user_id': userId,
        'product_id': productId,
        'quantity': quantity,
      }),
    );

    print('🛒 CartService addToCart status = ${response.statusCode}');
    print('🛒 CartService addToCart body = ${response.body}'); // ← ضيف ده

    final data = jsonDecode(response.body);
    return data['success'] == true;
  } catch (e) {
    return false;
  }
}

  Future<int> getCartCount(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/cart/summary/$userId'),
        headers: {'ngrok-skip-browser-warning': 'true'},
      );

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        return data['summary']['total_items'] ?? 0;
      }

      return 0;
    } catch (e) {
      return 0;
    }
  }

  Future<bool> removeFromCart(int cartId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/cart/remove/$cartId'),
        headers: _headers,
      );

      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateQuantity(int cartId, int quantity) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/cart/update'),
        headers: _headers,
        body: jsonEncode({
          'cart_id': cartId,
          'quantity': quantity,
        }),
      );

      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (e) {
      return false;
    }
  }
}