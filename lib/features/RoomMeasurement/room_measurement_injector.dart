import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/datasource/room_measurement_local_datasource.dart';
import 'data/repository/room_measurement_repository_impl.dart';
import 'data/services/ar_measurement_service.dart';
import 'domain/usecases/room_measurement_usecases.dart';
import 'presentation/bloc/room_measurement_bloc.dart';



class RoomMeasurementInjector {
  RoomMeasurementInjector._();

  static BlocProvider<RoomMeasurementBloc> provideBloc({
    required Widget child,
  }) {
    // ── Data layer ─────────────────────────────
    final datasource = RoomMeasurementLocalDatasource();
    final repository = RoomMeasurementRepositoryImpl(datasource);

    // ── Domain layer ───────────────────────────
    final getRooms = GetRoomsUseCase(repository);
    final saveRoom = SaveRoomUseCase(repository);
    final deleteRoom = DeleteRoomUseCase(repository);
    final updateRoomName = UpdateRoomNameUseCase(repository);

    // ── AR service ─────────────────────────────
    final arService = ArMeasurementService();

    return BlocProvider(
      create: (_) => RoomMeasurementBloc(
        arService: arService,
        getRooms: getRooms,
        saveRoom: saveRoom,
        deleteRoom: deleteRoom,
        updateRoomName: updateRoomName,
      ),
      child: child,
    );
  }
}