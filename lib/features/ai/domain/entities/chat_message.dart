class ChatMessage {
  final String text;
  final bool isUser;
  final String? imageBase64;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.imageBase64,
  });
}