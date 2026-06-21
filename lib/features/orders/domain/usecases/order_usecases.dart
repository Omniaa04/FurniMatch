// lib/features/orders/domain/usecases/order_usecases.dart

import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class GetCustomerOrdersUseCase {
  final OrderRepository repository;
  const GetCustomerOrdersUseCase(this.repository);

  Future<List<OrderEntity>> call(int customerId) =>
      repository.getCustomerOrders(customerId);
}

class UpdateOrderStatusUseCase {
  final OrderRepository repository;
  const UpdateOrderStatusUseCase(this.repository);

  Future<void> call(int orderId, String status) =>
      repository.updateOrderStatus(orderId, status);
}