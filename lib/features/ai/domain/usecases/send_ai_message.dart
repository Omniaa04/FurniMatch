// import 'dart:typed_data';

// import '../repositories/chat_repository.dart';

// class SendAiMessage {
//   final ChatRepository repository;

//   SendAiMessage(this.repository);

//   Future<String> call({
//     required String text,
//     Uint8List? imageBytes,
//     String? imageName,
//   }) {
//     return repository.sendMessage(
//       text: text,
//       imageBytes: imageBytes,
//       imageName: imageName,
//     );
//   }
// }
import 'dart:typed_data';

import '../repositories/chat_repository.dart';

class SendAiMessage {
  final ChatRepository repository;

  SendAiMessage(this.repository);

  Future<String> call({
    required String text,
    required int userId,
    Uint8List? imageBytes,
    String? imageName,
  }) {
    return repository.sendMessage(
      text: text,
      userId: userId,
      imageBytes: imageBytes,
      imageName: imageName,
    );
  }
}