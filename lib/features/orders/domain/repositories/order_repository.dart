// lib/features/orders/domain/repositories/order_repository.dart

import '../entities/order_entity.dart';

abstract class OrderRepository {
  Future<List<OrderEntity>> getCustomerOrders(int customerId);
  Future<void> updateOrderStatus(int orderId, String status);
}