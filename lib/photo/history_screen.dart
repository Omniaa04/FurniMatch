import 'package:flutter/material.dart';
import 'package:room_measure_app_final/photo/room_model.dart';
import 'package:room_measure_app_final/photo/room_storage.dart';
import '../core/app_colors.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<RoomModel> rooms = [];

  @override
  void initState() {
    super.initState();
    loadRooms();
  }

  Future<void> loadRooms() async {
    final data = await RoomStorage.getRooms();
    setState(() => rooms = data);
  }

  Future<void> deleteRoom(int index) async {
    await RoomStorage.deleteRoom(index);
    loadRooms();
  }

  // ================= EDIT NAME =================
  Future<void> editRoomName(int index, RoomModel room) async {
    final controller = TextEditingController(text: room.name);

    final newName = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Room Name"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: "Enter new name",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, controller.text.trim());
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );

    if (newName == null || newName.isEmpty) return;

    final updatedRoom = RoomModel(
      name: newName,
      area: room.area,
      sides: room.sides,
      date: room.date,
    );

    await RoomStorage.updateRoom(index, updatedRoom);
    loadRooms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("History"),
        backgroundColor: AppColors.primary,
      ),
      body: rooms.isEmpty
          ? const Center(
        child: Text(
          "No rooms saved yet",
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        itemCount: rooms.length,
        padding: const EdgeInsets.all(12),
        itemBuilder: (context, index) {
          final room = rooms[index];

          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),

              // ================= TITLE =================
              title: Text(
                room.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),

              // ================= DETAILS =================
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  Text("Area: ${room.area.toStringAsFixed(2)} m²"),
                  Text("Width: ${room.sides[0].toStringAsFixed(2)} m"),
                  Text("Height: ${room.sides[1].toStringAsFixed(2)} m"),
                  const SizedBox(height: 4),
                  Text(
                    room.date,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),

              // ================= ACTIONS =================
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