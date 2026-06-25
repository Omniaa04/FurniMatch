import 'package:flutter_test/flutter_test.dart';
import 'package:furnimatch/features/chat/data/models/chat_repository.dart';

void main() {
  group('ChatMessage Entity', () {
    test('fromMap should create ChatMessage correctly', () {
      final map = {
        'sender_id': 1,
        'receiver_id': 2,
        'store_id': 10,
        'text': 'Hello',
        'image_url': 'image.jpg',
        'created_at': '2026-06-26T10:00:00',
      };

      final message = ChatMessage.fromMap(map);

      expect(message.senderId, 1);
      expect(message.receiverId, 2);
      expect(message.storeId, 10);
      expect(message.text, 'Hello');
      expect(message.imageUrl, 'image.jpg');
      expect(message.isPending, false);
      expect(message.isLocal, false);
    });

    test('copyWith should update pending status', () {
      const message = ChatMessage(
        senderId: 1,
        receiverId: 2,
        storeId: 3,
        text: 'Hello',
        createdAt: '2026-06-26',
      );

      final updated = message.copyWith(isPending: true);

      expect(updated.isPending, true);
      expect(updated.text, 'Hello');
      expect(updated.senderId, 1);
    });
  });
}