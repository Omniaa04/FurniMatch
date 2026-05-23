import '../models/settings_model.dart';

abstract class SettingsRepository {
  Future<SettingsModel> getSettings();
  Future<void> saveSettings(SettingsModel settings);
  Future<void> clearCache();
}