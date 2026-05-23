// import '../entities/chat_message.dart';
// import '../repositories/chat_repository.dart';

// class SaveMessages {
//   final ChatRepository repository;

//   SaveMessages(this.repository);

//   Future<void> call(List<ChatMessage> messages) {
//     return repository.saveMessages(messages);
//   }
// }
import '../entities/chat_message.dart';
import '../repositories/chat_repository.dart';

class SaveMessages {
  final ChatRepository repository;

  SaveMessages(this.repository);

  Future<void> call(int userId, List<ChatMessage> messages) {
    return repository.saveMessages(userId, messages);
  }
}