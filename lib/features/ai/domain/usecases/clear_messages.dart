// import '../entities/chat_message.dart';
// import '../repositories/chat_repository.dart';

// class ClearMessages {
//   final ChatRepository repository;

//   ClearMessages(this.repository);

//   Future<void> call(List<ChatMessage> defaultMessages) {
//     return repository.clearMessages(defaultMessages);
//   }
// }
import '../entities/chat_message.dart';
import '../repositories/chat_repository.dart';

class ClearMessages {
  final ChatRepository repository;

  ClearMessages(this.repository);

  Future<void> call(int userId, List<ChatMessage> defaultMessages) {
    return repository.clearMessages(userId, defaultMessages);
  }
}