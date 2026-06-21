import '../entities/room_entity.dart';
import '../repositories/room_repository.dart';

class GetRoomsUseCase {
  final RoomRepository repository;
  const GetRoomsUseCase(this.repository);

  Future<List<RoomEntity>> call() => repository.getRooms();
}

class SaveRoomUseCase {
  final RoomRepository repository;
  const SaveRoomUseCase(this.repository);

  Future<void> call(RoomEntity room) => repository.saveRoom(room);
}

class DeleteRoomUseCase {
  final RoomRepository repository;
  const DeleteRoomUseCase(this.repository);

  Future<void> call(int index) => repository.deleteRoom(index);
}

class UpdateRoomUseCase {
  final RoomRepository repository;
  const UpdateRoomUseCase(this.repository);

  Future<void> call(int index, RoomEntity room) =>
      repository.updateRoom(index, room);
}
