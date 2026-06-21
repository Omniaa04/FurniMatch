import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:furnimatch/api_config.dart';
import 'my_rooms_screen.dart';
import 'room_setup_screen.dart';

class RoomsEntryTab extends StatefulWidget {
  final int userId;
  final VoidCallback onBackToHome;

  const RoomsEntryTab({
    super.key,
    required this.userId,
    required this.onBackToHome,
  });

  @override
  State<RoomsEntryTab> createState() => _RoomsEntryTabState();
}

class _RoomsEntryTabState extends State<RoomsEntryTab> {
  bool _isLoading = true;
  bool _hasRooms = false;

  @override
  void initState() {
    super.initState();
    _checkRooms();
  }

  Future<void> _checkRooms() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id') ?? widget.userId;
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/rooms/list?user_id=$userId'),
        headers: {'ngrok-skip-browser-warning': 'true'},
      );
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        _hasRooms = data.isNotEmpty;
      }
    } catch (_) {
      _hasRooms = false;
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF6F0E9),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFCF8D5B)),
        ),
      );
    }

    if (_hasRooms) {
      return MyRoomsScreen(fromNav: true, onBackToHome: widget.onBackToHome);
    } else {
      return RoomSetupScreen(onBackToHome: widget.onBackToHome);
    }
  }
}