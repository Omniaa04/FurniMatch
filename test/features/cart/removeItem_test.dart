import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:furnimatch/features/cart/domain/repositories/cart_repository.dart';
import 'package:furnimatch/features/cart/domain/usecases/cart_usecases.dart';

class MockCartRepository extends Mock implements CartRepository {}

void main() {
  late MockCartRepository mockRepository;
  late RemoveItemUseCase removeItemUseCase;

  setUp(() {
    mockRepository = MockCartRepository();
    removeItemUseCase = RemoveItemUseCase(mockRepository);

    when(() => mockRepository.removeItem(any()))
        .thenAnswer((_) async {});
  });

  group('Cart Feature', () {
    test('should remove item from cart', () async {
      // Act
      await removeItemUseCase('1');

      // Assert
      verify(() => mockRepository.removeItem('1')).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}