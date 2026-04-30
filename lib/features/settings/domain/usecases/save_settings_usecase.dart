import '../models/settings_model.dart';
import '../repository/settings_repository.dart';

class SaveSettingsUseCase {
  final SettingsRepository repository;
  SaveSettingsUseCase(this.repository);

  Future<void> call(SettingsModel settings) => repository.saveSettings(settings);
}