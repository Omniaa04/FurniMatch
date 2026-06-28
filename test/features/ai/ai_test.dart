import 'dart:typed_data';

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



  test(
  'should send message with image to AI',
  () async {
    // Arrange
    const aiResponse = 'Nice sofa!';

    final image = Uint8List.fromList([1, 2, 3, 4]);

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
      text: 'Analyze this sofa',
      userId: 1,
      imageBytes: image,
      imageName: 'sofa.jpg',
    );

    // Assert
    expect(result, aiResponse);

    verify(
      () => mockRepository.sendMessage(
        text: 'Analyze this sofa',
        userId: 1,
        imageBytes: image,
        imageName: 'sofa.jpg',
      ),
    ).called(1);

    verifyNoMoreInteractions(mockRepository);
  },
);


test(
  'should throw exception when repository fails',
  () async {
    // Arrange
    when(
      () => mockRepository.sendMessage(
        text: any(named: 'text'),
        userId: any(named: 'userId'),
        imageBytes: any(named: 'imageBytes'),
        imageName: any(named: 'imageName'),
      ),
    ).thenThrow(Exception('Server Error'));

    // Act & Assert
    expect(
      () => sendAiMessage(
        text: 'Recommend a chair',
        userId: 1,
      ),
      throwsException,
    );

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

test(
  'should return empty response when AI returns empty string',
  () async {
    // Arrange
    when(
      () => mockRepository.sendMessage(
        text: any(named: 'text'),
        userId: any(named: 'userId'),
        imageBytes: any(named: 'imageBytes'),
        imageName: any(named: 'imageName'),
      ),
    ).thenAnswer((_) async => '');

    // Act
    final result = await sendAiMessage(
      text: 'Hello',
      userId: 1,
    );

    // Assert
    expect(result, '');

    verify(
      () => mockRepository.sendMessage(
        text: 'Hello',
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