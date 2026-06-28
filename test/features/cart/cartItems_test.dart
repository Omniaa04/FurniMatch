import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:furnimatch/features/cart/domain/repositories/cart_repository.dart';
import 'package:furnimatch/features/cart/domain/usecases/cart_usecases.dart';

class MockCartRepository extends Mock implements CartRepository {}

void main() {
  late MockCartRepository mockRepository;
  late UpdateQuantityUseCase updateQuantityUseCase;

  setUp(() {
    mockRepository = MockCartRepository();
    updateQuantityUseCase = UpdateQuantityUseCase(mockRepository);

    when(() => mockRepository.updateQuantity(any(), any()))
        .thenAnswer((_) async {});
  });

  group('Cart Feature', () {
    test('should update cart item quantity', () async {
      // Act
      await updateQuantityUseCase('1', 3);

      // Assert
      verify(() => mockRepository.updateQuantity('1', 3)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}