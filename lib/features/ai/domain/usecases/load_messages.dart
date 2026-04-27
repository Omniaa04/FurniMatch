import '../entities/chat_message.dart';
import '../repositories/chat_repository.dart';

class LoadMessages {
  final ChatRepository repository;

  LoadMessages(this.repository);

  Future<List<ChatMessage>> call() {
    return repository.loadMessages();
  }
}