import '../../domain/models/settings_model.dart';
import '../../domain/repository/settings_repository.dart';
import '../datasource/settings_local_datasource.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;
  SettingsRepositoryImpl(this.localDataSource);

  @override
  Future<SettingsModel> getSettings() => localDataSource.getSettings();

  @override
  Future<void> saveSettings(SettingsModel settings) =>
      localDataSource.saveSettings(settings);

  @override
  Future<void> clearCache() => localDataSource.clearCache();
}