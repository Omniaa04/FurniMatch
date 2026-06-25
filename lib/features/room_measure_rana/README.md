# room_measure — Clean Architecture

## Folder Structure

```
room_measure/
├── core/
│   └── homography.dart          # Math utilities (homography, distance)
│
├── domain/                      # Pure Dart — no Flutter, no packages
│   ├── entities/
│   │   ├── room_entity.dart          # RoomEntity
│   │   └── measurement_entities.dart # ReferenceObjectEntity, MeasurementResultEntity,
│   │                                 # MarkingAction, PointGroup
│   ├── repositories/
│   │   └── room_repository.dart      # Abstract RoomRepository interface
│   ├── usecases/
│   │   └── room_usecases.dart        # GetRooms, SaveRoom, DeleteRoom, UpdateRoom
│   └── domain.dart                   # Barrel export
│
├── data/                        # Implements domain contracts
│   ├── models/
│   │   └── room_model.dart           # RoomModel  ↔  RoomEntity (fromEntity / toEntity)
│   ├── datasources/
│   │   └── room_local_datasource.dart # Abstract + SharedPreferences impl
│   ├── repositories/
│   │   └── room_repository_impl.dart  # RoomRepositoryImpl
│   └── data.dart                      # Barrel export
│
└── presentation/                # Flutter UI
    ├── theme/
    │   └── app_colors.dart
    ├── animations/
    │   └── tutorial_animations.dart
    ├── screens/
    │   ├── reference_screen.dart
    │   ├── photo_marking_screen.dart
    │   ├── measurement_result_screen.dart
    │   └── history_screen.dart
    └── presentation.dart         # Barrel export
```

## Dependency Rule

```
presentation  →  domain  ←  data
```

- **Domain** knows nothing about Flutter or storage libraries.
- **Data** implements domain interfaces; only it imports `shared_preferences`.
- **Presentation** calls use cases directly (no DI framework needed at this scale).

## Key Changes vs. Original

| Before | After |
|---|---|
| `RoomModel` used everywhere | `RoomEntity` in domain; `RoomModel` only in data layer |
| `ReferenceObject` in `models.dart` | `ReferenceObjectEntity` in `domain/entities` |
| `MeasurementResult` in `models.dart` | `MeasurementResultEntity` in `domain/entities` |
| `RoomStorage.saveRoom(...)` called from screens | `SaveRoomUseCase(repo).call(room)` |
| `RoomStorage.getRooms()` called from screens | `GetRoomsUseCase(repo).call()` |
| `app_colors.dart` in `core/` | `presentation/theme/app_colors.dart` |
| `tutorial_animations.dart` at feature root | `presentation/animations/` |
| `homography.dart` at feature root | `core/homography.dart` |

## Extending with DI

To add a proper DI container (e.g. `get_it`):

```dart
// injection_container.dart
final sl = GetIt.instance;

void init() {
  sl.registerLazySingleton<RoomLocalDataSource>(() => RoomLocalDataSourceImpl());
  sl.registerLazySingleton<RoomRepository>(() => RoomRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetRoomsUseCase(sl()));
  sl.registerLazySingleton(() => SaveRoomUseCase(sl()));
  sl.registerLazySingleton(() => DeleteRoomUseCase(sl()));
  sl.registerLazySingleton(() => UpdateRoomUseCase(sl()));
}
```
