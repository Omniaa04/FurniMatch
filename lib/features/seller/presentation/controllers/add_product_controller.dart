import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:furnimatch/api_config.dart';

class AddProductController extends ChangeNotifier {
  Uint8List? imageBytes;
  String? imageName;
  bool isLoading = false;
  final List<String> selectedColors = [];

  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
      withData: true,
    );

    if (result != null) {
      imageBytes = result.files.single.bytes;
      imageName = result.files.single.name;
      notifyListeners();
    }
  }

  void removeImage() {
    imageBytes = null;
    imageName = null;
    notifyListeners();
  }

  void toggleColor(String colorHex) {
    if (selectedColors.contains(colorHex)) {
      selectedColors.remove(colorHex);
    } else {
      selectedColors.add(colorHex);
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>> addProduct({
    required int storeId,
    required String name,
    required String description,
    required String price,
    required String category,
    required String stock,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/product/add'),
      );

      request.fields['store_id'] = storeId.toString();
      request.fields['name'] = name.trim();
      request.fields['description'] = description.trim();
      request.fields['price'] = price.trim();
      request.fields['category'] = category.trim();
      request.fields['stock'] = stock.trim().isEmpty ? '0' : stock.trim();
      request.fields['colors'] = jsonEncode(selectedColors);
      request.headers['ngrok-skip-browser-warning'] = 'true';

      if (imageBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            imageBytes!,
            filename: imageName ?? 'product.jpg',
          ),
        );
      }

      final response = await request.send();
      final body = await response.stream.bytesToString();
      final data = body.isNotEmpty ? jsonDecode(body) : <String, dynamic>{};

      isLoading = false;
      notifyListeners();

      return {
        'ok': response.statusCode == 201 || data['success'] == true,
        'message': data['message'] ?? 'Request completed',
        'data': data,
      };
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return {
        'ok': false,
        'message': e.toString(),
      };
    }
  }
}
