import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:furnimatch/api_config.dart';

// ─── Models ──────────────────────────────────────────────────

class ChatMessage {
  final int senderId;
  final int receiverId;
  final int storeId;
  final String text;
  final String? imageUrl;
  final Uint8List? imageBytes;
  final String createdAt;
  final bool isLocal;
  final bool isPending;

  const ChatMessage({
    required this.senderId,
    required this.receiverId,
    required this.storeId,
    required this.text,
    this.imageUrl,
    this.imageBytes,
    required this.createdAt,
    this.isLocal = false,
    this.isPending = false,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    final dynamic rawText =
        map['text'] ?? map['message'] ?? map['content'] ?? map['body'];
    final dynamic rawImage =
        map['image_url'] ?? map['image'] ?? map['imageUrl'];
    final String? imageUrl = rawImage?.toString();

    return ChatMessage(
      senderId: int.tryParse(map['sender_id'].toString()) ?? 0,
      receiverId: int.tryParse(map['receiver_id'].toString()) ?? 0,
      storeId: int.tryParse(map['store_id'].toString()) ?? 0,
      text: rawText?.toString() ?? '',
      imageUrl: (imageUrl == null || imageUrl.isEmpty) ? null : imageUrl,
      imageBytes: map['image_bytes'] as Uint8List?,
      createdAt:
          map['created_at']?.toString() ?? DateTime.now().toIso8601String(),
      isLocal: map['is_local'] == true,
      isPending: map['is_pending'] == true,
    );
  }

  ChatMessage copyWith({bool? isPending}) => ChatMessage(
        senderId: senderId,
        receiverId: receiverId,
        storeId: storeId,
        text: text,
        imageUrl: imageUrl,
        imageBytes: imageBytes,
        createdAt: createdAt,
        isLocal: isLocal,
        isPending: isPending ?? this.isPending,
      );
}

class ChatPreview {
  final int storeId;
  final String storeName;
  final int sellerUserId;
  final String lastMessage;
  final bool hasUnread;
  final bool lastMessageHasImage;
  final bool lastMessageFromShop;

  const ChatPreview({
    required this.storeId,
    required this.storeName,
    required this.sellerUserId,
    required this.lastMessage,
    required this.hasUnread,
    required this.lastMessageHasImage,
    required this.lastMessageFromShop,
  });

  factory ChatPreview.fromMap(Map<String, dynamic> map) => ChatPreview(
        storeId: map['store_id'] ?? 0,
        storeName: map['store_name'] ?? 'Shop',
        sellerUserId: map['seller_user_id'] ?? 0,
        lastMessage: (map['last_message'] ?? '').toString().trim(),
        hasUnread: map['has_unread'] == true,
        lastMessageHasImage: map['last_message_has_image'] == true,
        lastMessageFromShop: map['last_message_from_shop'] == true,
      );

  String get subtitle {
    String content = lastMessage;
    if (content.isEmpty && lastMessageHasImage) {
      content = 'sent a photo';
    } else if (content.isNotEmpty && lastMessageHasImage) {
      content = 'sent a photo: $content';
    } else if (content.isEmpty) {
      content = 'Open conversation';
    }
    return lastMessageFromShop ? 'Shop: $content' : 'You: $content';
  }
}

class ShopPreview {
  final int id;
  final String storeName;
  final int userId;

  const ShopPreview({
    required this.id,
    required this.storeName,
    required this.userId,
  });

  factory ShopPreview.fromMap(Map<String, dynamic> map) => ShopPreview(
        id: map['id'] ?? 0,
        storeName: map['store_name'] ?? 'Shop',
        userId: map['user_id'] ?? 0,
      );
}

// ─── Repository ──────────────────────────────────────────────

class ChatRepository {
  static const _headers = {
    'Content-Type': 'application/json',
    'ngrok-skip-browser-warning': 'true',
  };

  static const _getHeaders = {
    'ngrok-skip-browser-warning': 'true',
  };

  // ── Chat List ──

  Future<List<ChatPreview>> fetchUserChats(int userId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/user/$userId/chats'),
      headers: _getHeaders,
    );
    final data = jsonDecode(response.body);
    if (data['success'] != true) return [];
    return (data['chats'] as List? ?? [])
        .map((e) => ChatPreview.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<int> fetchUnreadCount(int userId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/user/$userId/unread-count'),
      headers: _getHeaders,
    );
    final data = jsonDecode(response.body);
    if (data['success'] != true) return 0;
    return int.tryParse('${data['unread_count'] ?? 0}') ?? 0;
  }

  Future<List<ShopPreview>> fetchAllShops() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/stores'),
      headers: _getHeaders,
    );
    final data = jsonDecode(response.body);
    if (data['success'] != true) return [];
    return (data['stores'] as List? ?? [])
        .map((e) => ShopPreview.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteChat({required int storeId, required int userId}) async {
    await http.post(
      Uri.parse('${ApiConfig.baseUrl}/messages/delete-chat'),
      headers: _headers,
      body: jsonEncode({'store_id': storeId, 'user_id': userId}),
    );
  }

  // ── Chat Details ──

  Future<List<ChatMessage>> fetchMessages({
    required int storeId,
    required int userId,
  }) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/messages/$storeId/$userId'),
      headers: _headers,
    );
    final data = jsonDecode(response.body);
    if (data['success'] != true) return [];
    return (data['messages'] as List? ?? [])
        .map((e) => ChatMessage.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> markMessagesAsRead({
    required int storeId,
    required int userId,
  }) async {
    await http.post(
      Uri.parse('${ApiConfig.baseUrl}/messages/mark-read'),
      headers: _headers,
      body: jsonEncode({'store_id': storeId, 'user_id': userId}),
    );
  }

  Future<bool> sendTextMessage({
    required int senderId,
    required int receiverId,
    required int storeId,
    required String text,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/messages/send');
    final payload = {
      'sender_id': senderId.toString(),
      'receiver_id': receiverId.toString(),
      'store_id': storeId.toString(),
      'text': text,
    };

    http.Response response;
    try {
      response = await http.post(
        uri,
        headers: _headers,
        body: jsonEncode(payload),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        // Fallback to form encoding
        response = await http.post(
          uri,
          headers: _getHeaders,
          body: payload,
        );
      }
    } catch (_) {
      response = await http.post(
        uri,
        headers: _getHeaders,
        body: payload,
      );
    }

    if (response.statusCode != 200 && response.statusCode != 201) return false;
    try {
      final data = jsonDecode(response.body);
      return data['success'] != false;
    } catch (_) {
      return true;
    }
  }

  Future<bool> sendImageMessage({
    required int senderId,
    required int receiverId,
    required int storeId,
    required String text,
    required XFile image,
    required Uint8List imageBytes,
  }) async {
    final ext = image.name.split('.').last.toLowerCase();
    final mediaType = switch (ext) {
      'png' => MediaType('image', 'png'),
      'webp' => MediaType('image', 'webp'),
      'heic' => MediaType('image', 'heic'),
      'heif' => MediaType('image', 'heif'),
      _ => MediaType('image', 'jpeg'),
    };

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConfig.baseUrl}/messages/send-image'),
    )
      ..fields['sender_id'] = senderId.toString()
      ..fields['receiver_id'] = receiverId.toString()
      ..fields['store_id'] = storeId.toString()
      ..fields['text'] = text
      ..headers['ngrok-skip-browser-warning'] = 'true'
      ..files.add(http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: image.name,
        contentType: mediaType,
      ));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    return response.statusCode == 200 || response.statusCode == 201;
  }
}
