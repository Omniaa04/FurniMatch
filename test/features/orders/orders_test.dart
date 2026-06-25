import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:furnimatch/features/orders/domain/entities/order_entity.dart';
import 'package:furnimatch/features/orders/domain/repositories/order_repository.dart';
import 'package:furnimatch/features/orders/domain/usecases/order_usecases.dart';

class MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  late MockOrderRepository mockRepository;
  late GetCustomerOrdersUseCase getCustomerOrdersUseCase;

  setUp(() {
    mockRepository = MockOrderRepository();
    getCustomerOrdersUseCase = GetCustomerOrdersUseCase(mockRepository);
  });

  group('Orders Feature', () {
    test(
      'should return customer orders successfully',
      () async {
        // Arrange
        final orders = [
          OrderEntity(
            id: 1,
            storeId: 10,
            productId: 100,
            customerId: 5,
            customerName: 'Shahd',
            productName: 'Modern Chair',
            status: 'Pending',
            imageUrl: 'chair.png',
            createdAt: DateTime(2025, 1, 1),
          ),
        ];

        when(() => mockRepository.getCustomerOrders(any()))
            .thenAnswer((_) async => orders);

        // Act
        final result = await getCustomerOrdersUseCase(5);

        // Assert
        expect(result, isA<List<OrderEntity>>());
        expect(result.length, 1);
        expect(result.first.customerId, 5);
        expect(result.first.productName, 'Modern Chair');
        expect(result.first.status, 'Pending');

        verify(() => mockRepository.getCustomerOrders(5)).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );
  });
}