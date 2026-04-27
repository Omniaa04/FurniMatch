import 'dart:math';
import 'package:camera/camera.dart';
import '../../domain/models/room_dimensions.dart';

/// Service that uses the camera to estimate room dimensions.
/// Uses AR plane detection when available (ar_flutter_plugin),
/// and falls back to sensor + heuristic estimation.
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

  /// Simulates AR-based room dimension measurement.
  /// In production, replace this with ar_flutter_plugin plane detection.
  Future<RoomDimensions> measureRoom() async {
    if (!isInitialized) {
      throw Exception('Camera not initialized. Call initialize() first.');
    }

    // Simulate processing delay (replace with real AR detection)
    await Future.delayed(const Duration(seconds: 2));

    // In real implementation, use ARCore/ARKit plane detection:
    //   - Detect floor plane → derive width & length
    //   - Detect ceiling/wall planes → derive height
    // For now we return a plausible randomised estimate as placeholder.
    final random = Random();
    final length = 3.0 + random.nextDouble() * 3.0;  // 3–6 m
    final width  = 2.5 + random.nextDouble() * 2.5;  // 2.5–5 m
    final height = 2.4 + random.nextDouble() * 0.6;  // 2.4–3.0 m

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