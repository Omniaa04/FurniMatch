import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:furnimatch/features/RoomMeasurement/domain/models/room_dimensions.dart';
import 'package:furnimatch/features/RoomMeasurement/domain/repository/measurement_repository.dart';
import 'package:furnimatch/features/RoomMeasurement/domain/usecases/measure_room_usecase.dart';

class MockMeasurementRepository extends Mock
    implements MeasurementRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      RoomDimensions(
        length: 0,
        width: 0,
        height: 0,
        measuredAt: DateTime(2000, 1, 1),
      ),
    );
  });

  late MockMeasurementRepository mockRepository;
  late MeasureRoomUseCase measureRoomUseCase;

  setUp(() {
    mockRepository = MockMeasurementRepository();
    measureRoomUseCase =
        MeasureRoomUseCase(repository: mockRepository);
  });

  group('Room Measurement Feature', () {
    test(
      'should measure the room, save the measurement, and return the dimensions',
      () async {
        final dimensions = RoomDimensions(
          length: 5,
          width: 4,
          height: 3,
          measuredAt: DateTime(2025, 1, 1),
        );

        when(() => mockRepository.measureRoom())
            .thenAnswer((_) async => dimensions);

        when(() => mockRepository.saveLastMeasurement(dimensions))
            .thenAnswer((_) async {});

        final result = await measureRoomUseCase();

        expect(result.area, 20);
        expect(result.volume, 60);

        verify(() => mockRepository.measureRoom()).called(1);
        verify(() => mockRepository.saveLastMeasurement(dimensions))
            .called(1);

        verifyNoMoreInteractions(mockRepository);
      },
    );
  });
}