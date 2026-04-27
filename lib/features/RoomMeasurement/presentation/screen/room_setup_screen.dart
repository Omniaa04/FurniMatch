// lib/features/RoomMeasurement/presentation/screen/room_setup_screen.dart
import 'package:flutter/material.dart';
import 'room_3d_screen.dart';
import 'measurement_screen.dart';

class RoomSetupScreen extends StatefulWidget {
  const RoomSetupScreen({super.key});
  @override
  State<RoomSetupScreen> createState() => _RoomSetupScreenState();
}

class _RoomSetupScreenState extends State<RoomSetupScreen> {
  final _widthCtrl  = TextEditingController();
  final _lengthCtrl = TextEditingController();
  final _heightCtrl = TextEditingController(text: '2.7');

  static const _primary = Color(0xFFCF8D5B);
  static const _dark    = Color(0xFF7D533D);
  static const _light   = Color(0xFFF5D1A9);
  static const _medium  = Color(0xFFA36846);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6EE),
      appBar: AppBar(
        backgroundColor: _dark,
        title: const Text('Set Up Your Room',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _light,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(children: [
                Icon(Icons.view_in_ar, size: 48, color: _dark),
                SizedBox(height: 8),
                Text('Visualize Your Room in 3D',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _dark)),
                SizedBox(height: 4),
                Text('Enter dimensions or use camera',
                    style: TextStyle(color: _medium, fontSize: 14)),
              ]),
            ),

            const SizedBox(height: 32),
            const Text('Option 1 — Enter Dimensions',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _dark)),
            const SizedBox(height: 16),

            _field(_widthCtrl,  'Room Width',     'e.g. 4.5', Icons.swap_horiz),
            const SizedBox(height: 12),
            _field(_lengthCtrl, 'Room Length',    'e.g. 6.0', Icons.swap_vert),
            const SizedBox(height: 12),
            _field(_heightCtrl, 'Ceiling Height', 'e.g. 2.7', Icons.height),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _openRoom3D,
                icon: const Icon(Icons.view_in_ar, color: Colors.white),
                label: const Text('Open 3D Room',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),

            const SizedBox(height: 32),
            Row(children: [
              Expanded(child: Divider(color: _medium.withValues(alpha: 0.4))),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('OR',
                    style: TextStyle(
                        color: _medium, fontWeight: FontWeight.bold)),
              ),
              Expanded(child: Divider(color: _medium.withValues(alpha: 0.4))),
            ]),
            const SizedBox(height: 32),

            const Text('Option 2 — Measure with Camera',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _dark)),
            const SizedBox(height: 8),
            const Text(
              'Point your camera at the room — it automatically measures the dimensions and opens the 3D view.',
              style: TextStyle(color: _medium, fontSize: 13),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton.icon(
                onPressed: _openMeasurement,
                icon: const Icon(Icons.camera_alt, color: _primary),
                label: const Text('Open Camera & Measure',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _primary)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _primary, width: 2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, String hint,
      IconData icon) {
    return TextField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: '$label (meters)',
        hintText: hint,
        prefixIcon: Icon(icon, color: _primary),
        suffixText: 'm',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primary.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primary.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primary, width: 2),
        ),
        labelStyle: const TextStyle(color: _medium),
      ),
    );
  }

  void _openRoom3D() {
    final width  = double.tryParse(_widthCtrl.text);
    final length = double.tryParse(_lengthCtrl.text);
    final height = double.tryParse(_heightCtrl.text) ?? 2.7;
    if (width == null || length == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter valid room dimensions'),
        backgroundColor: _dark,
      ));
      return;
    }
    Navigator.push(context, MaterialPageRoute(
        builder: (_) => Room3DScreen(
            roomWidth: width,
            roomLength: length,
            roomHeight: height)));
  }

  void _openMeasurement() {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => const MeasurementScreen()));
  }

  @override
  void dispose() {
    _widthCtrl.dispose();
    _lengthCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }
}