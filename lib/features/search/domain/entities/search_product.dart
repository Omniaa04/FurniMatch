class SearchProduct {
  final int id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String imageUrl;
  final int stock;
  final List<String> colors;
  final double? salePrice;
  final String storeName;

  const SearchProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.stock,
    required this.colors,
    this.salePrice,
    required this.storeName,
  });
}