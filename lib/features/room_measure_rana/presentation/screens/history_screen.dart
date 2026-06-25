import 'package:flutter/material.dart';
import '../../domain/entities/room_entity.dart';
import '../../data/datasources/room_local_datasource.dart';
import '../../data/repositories/room_repository_impl.dart';
import '../../domain/usecases/room_usecases.dart';
import '../theme/app_colors.dart';

class RoomHistoryScreen extends StatefulWidget {
  const RoomHistoryScreen({super.key});

  @override
  State<RoomHistoryScreen> createState() => _RoomHistoryScreenState();
}

class _RoomHistoryScreenState extends State<RoomHistoryScreen> {
  List<RoomEntity> rooms = [];

  late final _repo = RoomRepositoryImpl(RoomLocalDataSourceImpl());
  late final _getRooms = GetRoomsUseCase(_repo);
  late final _deleteRoom = DeleteRoomUseCase(_repo);
  late final _updateRoom = UpdateRoomUseCase(_repo);

  @override
  void initState() {
    super.initState();
    loadRooms();
  }

  Future<void> loadRooms() async {
    final data = await _getRooms();
    setState(() => rooms = data);
  }

  Future<void> deleteRoom(int index) async {
    await _deleteRoom(index);
    loadRooms();
  }

  Future<void> editRoomName(int index, RoomEntity room) async {
    final controller = TextEditingController(text: room.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Room Name"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Enter new name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text("Save"),
          ),
        ],
      ),
    );

    if (newName == null || newName.isEmpty) return;
    await _updateRoom(
      index,
      RoomEntity(name: newName, area: room.area, sides: room.sides, date: room.date),
    );
    loadRooms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RoomAppColors.background,
      appBar: AppBar(
        title: const Text("Room History"),
        backgroundColor: RoomAppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: rooms.isEmpty
          ? const Center(
              child: Text("No rooms saved yet", style: TextStyle(fontSize: 16)))
          : ListView.builder(
              itemCount: rooms.length,
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final room = rooms[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(room.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text("Area: ${room.area.toStringAsFixed(2)} m²"),
                        Text("Width: ${room.sides[0].toStringAsFixed(2)} m"),
                        Text("Height: ${room.sides[1].toStringAsFixed(2)} m"),
                        const SizedBox(height: 4),
                        Text(room.date, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => editRoomName(index, room),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteRoom(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
