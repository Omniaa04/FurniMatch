import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:furnimatch/features/auth/domain/repositories/auth_repository.dart';
import 'package:furnimatch/features/auth/domain/usecases/resend_otp_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;
  late ResendOtpUseCase resendOtpUseCase;

  setUp(() {
    mockRepository = MockAuthRepository();
    resendOtpUseCase = ResendOtpUseCase(mockRepository);
  });

  group('Authentication Feature - Resend OTP', () {
    testWidgets(
      'ResendOtpUseCase should call repository resendOtp successfully',
      (tester) async {
        // Arrange
        when(
          () => mockRepository.resendOtp(
            email: any(named: 'email'),
          ),
        ).thenAnswer((_) async {});

        // Act
        await resendOtpUseCase(
          email: 'shahd@test.com',
        );

        // Assert
        verify(
          () => mockRepository.resendOtp(
            email: 'shahd@test.com',
          ),
        ).called(1);

        verifyNoMoreInteractions(mockRepository);
      },
    );
  });
}