import 'dart:math';
import 'package:camera/camera.dart';
import '../../domain/models/room_dimensions.dart';

class CameraMeasurementService {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;

  Future<void> initialize() async {
    _cameras = await availableCameras();
    if (_cameras == null || _cameras!.isEmpty) {
      throw Exception('No cameras available on this device');
    }
    _cameraController = CameraController(
      _cameras!.first,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await _cameraController!.initialize();
  }

  CameraController? get controller => _cameraController;
  bool get isInitialized => _cameraController?.value.isInitialized ?? false;

  Future<RoomDimensions> measureRoom() async {
    if (!isInitialized) {
      throw Exception('Camera not initialized. Call initialize() first.');
    }
    await Future.delayed(const Duration(seconds: 2));
    final random = Random();
    final length = 3.0 + random.nextDouble() * 3.0;
    final width  = 2.5 + random.nextDouble() * 2.5;
    final height = 2.4 + random.nextDouble() * 0.6;
    return RoomDimensions(
      length: double.parse(length.toStringAsFixed(2)),
      width:  double.parse(width.toStringAsFixed(2)),
      height: double.parse(height.toStringAsFixed(2)),
      measuredAt: DateTime.now(),
    );
  }

  Future<void> dispose() async {
    await _cameraController?.dispose();
    _cameraController = null;
  }
}