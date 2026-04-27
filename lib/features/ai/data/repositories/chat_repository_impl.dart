import 'dart:typed_data';

import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_local_datasource.dart';
import '../datasources/chat_remote_datasource.dart';
import '../models/chat_message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatLocalDataSource localDataSource;
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<List<ChatMessage>> loadMessages() {
    return localDataSource.loadMessages();
  }

  @override
  Future<void> saveMessages(List<ChatMessage> messages) {
    final models = messages
        .map((message) => ChatMessageModel.fromEntity(message))
        .toList();

    return localDataSource.saveMessages(models);
  }

  @override
  Future<void> clearMessages(List<ChatMessage> defaultMessages) {
    final models = defaultMessages
        .map((message) => ChatMessageModel.fromEntity(message))
        .toList();

    return localDataSource.clearMessages(models);
  }

  @override
  Future<String> sendMessage({
    required String text,
    Uint8List? imageBytes,
    String? imageName,
  }) {
    return remoteDataSource.sendMessage(
      text: text,
      imageBytes: imageBytes,
      imageName: imageName,
    );
  }
}