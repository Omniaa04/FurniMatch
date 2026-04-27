import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/settings_model.dart';

abstract class SettingsLocalDataSource {
  Future<SettingsModel> getSettings();
  Future<void> saveSettings(SettingsModel settings);
  Future<void> clearCache();
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  static const _key = 'app_settings';

  @override
  Future<SettingsModel> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json == null) return const SettingsModel();
    return SettingsModel.fromJson(jsonDecode(json));
  }

  @override
  Future<void> saveSettings(SettingsModel settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(settings.toJson()));
  }

  @override
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    // Clear AR-related cache keys only
    final keys = prefs.getKeys().where((k) => k.startsWith('ar_cache_')).toList();
    for (final k in keys) {
      await prefs.remove(k);
    }
  }
}