import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:furnimatch/features/ar/domain/entities/ar_model.dart';
import 'package:furnimatch/features/ar/domain/repositories/ar_repository.dart';
import 'package:furnimatch/features/ar/domain/usecases/get_ar_model_usecase.dart';

class MockArRepository extends Mock implements ArRepository {}

void main() {
  late MockArRepository mockRepository;
  late GetArModelUseCase getArModelUseCase;

  setUp(() {
    mockRepository = MockArRepository();
    getArModelUseCase = GetArModelUseCase(mockRepository);
  });

  group('AR Feature', () {
    test(
      'should return AR model for the selected product',
      () async {
        // Arrange
        const arModel = ArModel(
          productId: 101,
          glbUrl: 'https://example.com/chair.glb',
          usdzUrl: 'https://example.com/chair.usdz',
        );

        when(() => mockRepository.getArModel(any()))
            .thenAnswer((_) async => arModel);

        // Act
        final result = await getArModelUseCase(101);

        // Assert
        expect(result.productId, 101);
        expect(result.glbUrl, 'https://example.com/chair.glb');
        expect(result.usdzUrl, 'https://example.com/chair.usdz');
        expect(result.hasAndroidModel, true);
        expect(result.hasIosModel, true);

        verify(() => mockRepository.getArModel(101)).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );
  });
}