import '../models/room_dimensions.dart';

abstract class MeasurementRepository {
  Future<RoomDimensions> measureRoom();
  Future<void> saveLastMeasurement(RoomDimensions dimensions);
  Future<RoomDimensions?> getLastMeasurement();
}