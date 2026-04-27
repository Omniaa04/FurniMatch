import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/chat_message.dart';
import '../models/chat_message_model.dart';

class ChatLocalDataSource {
  static const String chatStorageKey = "furnimatch_ai_chat_messages";

  Future<List<ChatMessage>> loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(chatStorageKey);

    if (saved == null || saved.isEmpty) {
      return [];
    }

    final List<dynamic> decoded = jsonDecode(saved);

    return decoded.map((item) {
      final model = ChatMessageModel.fromJson(item as Map<String, dynamic>);
      return ChatMessage(
        text: model.text,
        isUser: model.isUser,
        imageBase64: model.imageBase64,
      );
    }).toList();
  }

  Future<void> saveMessages(List<ChatMessage> messages) async {
    final prefs = await SharedPreferences.getInstance();

    final encoded = jsonEncode(
      messages
          .map((message) => ChatMessageModel.fromEntity(message).toJson())
          .toList(),
    );

    await prefs.setString(chatStorageKey, encoded);
  }

  Future<void> clearMessages(List<ChatMessage> defaultMessages) async {
    await saveMessages(defaultMessages);
  }
}