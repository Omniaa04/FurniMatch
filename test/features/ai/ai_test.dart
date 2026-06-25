import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:furnimatch/features/ai/domain/repositories/chat_repository.dart';
import 'package:furnimatch/features/ai/domain/usecases/send_ai_message.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late MockChatRepository mockRepository;
  late SendAiMessage sendAiMessage;

  setUp(() {
    mockRepository = MockChatRepository();
    sendAiMessage = SendAiMessage(mockRepository);
  });

  group('AI Feature', () {
    test(
      'should send message to AI and return the response',
      () async {
        // Arrange
        const aiResponse = 'I recommend the Modern Chair.';

        when(
          () => mockRepository.sendMessage(
            text: any(named: 'text'),
            userId: any(named: 'userId'),
            imageBytes: any(named: 'imageBytes'),
            imageName: any(named: 'imageName'),
          ),
        ).thenAnswer((_) async => aiResponse);

        // Act
        final result = await sendAiMessage(
          text: 'Recommend a chair',
          userId: 1,
        );

        // Assert
        expect(result, aiResponse);

        verify(
          () => mockRepository.sendMessage(
            text: 'Recommend a chair',
            userId: 1,
            imageBytes: null,
            imageName: null,
          ),
        ).called(1);

        verifyNoMoreInteractions(mockRepository);
      },
    );
  });
}