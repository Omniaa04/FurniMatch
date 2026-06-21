import '../../domain/entities/cart_item.dart';

class CartItemModel extends CartItem {
  CartItemModel({
    required super.id,
    required super.name,
    required super.category,
    required super.price,
    required super.imageUrl,
    super.quantity,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
  return CartItemModel(
    id: '${json['id'] ?? json['cart_id']}', // ✅ الـ backend بيرجع 'id'
    name: json['name'] ?? '',
    category: json['category'] ?? '',
    price: double.tryParse('${json['price']}') ?? 0.0,
    imageUrl: json['imageUrl'] ?? json['image_url'] ?? '',
    quantity: json['quantity'] ?? 1,
  );
}

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'price': price,
        'imageUrl': imageUrl,
        'quantity': quantity,
      };
}
