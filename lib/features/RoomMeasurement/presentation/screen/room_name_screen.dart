import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:furnimatch/api_config.dart';
import '../../domain/models/room_dimensions.dart';
import 'my_rooms_screen.dart';

class _C {
  static const primary    = Color(0xFFCF8D5B);
  static const dark       = Color(0xFF7D533D);
  static const medium     = Color(0xFFA36846);
  static const lighter    = Color(0xFFF0B589);
  static const lightest   = Color(0xFFF5D1A9);
  static const background = Color(0xFFFDF6EE);
}

class _RoomOption {
  final String emoji;
  final String name;
  const _RoomOption(this.emoji, this.name);
}

const _kRoomOptions = [
  _RoomOption('🛋', 'Living Room'),
  _RoomOption('🍳', 'Kitchen'),
  _RoomOption('🛏', 'Bedroom'),
  _RoomOption('🛁', 'Bathroom'),
  _RoomOption('🍽', 'Dining Room'),
  _RoomOption('🧺', 'Laundry Room'),
  _RoomOption('🖥', 'Home Office'),
  _RoomOption('🧸', 'Kids Room'),
];

class RoomNameScreen extends StatefulWidget {
  final RoomDimensions dimensions;
  final List<Map<String, dynamic>> furniture; // ← جديد

  const RoomNameScreen({
    super.key,
    required this.dimensions,
    this.furniture = const [], // ← جديد
  });

  @override
  State<RoomNameScreen> createState() => _RoomNameScreenState();
}

class _RoomNameScreenState extends State<RoomNameScreen> {
  String? _selectedName;
  bool _showCustomField = false;
  bool _isSaving = false;
  final _customCtrl = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _customCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String? get _finalName {
    if (_showCustomField) return _customCtrl.text.trim();
    return _selectedName;
  }

Future<void> _continue() async {
  final name = _finalName;
  if (name == null || name.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Please choose or enter a room name'),
      backgroundColor: _C.dark,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
    return;
  }

  setState(() => _isSaving = true);

  try {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    if (userId != null) {
      await http.post(
        Uri.parse('${ApiConfig.baseUrl}/rooms/save'),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({
          'user_id': userId,
          'name': name,
          'width': widget.dimensions.width,
          'length': widget.dimensions.length,
          'height': widget.dimensions.height,
          'furniture': widget.furniture,
        }),
      );
    }
  } catch (_) {}

if (!mounted) return;
setState(() => _isSaving = false);

// ✅ امسحي كل حاجة وروحي لـ MyRoomsScreen جديدة مع reload
Navigator.of(context).pushAndRemoveUntil(
  MaterialPageRoute(
    builder: (_) => const MyRoomsScreen(fromNav: false),
  ),
  (route) => false, // ← امسحي كل الـ stack حتى MainShell
);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top bar ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 16, 0),
              child: Row(children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new,
                      color: _C.dark, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: _C.lightest.withValues(alpha: .6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _C.lighter),
                  ),
                  child: Text(
                    '${widget.dimensions.width.toStringAsFixed(1)}m × '
                    '${widget.dimensions.length.toStringAsFixed(1)}m',
                    style: const TextStyle(
                        color: _C.dark,
                        fontWeight: FontWeight.w600,
                        fontSize: 13),
                  ),
                ),
              ]),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _showCustomField
                    ? 'Customize your\nroom name!'
                    : 'Choose the\nroom name',
                style: const TextStyle(
                  color: _C.dark,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: _showCustomField
                  ? _buildCustomField()
                  : _buildOptionList(),
            ),

            // ── Continue button ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: (_finalName?.isNotEmpty ?? false) && !_isSaving
                      ? _continue
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _C.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _C.primary.withValues(alpha: .3),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Continue',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                            SizedBox(width: 8),
                            Icon(Icons.play_arrow_rounded, size: 20),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionList() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        ..._kRoomOptions.map((opt) => _OptionTile(
              emoji: opt.emoji,
              name: opt.name,
              isSelected: _selectedName == opt.name,
              onTap: () => setState(() {
                _selectedName = opt.name;
                _showCustomField = false;
              }),
            )),
        _OptionTile(
          emoji: '🏷',
          name: 'Customize a name by yourself!',
          isSelected: false,
          isSpecial: true,
          onTap: () => setState(() {
            _showCustomField = true;
            _selectedName = null;
            Future.delayed(const Duration(milliseconds: 100),
                () => _focusNode.requestFocus());
          }),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCustomField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _customCtrl,
            focusNode: _focusNode,
            textCapitalization: TextCapitalization.words,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(color: _C.dark, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Write the name',
              hintStyle: TextStyle(
                  color: _C.medium.withValues(alpha: .5), fontSize: 15),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18, vertical: 16),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: _C.lightest, width: 1.5)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: _C.primary, width: 2)),
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => setState(() {
              _showCustomField = false;
              _customCtrl.clear();
            }),
            icon: const Icon(Icons.arrow_back, color: _C.medium, size: 16),
            label: const Text('Back to list',
                style: TextStyle(color: _C.medium, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String emoji;
  final String name;
  final bool isSelected;
  final bool isSpecial;
  final VoidCallback onTap;

  const _OptionTile({
    required this.emoji,
    required this.name,
    required this.isSelected,
    required this.onTap,
    this.isSpecial = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? _C.primary.withValues(alpha: .12)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? _C.primary
                : isSpecial
                    ? _C.lighter.withValues(alpha: .6)
                    : _C.lightest,
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Row(children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 14),
          Expanded(
            child: Text(name,
                style: TextStyle(
                    color: isSelected ? _C.primary : _C.dark,
                    fontSize: 15,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.w500)),
          ),
          if (isSelected)
            const Icon(Icons.check_circle_rounded,
                color: _C.primary, size: 20),
        ]),
      ),
    );
  }
}
