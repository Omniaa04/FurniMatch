import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:furnimatch/api_config.dart';
import '../models/cart_item_model.dart';

abstract class CartLocalDataSource {
  Future<List<CartItemModel>> getCartItems();
  Future<void> addItem(int productId, int quantity);
  Future<void> updateQuantity(String cartId, int quantity);
  Future<void> removeItem(String cartId);
  void setUserId(int userId);
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  int? _userId;

  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'ngrok-skip-browser-warning': 'true',
  };

  @override
  void setUserId(int userId) {
    _userId = userId;
  }

  @override
  Future<List<CartItemModel>> getCartItems() async {
    if (_userId == null) return [];

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/cart/$_userId'),
      headers: _headers,
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return List<CartItemModel>.from(
        (data['items'] as List? ?? []).map((e) => CartItemModel.fromJson(e)),
      );
    }

    return [];
  }

  @override
  Future<void> addItem(int productId, int quantity) async {
    if (_userId == null) {
      throw Exception('User id is missing');
    }

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/cart/add'),
      headers: _headers,
      body: jsonEncode({
        'user_id': _userId,
        'product_id': productId,
        'quantity': quantity,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(data['message'] ?? 'Could not add item to cart');
    }

    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'Could not add item to cart');
    }
  }

  @override
  Future<void> updateQuantity(String cartId, int quantity) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/cart/update'),
      headers: _headers,
      body: jsonEncode({
        'cart_id': int.parse(cartId),
        'quantity': quantity,
      }),
    );

    final data = jsonDecode(response.body);

    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'Could not update quantity');
    }
  }

  @override
  Future<void> removeItem(String cartId) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/cart/remove/$cartId'),
      headers: _headers,
    );

    final data = jsonDecode(response.body);

    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'Could not remove item');
    }
  }
}