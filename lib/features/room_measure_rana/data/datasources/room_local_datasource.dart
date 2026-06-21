import 'package:shared_preferences/shared_preferences.dart';
import '../models/room_model.dart';

abstract class RoomLocalDataSource {
  Future<List<RoomModel>> getRooms();
  Future<void> saveRoom(RoomModel room);
  Future<void> deleteRoom(int index);
  Future<void> updateRoom(int index, RoomModel room);
  Future<void> clearAll();
}

class RoomLocalDataSourceImpl implements RoomLocalDataSource {
  static const String _key = 'rooms';

  @override
  Future<List<RoomModel>> getRooms() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    return data.map(RoomModel.fromJson).toList();
  }

  @override
  Future<void> saveRoom(RoomModel room) async {
    final prefs = await SharedPreferences.getInstance();
    final rooms = prefs.getStringList(_key) ?? [];
    rooms.add(room.toJson());
    await prefs.setStringList(_key, rooms);
  }

  @override
  Future<void> deleteRoom(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final rooms = prefs.getStringList(_key) ?? [];
    if (index < 0 || index >= rooms.length) return;
    rooms.removeAt(index);
    await prefs.setStringList(_key, rooms);
  }

  @override
  Future<void> updateRoom(int index, RoomModel room) async {
    final prefs = await SharedPreferences.getInstance();
    final rooms = prefs.getStringList(_key) ?? [];
    if (index < 0 || index >= rooms.length) return;
    rooms[index] = room.toJson();
    await prefs.setStringList(_key, rooms);
  }

  @override
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
