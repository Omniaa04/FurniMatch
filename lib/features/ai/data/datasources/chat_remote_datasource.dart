// import 'dart:convert';
// import 'dart:typed_data';

// import 'package:http/http.dart' as http;
// import 'package:furnimatch/api_config.dart';

// class ChatRemoteDataSource {
//   final String apiUrl = "${ApiConfig.baseUrl}/analyze";

//   Future<String> sendMessage({
//     required String text,
//     Uint8List? imageBytes,
//     String? imageName,
//   }) async {
//     final request = http.MultipartRequest('POST', Uri.parse(apiUrl));

//     request.headers['ngrok-skip-browser-warning'] = 'true';
//     request.fields['text'] = text;

//     if (imageBytes != null && imageName != null) {
//       request.files.add(
//         http.MultipartFile.fromBytes(
//           'image',
//           imageBytes,
//           filename: imageName,
//         ),
//       );
//     }

//     final streamedResponse =
//         await request.send().timeout(const Duration(seconds: 60));

//     final responseBody = await streamedResponse.stream.bytesToString();

//     Map<String, dynamic> data = {};

//     try {
//       data = jsonDecode(responseBody);
//     } catch (_) {
//       data = {};
//     }

//     if (streamedResponse.statusCode == 200) {
//       return data['response'] ?? data['error'] ?? 'No response';
//     }

//     return data['error'] ??
//         data['message'] ??
//         "Server error: ${streamedResponse.statusCode}";
//   }
// }

import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:furnimatch/api_config.dart';

class ChatRemoteDataSource {
  final String apiUrl = "${ApiConfig.baseUrl}/analyze";

  Future<String> sendMessage({
    required String text,
    required int userId,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse(apiUrl));

    request.headers['ngrok-skip-browser-warning'] = 'true';
    request.fields['text'] = text;
    request.fields['user_id'] = userId.toString();

    print("AI URL: $apiUrl");
    print("AI TEXT: $text");
    print("AI USER ID: $userId");
    print("AI HAS IMAGE: ${imageBytes != null}");

    if (imageBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: imageName ?? 'ai_image.jpg',
        ),
      );
    }

    final streamedResponse =
        await request.send().timeout(const Duration(seconds: 60));

    final responseBody = await streamedResponse.stream.bytesToString();

    print("AI STATUS: ${streamedResponse.statusCode}");
    print("AI BODY: $responseBody");

    Map<String, dynamic> data = {};

    try {
      data = jsonDecode(responseBody);
    } catch (_) {
      data = {};
    }

    if (streamedResponse.statusCode == 200) {
      return data['response'] ?? data['error'] ?? 'No response';
    }

    return data['error'] ??
        data['message'] ??
        "Server error: ${streamedResponse.statusCode}";
  }
}