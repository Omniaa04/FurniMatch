import '../models/settings_model.dart';
import '../repository/settings_repository.dart';

class GetSettingsUseCase {
  final SettingsRepository repository;
  GetSettingsUseCase(this.repository);

  Future<SettingsModel> call() => repository.getSettings();
}