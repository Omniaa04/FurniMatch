// lib/features/orders/data/repositories/order_repository_impl.dart

import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_datasource.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;
  const OrderRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<OrderEntity>> getCustomerOrders(int customerId) =>
      remoteDataSource.getCustomerOrders(customerId);

  @override
  Future<void> updateOrderStatus(int orderId, String status) =>
      remoteDataSource.updateOrderStatus(orderId, status);
}