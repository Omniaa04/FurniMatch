import '../models/room_dimensions.dart';
import '../repository/measurement_repository.dart';

class MeasureRoomUseCase {
  final MeasurementRepository repository;
  const MeasureRoomUseCase({required this.repository});

  Future<RoomDimensions> call() async {
    final dimensions = await repository.measureRoom();
    await repository.saveLastMeasurement(dimensions);
    return dimensions;
  }
}

class GetLastMeasurementUseCase {
  final MeasurementRepository repository;
  const GetLastMeasurementUseCase({required this.repository});

  Future<RoomDimensions?> call() => repository.getLastMeasurement();
}