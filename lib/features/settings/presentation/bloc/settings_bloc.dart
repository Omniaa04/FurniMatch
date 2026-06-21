import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/models/settings_model.dart';
import '../../domain/usecases/get_settings_usecase.dart';
import '../../domain/usecases/save_settings_usecase.dart';
import '../../domain/usecases/clear_cache_usecase.dart';

// ─── Events ───────────────────────────────────────────────────────────────────

abstract class SettingsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadSettingsEvent extends SettingsEvent {}

class ToggleNotificationsEvent extends SettingsEvent {}

class ChangeLanguageEvent extends SettingsEvent {
  final String language;
  ChangeLanguageEvent(this.language);
  @override
  List<Object?> get props => [language];
}

class UpdateProfileEvent extends SettingsEvent {
  final String userName;
  final String? profileImagePath;
  UpdateProfileEvent({required this.userName, this.profileImagePath});
  @override
  List<Object?> get props => [userName, profileImagePath];
}

class ClearCacheEvent extends SettingsEvent {}

// ─── States ───────────────────────────────────────────────────────────────────

abstract class SettingsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final SettingsModel settings;
  SettingsLoaded(this.settings);
  @override
  List<Object?> get props => [settings];
}

class SettingsError extends SettingsState {
  final String message;
  SettingsError(this.message);
  @override
  List<Object?> get props => [message];
}

class CacheCleared extends SettingsState {
  final SettingsModel settings;
  CacheCleared(this.settings);
  @override
  List<Object?> get props => [settings];
}

// ─── Bloc ─────────────────────────────────────────────────────────────────────

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetSettingsUseCase getSettings;
  final SaveSettingsUseCase saveSettings;
  final ClearCacheUseCase clearCache;

  SettingsBloc({
    required this.getSettings,
    required this.saveSettings,
    required this.clearCache,
  }) : super(SettingsInitial()) {
    on<LoadSettingsEvent>(_onLoad);
    on<ToggleNotificationsEvent>(_onToggleNotifications);
    on<ChangeLanguageEvent>(_onChangeLanguage);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<ClearCacheEvent>(_onClearCache);
  }

  Future<void> _onLoad(LoadSettingsEvent e, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());
    try {
      final s = await getSettings();
      emit(SettingsLoaded(s));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onToggleNotifications(
      ToggleNotificationsEvent e, Emitter<SettingsState> emit) async {
    if (state is! SettingsLoaded) return;
    final cur = (state as SettingsLoaded).settings;
    final updated = cur.copyWith(notificationsEnabled: !cur.notificationsEnabled);
    await saveSettings(updated);
    emit(SettingsLoaded(updated));
  }

  Future<void> _onChangeLanguage(
      ChangeLanguageEvent e, Emitter<SettingsState> emit) async {
    if (state is! SettingsLoaded) return;
    final updated =
        (state as SettingsLoaded).settings.copyWith(language: e.language);
    await saveSettings(updated);
    emit(SettingsLoaded(updated));
  }

  Future<void> _onUpdateProfile(
      UpdateProfileEvent e, Emitter<SettingsState> emit) async {
    if (state is! SettingsLoaded) return;
    final cur = (state as SettingsLoaded).settings;
    final updated = cur.copyWith(
      userName: e.userName,
      profileImagePath: e.profileImagePath ?? cur.profileImagePath,
    );
    await saveSettings(updated);
    emit(SettingsLoaded(updated));
  }

  Future<void> _onClearCache(
      ClearCacheEvent e, Emitter<SettingsState> emit) async {
    if (state is! SettingsLoaded) return;
    final cur = (state as SettingsLoaded).settings;
    await clearCache();
    emit(CacheCleared(cur));
    emit(SettingsLoaded(cur));
  }
}