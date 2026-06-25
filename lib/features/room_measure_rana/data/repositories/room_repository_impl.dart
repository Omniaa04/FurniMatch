import '../../domain/entities/room_entity.dart';
import '../../domain/repositories/room_repository.dart';
import '../datasources/room_local_datasource.dart';
import '../models/room_model.dart';

class RoomRepositoryImpl implements RoomRepository {
  final RoomLocalDataSource dataSource;

  const RoomRepositoryImpl(this.dataSource);

  @override
  Future<List<RoomEntity>> getRooms() async {
    final models = await dataSource.getRooms();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> saveRoom(RoomEntity room) =>
      dataSource.saveRoom(RoomModel.fromEntity(room));

  @override
  Future<void> deleteRoom(int index) => dataSource.deleteRoom(index);

  @override
  Future<void> updateRoom(int index, RoomEntity room) =>
      dataSource.updateRoom(index, RoomModel.fromEntity(room));

  @override
  Future<void> clearAll() => dataSource.clearAll();
}
