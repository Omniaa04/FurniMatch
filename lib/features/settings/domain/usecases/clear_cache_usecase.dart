import '../repository/settings_repository.dart';

class ClearCacheUseCase {
  final SettingsRepository repository;
  ClearCacheUseCase(this.repository);

  Future<void> call() => repository.clearCache();
}