import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:furnimatch/features/room_measure_rana/domain/entities/room_entity.dart';
import 'package:furnimatch/features/room_measure_rana/domain/repositories/room_repository.dart';
import 'package:furnimatch/features/room_measure_rana/domain/usecases/room_usecases.dart';

class MockRoomRepository extends Mock implements RoomRepository {}

void main() {
  late MockRoomRepository mockRepository;
  late SaveRoomUseCase saveRoomUseCase;

  setUpAll(() {
    registerFallbackValue(
      const RoomEntity(
        name: '',
        area: 0,
        sides: [],
        date: '',
      ),
    );
  });

  setUp(() {
    mockRepository = MockRoomRepository();
    saveRoomUseCase = SaveRoomUseCase(mockRepository);
  });

  group('Room Repository Feature', () {
    test(
      'should save a measured room successfully',
      () async {
        // Arrange
        const room = RoomEntity(
          name: 'Living Room',
          area: 25.5,
          sides: [5.0, 5.1, 5.0, 5.1],
          date: '2026-06-26',
        );

        when(() => mockRepository.saveRoom(room))
            .thenAnswer((_) async {});

        // Act
        await saveRoomUseCase(room);

        // Assert
        verify(() => mockRepository.saveRoom(room)).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );
  });


test('copyWith should update only specified fields', () {
  const room = RoomEntity(
    name: 'Bedroom',
    area: 16,
    sides: [4, 4, 4, 4],
    date: '2026-06-26',
  );

  final updated = room.copyWith(
    name: 'Master Bedroom',
    area: 20,
  );

  expect(updated.name, 'Master Bedroom');
  expect(updated.area, 20);
  expect(updated.sides, [4, 4, 4, 4]);
  expect(updated.date, '2026-06-26');
});

test(
  'should throw an exception when saving the room fails',
  () async {
    // Arrange
    const room = RoomEntity(
      name: 'Living Room',
      area: 25.5,
      sides: [5.0, 5.1, 5.0, 5.1],
      date: '2026-06-26',
    );

    when(() => mockRepository.saveRoom(room))
        .thenThrow(Exception('Failed to save room'));

    // Act & Assert
    expect(
      () => saveRoomUseCase(room),
      throwsException,
    );

    verify(() => mockRepository.saveRoom(room)).called(1);
    verifyNoMoreInteractions(mockRepository);
  },
);

test(
  'copyWith should keep all values when no fields are provided',
  () {
    const room = RoomEntity(
      name: 'Bedroom',
      area: 16,
      sides: [4, 4, 4, 4],
      date: '2026-06-26',
    );

    final copied = room.copyWith();

    expect(copied.name, room.name);
    expect(copied.area, room.area);
    expect(copied.sides, room.sides);
    expect(copied.date, room.date);
  },
);

test(
  'copyWith should update only the room name',
  () {
    const room = RoomEntity(
      name: 'Bedroom',
      area: 16,
      sides: [4, 4, 4, 4],
      date: '2026-06-26',
    );

    final updated = room.copyWith(
      name: 'Guest Room',
    );

    expect(updated.name, 'Guest Room');
    expect(updated.area, 16);
    expect(updated.sides, [4, 4, 4, 4]);
    expect(updated.date, '2026-06-26');
  },
);

test(
  'two RoomEntity objects with the same values should be equal',
  () {
    const room1 = RoomEntity(
      name: 'Living Room',
      area: 25,
      sides: [5, 5, 5, 5],
      date: '2026-06-26',
    );

    const room2 = RoomEntity(
      name: 'Living Room',
      area: 25,
      sides: [5, 5, 5, 5],
      date: '2026-06-26',
    );

    expect(room1, room2);
  },
);

}