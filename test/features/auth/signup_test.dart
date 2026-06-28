import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:furnimatch/features/auth/domain/entities/auth_user.dart';
import 'package:furnimatch/features/auth/domain/repositories/auth_repository.dart';
import 'package:furnimatch/features/auth/domain/usecases/signup_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;
  late SignupUseCase signupUseCase;

  setUp(() {
    mockRepository = MockAuthRepository();
    signupUseCase = SignupUseCase(mockRepository);
  });

  group('SignupUseCase', () {
    test(
      'should return AuthUser when signup succeeds',
      () async {
        // Arrange
        final user = AuthUser(
          userId: 2,
          name: 'Shahd',
          role: 'customer',
        );

        when(
          () => mockRepository.signup(
            name: any(named: 'name'),
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => user);

        // Act
        final result = await signupUseCase(
          name: 'Shahd',
          email: 'shahd@test.com',
          password: '123456',
        );

        // Assert
        expect(result, isA<AuthUser>());
        expect(result.userId, 2);
        expect(result.name, 'Shahd');
        expect(result.role, 'customer');

        verify(
          () => mockRepository.signup(
            name: 'Shahd',
            email: 'shahd@test.com',
            password: '123456',
          ),
        ).called(1);

        verifyNoMoreInteractions(mockRepository);
      },
    );
  });
}