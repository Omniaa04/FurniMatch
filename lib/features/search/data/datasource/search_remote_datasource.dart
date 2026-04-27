import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:furnimatch/api_config.dart';
import '../../domain/entities/search_product.dart';

abstract class SearchRemoteDataSource {
  Future<List<SearchProduct>> searchProducts(String query);
}

class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'ngrok-skip-browser-warning': 'true',
  };

  @override
  Future<List<SearchProduct>> searchProducts(String query) async {
    final response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/products/search?q=${Uri.encodeComponent(query)}',
      ),
      headers: _headers,
    );

    final data = jsonDecode(response.body);

    if (data['success'] == true) {
      return (data['products'] as List).map((json) {
        return SearchProduct(
          id: json['id'],
          name: json['name'] ?? '',
          description: json['description'] ?? '',
          price: double.tryParse('${json['price']}') ?? 0.0,
          category: json['category'] ?? '',
          imageUrl: json['image_url'] ?? '',
          stock: (json['stock'] ?? 0) is int
              ? json['stock']
              : int.tryParse('${json['stock']}') ?? 0,
          colors: json['colors'] is List
              ? List<String>.from(json['colors'])
              : [],
          salePrice: json['sale_price'] != null
              ? double.tryParse('${json['sale_price']}')
              : null,
          storeName: json['store_name'] ?? '',
        );
      }).toList();
    }

    return [];
  }
}