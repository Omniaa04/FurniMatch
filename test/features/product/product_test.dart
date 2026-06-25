import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:furnimatch/features/product/domain/repositories/product_details_repository.dart';
import 'package:furnimatch/features/product/domain/usecases/toggle_favorite_usecase.dart';

class MockProductDetailsRepository extends Mock
    implements ProductDetailsRepository {}

void main() {
  late MockProductDetailsRepository mockRepository;
  late ToggleFavoriteUseCase toggleFavoriteUseCase;

  setUp(() {
    mockRepository = MockProductDetailsRepository();
    toggleFavoriteUseCase = ToggleFavoriteUseCase(mockRepository);
  });

  group('Product Feature', () {
    test(
      'should toggle favorite successfully',
      () async {
        // Arrange
        when(
          () => mockRepository.toggleFavorite(
            userId: any(named: 'userId'),
            productId: any(named: 'productId'),
          ),
        ).thenAnswer((_) async => true);

        // Act
        final result = await toggleFavoriteUseCase(
          userId: 5,
          productId: 100,
        );

        // Assert
        expect(result, true);

        verify(
          () => mockRepository.toggleFavorite(
            userId: 5,
            productId: 100,
          ),
        ).called(1);

        verifyNoMoreInteractions(mockRepository);
      },
    );
  });
}