import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:furnimatch/features/points/domain/models/points_model.dart';
import 'package:furnimatch/features/points/domain/repository/points_repository.dart';
import 'package:furnimatch/features/points/domain/usecases/points_usecases.dart';

class MockPointsRepository extends Mock implements PointsRepository {}

void main() {
  late MockPointsRepository mockRepository;
  late EarnPointsUseCase earnPointsUseCase;

  setUpAll(() {
    registerFallbackValue(
      const PointsModel(
        totalPoints: 0,
        transactions: [],
      ),
    );
  });

  setUp(() {
    mockRepository = MockPointsRepository();
    earnPointsUseCase = EarnPointsUseCase(mockRepository);
  });

  group('Points Feature', () {
    test('should earn points after a purchase', () async {
      // Arrange
      const pointsModel = PointsModel(
        totalPoints: 25,
        transactions: [],
      );

      when(() => mockRepository.earnPoints(250.0, 'ORDER123'))
          .thenAnswer((_) async => pointsModel);

      // Act
      final result = await earnPointsUseCase(250.0, 'ORDER123');

      // Assert
      expect(result.totalPoints, 25);

      verify(() => mockRepository.earnPoints(250.0, 'ORDER123'))
          .called(1);

      verifyNoMoreInteractions(mockRepository);
    });

    test(
  'should throw an exception when earning points fails',
  () async {
    // Arrange
    when(() => mockRepository.earnPoints(250.0, 'ORDER123'))
        .thenThrow(Exception('Failed to earn points'));

    // Act & Assert
    expect(
      () => earnPointsUseCase(250.0, 'ORDER123'),
      throwsException,
    );

    verify(() => mockRepository.earnPoints(250.0, 'ORDER123'))
        .called(1);

    verifyNoMoreInteractions(mockRepository);
  },
);

test(
  'should return zero points for a purchase worth zero',
  () async {
    // Arrange
    const pointsModel = PointsModel(
      totalPoints: 0,
      transactions: [],
    );

    when(() => mockRepository.earnPoints(0.0, 'ORDER000'))
        .thenAnswer((_) async => pointsModel);

    // Act
    final result = await earnPointsUseCase(0.0, 'ORDER000');

    // Assert
    expect(result.totalPoints, 0);

    verify(() => mockRepository.earnPoints(0.0, 'ORDER000'))
        .called(1);

    verifyNoMoreInteractions(mockRepository);
  },
);

test(
  'should return correct points for a large purchase',
  () async {
    // Arrange
    const pointsModel = PointsModel(
      totalPoints: 500,
      transactions: [],
    );

    when(() => mockRepository.earnPoints(5000.0, 'ORDER999'))
        .thenAnswer((_) async => pointsModel);

    // Act
    final result = await earnPointsUseCase(5000.0, 'ORDER999');

    // Assert
    expect(result.totalPoints, 500);

    verify(() => mockRepository.earnPoints(5000.0, 'ORDER999'))
        .called(1);

    verifyNoMoreInteractions(mockRepository);
  },
);



  });
}