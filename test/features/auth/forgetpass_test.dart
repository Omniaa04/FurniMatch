import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:furnimatch/features/auth/domain/repositories/auth_repository.dart';
import 'package:furnimatch/features/auth/domain/usecases/forgot_password_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;
  late ForgotPasswordUseCase forgotPasswordUseCase;

  setUp(() {
    mockRepository = MockAuthRepository();
    forgotPasswordUseCase = ForgotPasswordUseCase(mockRepository);
  });

  group('ForgotPasswordUseCase', () {
    test(
      'should call repository forgotPassword successfully',
      () async {
        // Arrange
        when(
          () => mockRepository.forgotPassword(
            email: any(named: 'email'),
          ),
        ).thenAnswer((_) async {});

        // Act
        await forgotPasswordUseCase(
          email: 'shahd@test.com',
        );

        // Assert
        verify(
          () => mockRepository.forgotPassword(
            email: 'shahd@test.com',
          ),
        ).called(1);

        verifyNoMoreInteractions(mockRepository);
      },
    );

    test(
      'should throw Exception when repository fails',
      () async {
        // Arrange
        when(
          () => mockRepository.forgotPassword(
            email: any(named: 'email'),
          ),
        ).thenThrow(Exception('Failed to send OTP'));

        // Act & Assert
        expect(
          () => forgotPasswordUseCase(
            email: 'shahd@test.com',
          ),
          throwsException,
        );

        verify(
          () => mockRepository.forgotPassword(
            email: 'shahd@test.com',
          ),
        ).called(1);

        verifyNoMoreInteractions(mockRepository);
      },
    );
  });
}