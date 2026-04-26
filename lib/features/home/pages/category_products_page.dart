import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:furnimatch/api_config.dart';
import 'package:furnimatch/features/product/pages/product_details_page.dart';
// import 'package:furnimatch/features/favorite/pages/favorites_screen.dart';
import 'package:furnimatch/features/chat/pages/user_chat_list_page.dart';
import 'package:furnimatch/features/profile/pages/profile_page.dart';
import 'package:furnimatch/features/home/pages/home_page.dart';

class CategoryProductsPage extends StatefulWidget {
  final String categoryName;
  final int? userId;
  final String? userName;


  const CategoryProductsPage({
    super.key,
    required this.categoryName,
    this.userId,
    this.userName,
  });

  @override
  State<CategoryProductsPage> createState() => _CategoryProductsPageState();
}

class _CategoryProductsPageState extends State<CategoryProductsPage> {
  Set<int> favoriteProductIds = {};
  final Color darkBrown = const Color(0xFF7D533D);
  final Color bgColor = const Color(0xFFF6F0E9);
  final Color orangeText = const Color(0xFFEBA46E);

  List<Map<String, dynamic>> products = [];
  bool isLoading = true;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchCategoryProducts();
    fetchFavorites();
  }

  Future<void> fetchCategoryProducts() async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/products/category/${Uri.encodeComponent(widget.categoryName)}',
        ),
        headers: {"ngrok-skip-browser-warning": "true"},
      );

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        setState(() {
          products = List<Map<String, dynamic>>.from(data['products'] ?? []);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _onBottomNavTap(int index) async {
    setState(() {
      currentIndex = index;
    });

    if (index == 0) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            userId: widget.userId,
            userName: widget.userName,
          ),
        ),
        (route) => false,
      );
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
          builder: (_) => UserChatListPage(
            currentUserId: widget.userId!,
            userName: widget.userName,
          ),
        ),
      );
      return;
    }

    if (index == 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Notifications page is not connected yet")),
      );
      return;
    }

    if (index == 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("3D model page is not connected yet")),
      );
      return;
    }

    if (index == 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cart page is not connected yet")),
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

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MyProfilePage(
            userId: widget.userId!,
            currentName: widget.userName ?? '',
          ),
        ),
      );
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: darkBrown, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.categoryName,
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
              child: CircularProgressIndicator(color: Colors.brown),
            )
          : products.isEmpty
              ? Center(
                  child: Text(
                    'No products found',
                    style: TextStyle(color: darkBrown, fontSize: 16),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 12,
                  ),
                  child: GridView.builder(
                    itemCount: products.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 18,
                      childAspectRatio: 0.62,
                    ),
                    itemBuilder: (context, index) {
                      final p = products[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetailsPage(
                                product: p,
                                userId: widget.userId,
                                userName: widget.userName,
                              ),
                            ),
                          );
                        },
                        child: _buildProductCard(p),
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
          onTap: _onBottomNavTap,
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

  Widget _buildProductCard(Map<String, dynamic> p) {
    final int stock = (p['stock'] ?? 0) is int
        ? (p['stock'] ?? 0)
        : int.tryParse('${p['stock']}') ?? 0;

    final String name = p['name'] ?? '';
    final String description = p['description'] ?? 'No description available';
    final String price = '${p['price'] ?? ''}';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(22),
                    topRight: Radius.circular(22),
                  ),
                  child: Container(
                    width: double.infinity,
                    color: const Color(0xFFF4EFE5),
                    child: p['image_url'] != null &&
                            p['image_url'].toString().isNotEmpty
                        ? Image.network(
                            p['image_url'],
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            headers: const {
                              "ngrok-skip-browser-warning": "true"
                            },
                            errorBuilder: (c, e, s) => const Center(
                              child: Icon(
                                Icons.image,
                                color: Colors.brown,
                                size: 40,
                              ),
                            ),
                          )
                        : const Center(
                            child: Icon(
                              Icons.image,
                              color: Colors.brown,
                              size: 40,
                            ),
                          ),
                  ),
                ),
                if (stock <= 0)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Text(
                        "Out of Stock",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  )
                else if (stock <= 5)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Text(
                        "Low Stock",
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.3,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '\$$price',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      GestureDetector(
  onTap: () => toggleFavorite(p),
  child: Container(
    width: 38,
    height: 38,
    decoration: const BoxDecoration(
      color: Color(0xFFFFF1F1),
      shape: BoxShape.circle,
    ),
    child: Icon(
      favoriteProductIds.contains(p['id']) 
          ? Icons.favorite 
          : Icons.favorite_border,
      color: Colors.redAccent,
      size: 20,
    ),
  ),
),
                      const SizedBox(width: 8),
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: stock <= 0
                              ? Colors.grey.shade200
                              : const Color(0xFFF4F0E6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.shopping_cart_checkout_rounded,
                          color: stock <= 0 ? Colors.grey : darkBrown,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
Set<int> favoriteProducts ={};
Future<void> fetchFavorites() async {
  if (widget.userId == null) {
    setState(() {
      favoriteProductIds.clear();
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
      final favs = List<Map<String, dynamic>>.from(data['favorites'] ?? []);
      setState(() {
        favoriteProductIds = favs.map((e) => e['id'] as int).toSet();
      });
    }
  } catch (e) {
    // ignore
  }
}

Future<void> toggleFavorite(Map<String, dynamic> product) async {
  if (widget.userId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please log in first!")),
    );
    return;
  }

  try {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/favorite/toggle'),
      headers: {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
      body: jsonEncode({
        'user_id': widget.userId,
        'product_id': product['id'],
      }),
    );

    final data = jsonDecode(response.body);

    if (data['success'] == true) {
      final bool nowFavorite = data['is_favorite'] ?? false;

      setState(() {
        if (nowFavorite) {
          favoriteProductIds.add(product['id']);
        } else {
          favoriteProductIds.remove(product['id']);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? 'Done')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? 'Something went wrong')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Something went wrong")),
    );
  }
}
}