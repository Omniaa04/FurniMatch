import '../entities/room_entity.dart';

abstract class RoomRepository {
  Future<List<RoomEntity>> getRooms();
  Future<void> saveRoom(RoomEntity room);
  Future<void> deleteRoom(int index);
  Future<void> updateRoom(int index, RoomEntity room);
  Future<void> clearAll();
}
