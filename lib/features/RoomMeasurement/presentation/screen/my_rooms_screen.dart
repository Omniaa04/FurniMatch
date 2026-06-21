import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:furnimatch/api_config.dart';
import 'room_3d_screen.dart';
import 'room_setup_screen.dart';
import 'package:furnimatch/features/buttom_nav/main_shell.dart';

const _kPrimary = Color(0xFFCF8D5B);
const _kDark    = Color(0xFF7D533D);
const _kMedium  = Color(0xFFA36846);
const _kLight   = Color(0xFFF5D1A9);
const _kBg      = Color(0xFFFDF6EE);

class MyRoomsScreen extends StatefulWidget {
  final bool fromNav;
  final VoidCallback? onBackToHome;

  const MyRoomsScreen({
    super.key,
    this.fromNav = false,
    this.onBackToHome,
  });

  @override
  State<MyRoomsScreen> createState() => _MyRoomsScreenState();
}

class _MyRoomsScreenState extends State<MyRoomsScreen> {
  List<Map<String, dynamic>> _rooms = [];
  bool _isLoading = true;
  int? _cachedUserId;        // ← هنا
  String? _cachedUserName;   // ← هنا

  @override
  void initState() {
    super.initState();
    _loadRooms();
    _loadUserData();  // ← هنا
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _cachedUserId = prefs.getInt('user_id');
        _cachedUserName = prefs.getString('user_name');
      });
    }
  }

  Future<void> _loadRooms() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      if (userId == null) {
        setState(() => _isLoading = false);
        return;
      }
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/rooms/list?user_id=$userId'),
        headers: {'ngrok-skip-browser-warning': 'true'},
      );
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        setState(() => _rooms = data.cast<Map<String, dynamic>>());
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _deleteRoom(int id) async {
    try {
      await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/rooms/$id'),
        headers: {'ngrok-skip-browser-warning': 'true'},
      );
      await _loadRooms();
    } catch (_) {}
  }

  void _openRoom(Map<String, dynamic> r) {
    // ✅ بعتي الـ furniture مع الـ room عشان تتحمل في Room3DScreen
    final furnitureData = (r['furniture'] as List?)
        ?.map((e) => Map<String, dynamic>.from(e as Map))
        .toList() ?? [];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Room3DScreen(
          roomWidth:        (r['width']  as num).toDouble(),
          roomLength:       (r['length'] as num).toDouble(),
          roomHeight:       (r['height'] as num).toDouble(),
          initialFurniture: furnitureData, // ✅ جديد
        ),
      ),
    );
  }

  void _goToNewRoom() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RoomSetupScreen()),
    );
  }




  void _handleBack() {
    if (widget.fromNav) {
      widget.onBackToHome?.call();
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => MainShell(
            userId: _cachedUserId,
            userName: _cachedUserName,
            initialIndex: 0,
          ),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: _kDark, size: 20),
          onPressed: _handleBack,
        ),
        title: const Text(
          'My Rooms',
          style: TextStyle(
              color: _kDark,
              fontSize: 22,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: _kMedium),
            onPressed: _loadRooms,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _kPrimary))
          : _rooms.isEmpty
              ? _buildEmpty()
              : _buildList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToNewRoom,
        backgroundColor: _kPrimary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'New Room',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: _kLight.withValues(alpha: .5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.meeting_room_outlined,
                size: 56, color: _kDark),
          ),
          const SizedBox(height: 20),
          const Text(
            'No rooms yet',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: _kDark),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the button below to add your first room',
            style: TextStyle(color: _kMedium, fontSize: 14),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _goToNewRoom,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Add First Room',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kPrimary,
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return RefreshIndicator(
      color: _kPrimary,
      onRefresh: _loadRooms,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        itemCount: _rooms.length,
        itemBuilder: (_, i) => _RoomCard(
          room: _rooms[i],
          onOpen: () => _openRoom(_rooms[i]),
          onDelete: () => _deleteRoom(_rooms[i]['id'] as int),
        ),
      ),
    );
  }
}

// ─── Room Card ────────────────────────────────────────────────────────────────
class _RoomCard extends StatelessWidget {
  final Map<String, dynamic> room;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  const _RoomCard({
    required this.room,
    required this.onOpen,
    required this.onDelete,
  });

  String get _emoji {
    final name = (room['name'] as String? ?? '').toLowerCase();
    if (name.contains('living'))  return '🛋';
    if (name.contains('kitchen')) return '🍳';
    if (name.contains('bed'))     return '🛏';
    if (name.contains('bath'))    return '🛁';
    if (name.contains('dining'))  return '🍽';
    if (name.contains('laundry')) return '🧺';
    if (name.contains('office'))  return '🖥';
    if (name.contains('kids'))    return '🧸';
    return '🏠';
  }

  @override
  Widget build(BuildContext context) {
    final w = (room['width']  as num).toDouble();
    final l = (room['length'] as num).toDouble();
    final h = (room['height'] as num).toDouble();
    final furnitureList = (room['furniture'] as List?) ?? [];
    final area = (w * l).toStringAsFixed(1);

    return GestureDetector(
      onTap: onOpen,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _kLight),
          boxShadow: [
            BoxShadow(
                color: _kDark.withValues(alpha: .06),
                blurRadius: 10,
                offset: const Offset(0, 3)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: _kLight.withValues(alpha: .7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                  child: Text(_emoji,
                      style: const TextStyle(fontSize: 26))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room['name'] ?? 'Room',
                    style: const TextStyle(
                        color: _kDark,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${w.toStringAsFixed(1)}m × '
                    '${l.toStringAsFixed(1)}m × '
                    '${h.toStringAsFixed(1)}m',
                    style:
                        const TextStyle(color: _kMedium, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Row(children: [
                    _Chip(label: '$area m²'),
                    const SizedBox(width: 6),
                    _Chip(label: '${furnitureList.length} items'),
                  ]),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: _kPrimary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.view_in_ar,
                        color: Colors.white, size: 20),
                    onPressed: onOpen,
                    tooltip: 'Open in 3D',
                    constraints:
                        const BoxConstraints(minWidth: 38, minHeight: 38),
                    padding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.delete_outline,
                        color: Colors.red[400], size: 20),
                    onPressed: () => _confirmDelete(context),
                    tooltip: 'Delete',
                    constraints:
                        const BoxConstraints(minWidth: 38, minHeight: 38),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ]),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFFDF6EE),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Delete Room?',
          style:
              TextStyle(color: _kDark, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete "${room['name']}"?',
          style: const TextStyle(color: _kMedium),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: _kMedium)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _kLight.withValues(alpha: .6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
            color: _kDark, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}