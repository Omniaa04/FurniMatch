import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Screens (unused direct imports - kept for routing)
import 'features/shipping/presentation/screen/shipping_address_screen.dart';
import 'features/product_details/presentation/screen/product_details_screen.dart';
import 'features/tracking/presentation/screen/order_tracking_screen.dart';
import 'features/location/presentation/screen/select_location_screen.dart';
import 'features/shipping/presentation/screen/save_address_screen.dart';
import 'features/notifications/presentation/screen/notifications_screen.dart';
import 'features/Favorite/presentation/screen/favorites_screen.dart';

// Settings imports
import 'features/settings/data/datasource/settings_local_datasource.dart';
import 'features/settings/data/repository/settings_repository_impl.dart';
import 'features/settings/domain/usecases/get_settings_usecase.dart';
import 'features/settings/domain/usecases/save_settings_usecase.dart';
import 'features/settings/domain/usecases/clear_cache_usecase.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'features/settings/presentation/screen/settings_screen.dart';

// Points imports
import 'features/points/data/datasource/points_local_datasource.dart';
import 'features/points/data/repository/points_repository_impl.dart';
import 'features/points/domain/usecases/points_usecases.dart';
import 'features/points/presentation/bloc/points_bloc.dart';
import 'features/points/presentation/screen/points_screen.dart';

// RoomMeasurement imports ✅
import 'features/RoomMeasurement/data/datasource/room_measurement_local_datasource.dart';
import 'features/RoomMeasurement/data/repository/room_measurement_repository_impl.dart';
import 'features/RoomMeasurement/data/services/ar_measurement_service.dart';
import 'features/RoomMeasurement/domain/usecases/room_measurement_usecases.dart';
import 'features/RoomMeasurement/presentation/bloc/room_measurement_bloc.dart';
import 'features/RoomMeasurement/presentation/screen/ar_measurement_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Settings
    final settingsDataSource = SettingsLocalDataSourceImpl();
    final settingsRepo = SettingsRepositoryImpl(settingsDataSource);

    // Points
    final pointsDataSource = PointsLocalDataSourceImpl();
    final pointsRepo = PointsRepositoryImpl(pointsDataSource);

    // RoomMeasurement ✅
    final roomDatasource = RoomMeasurementLocalDatasource();
    final roomRepo = RoomMeasurementRepositoryImpl(roomDatasource);

    return MultiBlocProvider(
      providers: [
        // Settings Bloc
        BlocProvider(
          create: (_) => SettingsBloc(
            getSettings: GetSettingsUseCase(settingsRepo),
            saveSettings: SaveSettingsUseCase(settingsRepo),
            clearCache: ClearCacheUseCase(settingsRepo),
          )..add(LoadSettingsEvent()),
        ),

        // Points Bloc
        BlocProvider(
          create: (_) => PointsBloc(
            getPoints: GetPointsUseCase(pointsRepo),
            earnPoints: EarnPointsUseCase(pointsRepo),
            redeemPoints: RedeemPointsUseCase(pointsRepo),
            savePoints: SavePointsUseCase(pointsRepo),
          )..add(LoadPointsEvent()),
        ),

        // RoomMeasurement Bloc ✅
        BlocProvider(
          create: (_) => RoomMeasurementBloc(
            arService: ArMeasurementService(),
            getRooms: GetRoomsUseCase(roomRepo),
            saveRoom: SaveRoomUseCase(roomRepo),
            deleteRoom: DeleteRoomUseCase(roomRepo),
            updateRoomName: UpdateRoomNameUseCase(roomRepo),
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Furniture App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8B5A3C)),
          useMaterial3: true,
        ),
        home: const ArMeasurementScreen(), // ← غيرناها للـ AR screen
      ),
    );
  }
}