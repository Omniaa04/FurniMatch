import '../models/room_model.dart';

// ─────────────────────────────────────────────
//  RoomMeasurementRepository – Abstract Contract
// ─────────────────────────────────────────────
abstract class RoomMeasurementRepository {
  Future<List<RoomModel>> getRooms();
  Future<void> saveRoom(RoomModel room);
  Future<void> deleteRoom(int index);
  Future<void> updateRoom(int index, RoomModel room);
}