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
  });
}