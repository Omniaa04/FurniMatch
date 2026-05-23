// import '../../domain/models/settings_model.dart';
// import '../../domain/repository/settings_repository.dart';
// import '../datasource/settings_local_datasource.dart';

// class SettingsRepositoryImpl implements SettingsRepository {
//   final SettingsLocalDataSource localDataSource;
//   SettingsRepositoryImpl(this.localDataSource);

//   @override
//   Future<SettingsModel> getSettings() => localDataSource.getSettings();

//   @override
//   Future<void> saveSettings(SettingsModel settings) =>
//       localDataSource.saveSettings(settings);

//   @override
//   Future<void> clearCache() => localDataSource.clearCache();
// }
import '../../domain/models/settings_model.dart';
import '../../domain/repository/settings_repository.dart';
import '../datasource/settings_remote_datasource.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsRemoteDataSource remoteDataSource;
  final int userId;

  SettingsRepositoryImpl({
    required this.remoteDataSource,
    required this.userId,
  });

  @override
  Future<SettingsModel> getSettings() {
    return remoteDataSource.getSettings(userId);
  }

  @override
  Future<void> saveSettings(SettingsModel settings) {
    return remoteDataSource.saveSettings(
      userId: userId,
      settings: settings,
    );
  }

  @override
  Future<void> clearCache() {
    return remoteDataSource.clearCache(userId);
  }
}