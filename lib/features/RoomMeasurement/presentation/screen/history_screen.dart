import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/room_measurement_bloc.dart';
import '../../domain/models/room_model.dart';

// ─────────────────────────────────────────────
//  HistoryScreen
// ─────────────────────────────────────────────
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<RoomMeasurementBloc>().add(LoadRoomsEvent());

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        title: const Text('room saved',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: BlocBuilder<RoomMeasurementBloc, RoomMeasurementState>(
        builder: (context, state) {
          if (state is SavingState) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is RoomsLoadedState) {
            return state.rooms.isEmpty
                ? _buildEmpty()
                : _buildList(context, state.rooms);
          }
          if (state is RoomMeasurementErrorState) {
            return Center(
                child: Text(state.message,
                    style: const TextStyle(color: Colors.red)));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  // ── Empty ────────────────────────────────────

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.meeting_room_outlined, size: 64, color: Colors.white24),
          SizedBox(height: 16),
          Text('لا توجد غرف محفوظة بعد',
              style: TextStyle(color: Colors.white38, fontSize: 16)),
        ],
      ),
    );
  }

  // ── List ─────────────────────────────────────

  Widget _buildList(BuildContext context, List<RoomModel> rooms) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rooms.length,
      itemBuilder: (context, index) => _RoomCard(
        room: rooms[index],
        onDelete: () =>
            context.read<RoomMeasurementBloc>().add(DeleteRoomEvent(index)),
        onEdit: () => _showEditDialog(context, index, rooms[index]),
      ),
    );
  }

  // ── Edit Dialog ──────────────────────────────

  Future<void> _showEditDialog(
      BuildContext context, int index, RoomModel room) async {
    final controller = TextEditingController(text: room.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (_) => _EditNameDialog(controller: controller),
    );
    if (newName != null && newName.trim().isNotEmpty && context.mounted) {
      context.read<RoomMeasurementBloc>().add(
            UpdateRoomNameEvent(index: index, room: room, newName: newName),
          );
    }
  }
}

// ─────────────────────────────────────────────
//  _RoomCard
// ─────────────────────────────────────────────
class _RoomCard extends StatelessWidget {
  const _RoomCard({
    required this.room,
    required this.onDelete,
    required this.onEdit,
  });

  final RoomModel room;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        children: [
          // ── Icon ──────────────────────────────
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF00E5FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.meeting_room_rounded,
                color: Color(0xFF00E5FF), size: 22),
          ),

          const SizedBox(width: 14),

          // ── Details ───────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(room.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15)),
                const SizedBox(height: 4),
                Text(
                  '${room.widthM.toStringAsFixed(2)} م × ${room.heightM.toStringAsFixed(2)} م  •  ${room.area.toStringAsFixed(2)} م²',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.45), fontSize: 12),
                ),
              ],
            ),
          ),

          // ── Actions ───────────────────────────
          IconButton(
            icon: const Icon(Icons.edit_outlined,
                color: Color(0xFF00E5FF), size: 20),
            onPressed: onEdit,
          ),
          IconButton(
            icon: Icon(Icons.delete_outline,
                color: Colors.red.withOpacity(0.7), size: 20),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  _EditNameDialog
// ─────────────────────────────────────────────
class _EditNameDialog extends StatelessWidget {
  const _EditNameDialog({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تعديل اسم الغرفة'),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(hintText: 'اسم الغرفة'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}