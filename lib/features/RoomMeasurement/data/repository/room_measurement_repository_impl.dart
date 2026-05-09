import '../../domain/models/room_model.dart';
import '../../domain/repository/room_measurement_repository.dart';
import '../datasource/room_measurement_local_datasource.dart';

// ─────────────────────────────────────────────
//  RoomMeasurementRepositoryImpl
// ─────────────────────────────────────────────
class RoomMeasurementRepositoryImpl implements RoomMeasurementRepository {
  const RoomMeasurementRepositoryImpl(this._datasource);

  final RoomMeasurementLocalDatasource _datasource;

  @override
  Future<List<RoomModel>> getRooms() => _datasource.getRooms();

  @override
  Future<void> saveRoom(RoomModel room) => _datasource.saveRoom(room);

  @override
  Future<void> deleteRoom(int index) => _datasource.deleteRoom(index);

  @override
  Future<void> updateRoom(int index, RoomModel room) =>
      _datasource.updateRoom(index, room);
}