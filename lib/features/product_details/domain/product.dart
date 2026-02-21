// domain/product_details_model.dart

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final double rating;
  final List<String> colors;
  final String selectedColor; // اللون المختار حالياً

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.rating,
    required this.colors,
    required this.selectedColor,
  });
  
}