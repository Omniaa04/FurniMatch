import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:furnimatch/api_config.dart';


class NetworkTimeoutException implements Exception {
  final String message;
  NetworkTimeoutException([this.message = 'الاتصال بالسيرفر بطيء جدًا أو السيرفر متوقف']);
  @override
  String toString() => message;
}

class NetworkUnavailableException implements Exception {
  final String message;
  NetworkUnavailableException([this.message = 'لا يوجد اتصال بالسيرفر']);
  @override
  String toString() => message;
}



class Product {
  final int id;
  final String name;
  final String description;
  final String price;
  final String? salePrice;
  final String? imageUrl;
  final int stock;
  final List<String> colors;
  final Map<String, dynamic>
      raw; 

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.salePrice,
    this.imageUrl,
    required this.stock,
    required this.colors,
    required this.raw,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    final colorsList = map['colors'] is List
        ? List<String>.from((map['colors'] as List).map((e) => e.toString()))
        : <String>[];

    return Product(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      description: map['description'] ?? 'No description available',
      price: '${map['price'] ?? ''}',
      salePrice: map['sale_price']?.toString(),
      imageUrl: map['image_url']?.toString(),
      stock: (map['stock'] is int)
          ? map['stock']
          : int.tryParse('${map['stock']}') ?? 0,
      colors: colorsList,
      raw: map,
    );
  }

  bool get isOutOfStock => stock <= 0;
  bool get isLowStock => stock > 0 && stock <= 5;
  bool get onSale => salePrice != null && salePrice!.trim().isNotEmpty;
}



class HomeRepository {
  static const _timeout = Duration(seconds: 10);

  static const _headers = {
    'Content-Type': 'application/json',
    'ngrok-skip-browser-warning': 'true',
  };

  static const _getHeaders = {
    'ngrok-skip-browser-warning': 'true',
  };



  Future<List<Product>> fetchAllProducts() async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/products/all'),
            headers: _getHeaders,
          )
          .timeout(_timeout);
      final data = jsonDecode(response.body);
      if (data['success'] != true) return [];
      return (data['products'] as List)
          .map((e) => Product.fromMap(e as Map<String, dynamic>))
          .toList();
    } on TimeoutException {
      throw NetworkTimeoutException();
    } on SocketException {
      throw NetworkUnavailableException();
    } catch (_) {
      return [];
    }
  }

  Future<List<Product>> fetchCategoryProducts(String categoryName) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              '${ApiConfig.baseUrl}/products/category/${Uri.encodeComponent(categoryName)}',
            ),
            headers: _getHeaders,
          )
          .timeout(_timeout);
      final data = jsonDecode(response.body);
      if (data['success'] != true) return [];
      return (data['products'] as List? ?? [])
          .map((e) => Product.fromMap(e as Map<String, dynamic>))
          .toList();
    } on TimeoutException {
      throw NetworkTimeoutException();
    } on SocketException {
      throw NetworkUnavailableException();
    } catch (_) {
      return [];
    }
  }

 

  Future<Set<int>> fetchFavoriteIds(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/favorites/$userId'),
        headers: _getHeaders,
      ).timeout(_timeout);
      final data = jsonDecode(response.body);
      if (data['success'] != true) return {};
      final favs = List<Map<String, dynamic>>.from(data['favorites'] ?? []);
      return favs.map((e) => e['id'] as int).toSet();
    } catch (_) {
      return {};
    }
  }

  /// Returns (isFavorite, message)
  Future<(bool, String)> toggleFavorite({
    required int userId,
    required int productId,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/favorite/toggle'),
      headers: _headers,
      body: jsonEncode({'user_id': userId, 'product_id': productId}),
    ).timeout(_timeout);
    final data = jsonDecode(response.body);
    if (data['success'] == true) {
      return (
        data['is_favorite'] as bool? ?? false,
        data['message']?.toString() ?? 'Done'
      );
    }
    throw Exception(data['message'] ?? 'Something went wrong');
  }

  

  Future<int> fetchUnreadCount(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/user/$userId/unread-count'),
        headers: _getHeaders,
      ).timeout(_timeout);
      final data = jsonDecode(response.body);
      if (data['success'] != true) return 0;
      return int.tryParse('${data['unread_count'] ?? 0}') ?? 0;
    } catch (_) {
      return 0;
    }
  }

Future<int> fetchUnreadNotifCount(int userId) async {
  try {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/notifications/$userId'),
      headers: _getHeaders,
    ).timeout(_timeout);
    final data = jsonDecode(response.body) as List;
    return data.where((n) => n['is_unread'] == true).length;
  } catch (_) {
    return 0;
  }
}





}