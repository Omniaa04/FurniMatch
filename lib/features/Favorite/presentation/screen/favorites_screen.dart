import 'package:flutter/material.dart';
import '../../domain/favorite_model.dart';
import '../widgets/favorite_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  // بيانات تجريبية — استبدلها ببيانات من الـ backend
  final List<FavoriteItem> _favorites = [
    const FavoriteItem(
      id: '1',
      category: 'Sofa',
      name: 'Brown Comfy Mini Sofa',
      price: 80.00,
      imageUrl: 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=400',
    ),
    const FavoriteItem(
      id: '2',
      category: 'Sofa',
      name: 'Blue Study Sofa',
      price: 65.00,
      imageUrl: 'https://images.unsplash.com/photo-1567538096621-38d2284b23ff?w=400',
    ),
    const FavoriteItem(
      id: '3',
      category: 'Dining Table',
      name: 'Final Tables Dining Sets Wooden',
      price: 150.00,
      imageUrl: 'https://images.unsplash.com/photo-1617806118233-18e1de247200?w=400',
    ),
    const FavoriteItem(
      id: '4',
      category: 'Sofa',
      name: 'Cibor Wooden Bed Frame',
      price: 290.00,
      imageUrl: 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=400',
    ),
  ];

  void _onAddToCart(FavoriteItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} added to cart'),
        backgroundColor: const Color(0xFFC4845A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onRemove(FavoriteItem item) {
    setState(() => _favorites.removeWhere((f) => f.id == item.id));

    // Snackbar مع زرار Undo
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} removed from favorites'),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Undo',
          textColor: const Color(0xFFFFB48A),
          onPressed: () {
            setState(() => _favorites.add(item));
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Favorites',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: _favorites.isEmpty
          ? _buildEmpty()
          : Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                itemCount: _favorites.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.62,
                ),
                itemBuilder: (context, index) {
                  final item = _favorites[index];
                  return FavoriteCard(
                    item: item,
                    onAddToCart: () => _onAddToCart(item),
                    onRemove: () => _onRemove(item),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No favorites yet',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Items you heart will appear here',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}