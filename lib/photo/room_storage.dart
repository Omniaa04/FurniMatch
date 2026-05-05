import 'package:shared_preferences/shared_preferences.dart';
import 'room_model.dart';

class RoomStorage {
  static const String key = "rooms";

  // ================= SAVE =================
  static Future<void> saveRoom(RoomModel room) async {
    final prefs = await SharedPreferences.getInstance();

    final List<String> rooms = prefs.getStringList(key) ?? [];

    rooms.add(room.toJson());

    await prefs.setStringList(key, rooms);
  }

  // ================= GET =================
  static Future<List<RoomModel>> getRooms() async {
    final prefs = await SharedPreferences.getInstance();

    final List<String> data = prefs.getStringList(key) ?? [];

    return data.map(RoomModel.fromJson).toList();
  }

  // ================= DELETE =================
  static Future<void> deleteRoom(int index) async {
    final prefs = await SharedPreferences.getInstance();

    final List<String> rooms = prefs.getStringList(key) ?? [];

    if (index < 0 || index >= rooms.length) return;

    rooms.removeAt(index);

    await prefs.setStringList(key, rooms);
  }

  // ================= UPDATE =================
  static Future<void> updateRoom(int index, RoomModel updatedRoom) async {
    final prefs = await SharedPreferences.getInstance();

    final List<String> rooms = prefs.getStringList(key) ?? [];

    if (index < 0 || index >= rooms.length) return;

    rooms[index] = updatedRoom.toJson();

    await prefs.setStringList(key, rooms);
  }

  // ================= CLEAR ALL =================
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}