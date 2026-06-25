import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:furnimatch/features/settings/domain/models/settings_model.dart';
import 'package:furnimatch/features/settings/domain/repository/settings_repository.dart';
import 'package:furnimatch/features/settings/domain/usecases/save_settings_usecase.dart';

class MockSettingsRepository extends Mock
    implements SettingsRepository {}

void main() {
  late MockSettingsRepository mockRepository;
  late SaveSettingsUseCase saveSettingsUseCase;

  setUpAll(() {
    registerFallbackValue(
      const SettingsModel(
        notificationsEnabled: true,
        language: 'English',
      ),
    );
  });

  setUp(() {
    mockRepository = MockSettingsRepository();
    saveSettingsUseCase = SaveSettingsUseCase(mockRepository);
  });

  group('Settings Feature', () {
    test('should save user settings successfully', () async {
      // Arrange
      const settings = SettingsModel(
        notificationsEnabled: false,
        language: 'Arabic',
        userName: 'Shahd',
        userEmail: 'shahd@example.com',
        profileImagePath: '/images/profile.png',
      );

      when(() => mockRepository.saveSettings(settings))
          .thenAnswer((_) async {});

      // Act
      await saveSettingsUseCase(settings);

      // Assert
      verify(() => mockRepository.saveSettings(settings)).called(1);

      verifyNoMoreInteractions(mockRepository);
    });
  });

test('copyWith should update only provided fields', () {
  const settings = SettingsModel(
    notificationsEnabled: true,
    language: 'English',
    userName: 'Shahd',
  );

  final updated = settings.copyWith(
    language: 'Arabic',
    notificationsEnabled: false,
  );

  expect(updated.language, 'Arabic');
  expect(updated.notificationsEnabled, false);

  // Unchanged fields
  expect(updated.userName, 'Shahd');
  expect(updated.userEmail, null);
});


}