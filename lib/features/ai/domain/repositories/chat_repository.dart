import 'dart:typed_data';

import '../entities/chat_message.dart';

abstract class ChatRepository {
  Future<List<ChatMessage>> loadMessages();

  Future<void> saveMessages(List<ChatMessage> messages);

  Future<void> clearMessages(List<ChatMessage> defaultMessages);

  Future<String> sendMessage({
    required String text,
    Uint8List? imageBytes,
    String? imageName,
  });
}