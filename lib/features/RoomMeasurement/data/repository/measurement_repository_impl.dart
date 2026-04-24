import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/room_dimensions.dart';
import '../../domain/repository/measurement_repository.dart';
import '../datasource/camera_measurement_service.dart';

class MeasurementRepositoryImpl implements MeasurementRepository {
  final CameraMeasurementService cameraService;
  static const _kLastMeasurement = 'last_room_measurement';

  const MeasurementRepositoryImpl({required this.cameraService});

  @override
  Future<RoomDimensions> measureRoom() => cameraService.measureRoom();

  @override
  Future<void> saveLastMeasurement(RoomDimensions dimensions) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLastMeasurement, jsonEncode(dimensions.toJson()));
  }

  @override
  Future<RoomDimensions?> getLastMeasurement() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kLastMeasurement);
    if (raw == null) return null;
    return RoomDimensions.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}