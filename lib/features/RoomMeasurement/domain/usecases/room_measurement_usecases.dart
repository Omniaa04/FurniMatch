import '../models/room_model.dart';
import '../repository/room_measurement_repository.dart';

// ─────────────────────────────────────────────
//  Use Cases – كل use case = action واحدة
// ─────────────────────────────────────────────

class GetRoomsUseCase {
  const GetRoomsUseCase(this._repo);
  final RoomMeasurementRepository _repo;
  Future<List<RoomModel>> call() => _repo.getRooms();
}

class SaveRoomUseCase {
  const SaveRoomUseCase(this._repo);
  final RoomMeasurementRepository _repo;
  Future<void> call(RoomModel room) => _repo.saveRoom(room);
}

class DeleteRoomUseCase {
  const DeleteRoomUseCase(this._repo);
  final RoomMeasurementRepository _repo;
  Future<void> call(int index) => _repo.deleteRoom(index);
}

class UpdateRoomNameUseCase {
  const UpdateRoomNameUseCase(this._repo);
  final RoomMeasurementRepository _repo;

  Future<void> call(int index, RoomModel room, String newName) {
    return _repo.updateRoom(index, room.copyWith(name: newName.trim()));
  }
}