import '../../domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessage {
  ChatMessageModel({
    required super.text,
    required super.isUser,
    super.imageBase64,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
      'imageBase64': imageBase64,
    };
  }

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      text: json['text'] ?? '',
      isUser: json['isUser'] ?? false,
      imageBase64: json['imageBase64'],
    );
  }

  factory ChatMessageModel.fromEntity(ChatMessage message) {
    return ChatMessageModel(
      text: message.text,
      isUser: message.isUser,
      imageBase64: message.imageBase64,
    );
  }
}