import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:furnimatch/features/cart/domain/entities/cart_summary.dart';
import 'package:furnimatch/features/cart/domain/repositories/cart_repository.dart';
import 'package:furnimatch/features/cart/domain/usecases/cart_usecases.dart';

class MockCartRepository extends Mock implements CartRepository {}

void main() {
  late MockCartRepository mockRepository;
  late GetCartSummaryUseCase getCartSummaryUseCase;

  setUp(() {
    mockRepository = MockCartRepository();
    getCartSummaryUseCase = GetCartSummaryUseCase(mockRepository);
  });

  group('Cart Feature', () {
    test(
      'should return the correct cart summary',
      () async {
        // Arrange
        const summary = CartSummary(
          subTotal: 1000,
          deliveryFee: 50,
          discount: 100,
        );

        when(() => mockRepository.getCartSummary(any()))
            .thenAnswer((_) async => summary);

        // Act
        final result = await getCartSummaryUseCase(null);

        // Assert
        expect(result.subTotal, 1000);
        expect(result.deliveryFee, 50);
        expect(result.discount, 100);

        // totalCost = subtotal + delivery - discount
        expect(result.totalCost, 950);

        verify(() => mockRepository.getCartSummary(null)).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );
  });
}