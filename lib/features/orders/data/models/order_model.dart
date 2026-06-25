// lib/features/orders/data/models/order_model.dart

import '../../domain/entities/order_entity.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.storeId,
    required super.productId,
    required super.customerId,
    required super.customerName,
    required super.productName,
    required super.status,
    super.imageUrl,
    super.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as int,
      storeId: json['store_id'] as int,
      productId: json['product_id'] as int,
      customerId: json['customer_id'] as int,
      customerName: json['customer_name'] as String? ?? '',
      productName: json['product_name'] as String? ?? '',
      status: json['status'] as String? ?? 'Preparing',
      imageUrl: json['image_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'store_id': storeId,
        'product_id': productId,
        'customer_id': customerId,
        'customer_name': customerName,
        'product_name': productName,
        'status': status,
        'image_url': imageUrl,
        'created_at': createdAt?.toIso8601String(),
      };
}