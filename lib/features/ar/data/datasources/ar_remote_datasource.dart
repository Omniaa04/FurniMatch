import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:furnimatch/api_config.dart';
import '../../domain/entities/ar_model.dart';

abstract class ArRemoteDataSource {
  Future<ArModel> getArModel(int productId);
}

class ArRemoteDataSourceImpl implements ArRemoteDataSource {
  @override
  Future<ArModel> getArModel(int productId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/product/$productId/ar-model'),
      headers: {"ngrok-skip-browser-warning": "true"},
    );

    final data = jsonDecode(response.body);

    if (data['success'] == true) {
      return ArModel(
        productId: productId,
        glbUrl: data['glb_url'],
        usdzUrl: data['usdz_url'],
      );
    }

    throw Exception(data['message'] ?? 'Failed to load AR model');
  }
}
