import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:furnimatch/api_config.dart';
import 'package:furnimatch/features/chat/pages/user_chat_list_page.dart';
import 'package:furnimatch/features/profile/pages/profile_page.dart';
import 'package:furnimatch/features/product/pages/product_details_page.dart';
import '../widgets/favorite_card.dart';

class FavoritesScreen extends StatefulWidget {
  final int? userId;
  final String? userName;

  const FavoritesScreen({
    super.key,
    this.userId,
    this.userName,
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final Color darkBrown = const Color(0xFF7D533D);
  final Color bgColor = const Color(0xFFF6F0E9);
  final Color orangeText = const Color(0xFFEBA46E);

  int currentIndex = 0;
  bool isLoading = true;
  List<Map<String, dynamic>> favorites = [];

  @override
  void initState() {
    super.initState();
    fetchFavorites();
  }

  Future<void> fetchFavorites() async {
    if (widget.userId == null) {
      setState(() {
        favorites = [];
        isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/favorites/${widget.userId}'),
        headers: {"ngrok-skip-browser-warning": "true"},
      );

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        setState(() {
          favorites = List<Map<String, dynamic>>.from(data['favorites'] ?? []);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load favorites")),
      );
    }
  }

  void _onAddToCart(Map<String, dynamic> item) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item['name']} added to cart'),
        backgroundColor: darkBrown,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _onRemove(Map<String, dynamic> item) async {
    if (widget.userId == null) return;

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/favorite/toggle'),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({
          'user_id': widget.userId,
          'product_id': item['id'],
        }),
      );

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        setState(() {
          favorites.removeWhere((f) => f['id'] == item['id']);
        });

        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Removed from favorites'),
            backgroundColor: Colors.black87,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Failed to remove favorite'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to remove favorite"),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _openProductDetails(Map<String, dynamic> item) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailsPage(
          product: item,
          userId: widget.userId,
          userName: widget.userName,
        ),
      ),
    );

    await fetchFavorites();

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Order placed successfully"),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _onNavTap(int index) async {
    setState(() {
      currentIndex = index;
    });

    if (index == 0) {
      Navigator.pop(context);
      return;
    }

    if (index == 1) {
      if (widget.userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please log in first!")),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => UserChatListPage(currentUserId: widget.userId!),
        ),
      );
      return;
    }

    if (index == 5) {
      if (widget.userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please log in first!")),
        );
        return;
      }

      final updatedName = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MyProfilePage(
            userId: widget.userId!,
            currentName: widget.userName ?? '',
          ),
        ),
      );

      if (updatedName != null && updatedName is String) {
        Navigator.pop(context, updatedName);
      }
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("This section is not connected yet")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: darkBrown, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Favorites',
          style: TextStyle(
            color: darkBrown,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF7D533D)),
            )
          : favorites.isEmpty
              ? _buildEmpty()
              : Padding(
                  padding: const EdgeInsets.fromLTRB(15, 8, 15, 15),
                  child: GridView.builder(
                    itemCount: favorites.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 18,
                      childAspectRatio: 0.62,
                    ),
                    itemBuilder: (context, index) {
                      final item = favorites[index];
                      return FavoriteCard(
                        item: item,
                        onAddToCart: () => _onAddToCart(item),
                        onRemove: () => _onRemove(item),
                        onTap: () => _openProductDetails(item),
                      );
                    },
                  ),
                ),
      bottomNavigationBar: Container(
        height: 75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: currentIndex,
          selectedItemColor: orangeText,
          unselectedItemColor: Colors.grey,
          onTap: _onNavTap,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_outlined),
              label: "Inbox",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_none),
              label: "Notifications",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.view_in_ar),
              label: "3D model",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              label: "Cart",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 68,
              color: darkBrown.withOpacity(0.35),
            ),
            const SizedBox(height: 18),
            Text(
              'No favorites yet',
              style: TextStyle(
                fontSize: 20,
                color: darkBrown,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'The products you love will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: darkBrown.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}