import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:furnimatch/features/cart/domain/repositories/cart_repository.dart';
import 'package:furnimatch/features/cart/domain/usecases/cart_usecases.dart';

class MockCartRepository extends Mock implements CartRepository {}

void main() {
  late MockCartRepository mockRepository;
  late ApplyPromoCodeUseCase applyPromoCodeUseCase;

  setUp(() {
    mockRepository = MockCartRepository();
    applyPromoCodeUseCase = ApplyPromoCodeUseCase(mockRepository);
  });

  group('Cart Feature', () {
    test('should apply a valid promo code', () async {
      // Arrange
      when(() => mockRepository.applyPromoCode(any()))
          .thenAnswer((_) async => true);

      // Act
      final result = await applyPromoCodeUseCase('SAVE10');

      // Assert
      expect(result, true);

      verify(() => mockRepository.applyPromoCode('SAVE10')).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}