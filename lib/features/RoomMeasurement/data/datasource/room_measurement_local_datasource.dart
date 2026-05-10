import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/room_model.dart';

// ─────────────────────────────────────────────
//  RoomMeasurementLocalDatasource
//  التعامل مع SharedPreferences مباشرة
// ─────────────────────────────────────────────
class RoomMeasurementLocalDatasource {
  static const _key = 'room_measurement_rooms';

  Future<List<RoomModel>> getRooms() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    return data.map(RoomModel.fromJson).toList();
  }

  Future<void> saveRoom(RoomModel room) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    data.add(room.toJson());
    await prefs.setStringList(_key, data);
  }

  Future<void> deleteRoom(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    if (index < 0 || index >= data.length) return;
    data.removeAt(index);
    await prefs.setStringList(_key, data);
  }

  Future<void> updateRoom(int index, RoomModel room) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    if (index < 0 || index >= data.length) return;
    data[index] = room.toJson();
    await prefs.setStringList(_key, data);
  }
}