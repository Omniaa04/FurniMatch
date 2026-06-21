// lib/features/orders/domain/entities/order_entity.dart

class OrderEntity {
  final int id;
  final int storeId;
  final int productId;
  final int customerId;
  final String customerName;
  final String productName;
  final String status;
  final String? imageUrl;
  final DateTime? createdAt;

  const OrderEntity({
    required this.id,
    required this.storeId,
    required this.productId,
    required this.customerId,
    required this.customerName,
    required this.productName,
    required this.status,
    this.imageUrl,
    this.createdAt,
  });
}