import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:furnimatch/features/auth/domain/entities/auth_user.dart';
import 'package:furnimatch/features/auth/domain/repositories/auth_repository.dart';
import 'package:furnimatch/features/auth/domain/usecases/login_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;
  late LoginUseCase loginUseCase;

  setUp(() {
    mockRepository = MockAuthRepository();
    loginUseCase = LoginUseCase(mockRepository);
  });

  group('Authentication Feature', () {
    test(
      'LoginUseCase should return an AuthUser when repository login succeeds',
      () async {
        // Arrange
        final user = AuthUser(
          userId: 1,
          name: 'Shahd',
          role: 'customer',
        );

        when(
          () => mockRepository.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => user);

        // Act
        final result = await loginUseCase(
          email: 'shahd@test.com',
          password: '123456',
        );

        // Assert
        expect(result, isA<AuthUser>());
        expect(result.userId, 1);
        expect(result.name, 'Shahd');
        expect(result.role, 'customer');

        verify(
          () => mockRepository.login(
            email: 'shahd@test.com',
            password: '123456',
          ),
        ).called(1);

        verifyNoMoreInteractions(mockRepository);
      },
    );
   //news
   test(
  'LoginUseCase should throw Exception when repository login fails',
  () async {
    // Arrange
    when(
      () => mockRepository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(Exception('Invalid credentials'));

    // Act & Assert
    expect(
      () => loginUseCase(
        email: 'wrong@test.com',
        password: 'wrong123',
      ),
      throwsA(isA<Exception>()),
    );

    verify(
      () => mockRepository.login(
        email: 'wrong@test.com',
        password: 'wrong123',
      ),
    ).called(1);

    verifyNoMoreInteractions(mockRepository);
  },
);


test(
  'LoginUseCase should return another AuthUser correctly',
  () async {
    // Arrange
    final user = AuthUser(
      userId: 25,
      name: 'Ali',
      role: 'admin',
    );

    when(
      () => mockRepository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => user);

    // Act
    final result = await loginUseCase(
      email: 'ali@test.com',
      password: 'admin123',
    );

    // Assert
    expect(result.userId, 25);
    expect(result.name, 'Ali');
    expect(result.role, 'admin');

    verify(
      () => mockRepository.login(
        email: 'ali@test.com',
        password: 'admin123',
      ),
    ).called(1);

    verifyNoMoreInteractions(mockRepository);
  },
);



test(
  'LoginUseCase should return exactly the repository object',
  () async {
    // Arrange
    final user = AuthUser(
      userId: 7,
      name: 'Mona',
      role: 'customer',
    );

    when(
      () => mockRepository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => user);

    // Act
    final result = await loginUseCase(
      email: 'mona@test.com',
      password: 'password',
    );

    // Assert
    expect(identical(result, user), isTrue);

    verify(
      () => mockRepository.login(
        email: 'mona@test.com',
        password: 'password',
      ),
    ).called(1);

    verifyNoMoreInteractions(mockRepository);
  },
);


  });
}