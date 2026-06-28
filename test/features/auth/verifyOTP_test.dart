import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:furnimatch/features/auth/domain/repositories/auth_repository.dart';
import 'package:furnimatch/features/auth/domain/usecases/verify_otp_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;
  late VerifyOtpUseCase verifyOtpUseCase;

  setUp(() {
    mockRepository = MockAuthRepository();
    verifyOtpUseCase = VerifyOtpUseCase(mockRepository);
  });

  group('VerifyOtpUseCase', () {
    test(
      'should call repository verifyOtp successfully',
      () async {
        // Arrange
        when(
          () => mockRepository.verifyOtp(
            email: any(named: 'email'),
            otp: any(named: 'otp'),
          ),
        ).thenAnswer((_) async {});

        // Act
        await verifyOtpUseCase(
          email: 'shahd@test.com',
          otp: '123456',
        );

        // Assert
        verify(
          () => mockRepository.verifyOtp(
            email: 'shahd@test.com',
            otp: '123456',
          ),
        ).called(1);

        verifyNoMoreInteractions(mockRepository);
      },
    );

    test(
      'should throw Exception when repository verifyOtp fails',
      () async {
        // Arrange
        when(
          () => mockRepository.verifyOtp(
            email: any(named: 'email'),
            otp: any(named: 'otp'),
          ),
        ).thenThrow(Exception('Invalid OTP'));

        // Act & Assert
        expect(
          () => verifyOtpUseCase(
            email: 'shahd@test.com',
            otp: '000000',
          ),
          throwsException,
        );

        // Verify
        verify(
          () => mockRepository.verifyOtp(
            email: 'shahd@test.com',
            otp: '000000',
          ),
        ).called(1);

        verifyNoMoreInteractions(mockRepository);
      },
    );
  });
}