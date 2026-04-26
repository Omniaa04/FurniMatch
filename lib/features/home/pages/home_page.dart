import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:furnimatch/features/seller/presentation/pages/seller_registration.dart';
import 'package:furnimatch/features/auth/pages/login_page.dart';
import 'package:furnimatch/features/auth/pages/signup_page.dart';
import 'package:furnimatch/features/chat/pages/user_chat_list_page.dart';
import 'package:furnimatch/features/ai/pages/ai_chat_page.dart';
import 'package:furnimatch/api_config.dart';
import 'package:furnimatch/features/product/pages/product_details_page.dart';
import 'package:furnimatch/features/profile/pages/profile_page.dart';
import 'package:furnimatch/features/profile/pages/about_us_page.dart';
import 'package:furnimatch/features/Favorite/screen/favorites_screen.dart';
import 'package:furnimatch/features/home/pages/category_products_page.dart';

void main() => runApp(
      const MaterialApp(
        home: HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );

class HomeScreen extends StatefulWidget {
  final int? userId;
  final String? userName;

  const HomeScreen({
    super.key,
    this.userId,
    this.userName,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Color darkBrown = const Color(0xFF7D533D);
  final Color bgColor = const Color(0xFFF6F0E9);
  final Color orangeText = const Color(0xFFEBA46E);
  final Color btnColor = const Color(0xFFAD8B73);

  int unreadCount = 0;
  int? userId;
  String? userName;
  bool isLoggedIn = false;

  List<Map<String, dynamic>> popularProducts = [];
  bool isLoadingProducts = true;

  Set<int> favoriteProductIds = {};
  bool isLoadingFavorites = false;

  Color hexToColor(String hex) {
    final cleanedHex = hex.replaceAll('#', '');
    return Color(int.parse('FF$cleanedHex', radix: 16));
  }

  @override
  void initState() {
    super.initState();

    userId = widget.userId;
    userName = widget.userName;
    isLoggedIn = widget.userId != null;

    fetchProducts();
    fetchUnreadCount();
    fetchFavorites();
  }

  Future<void> fetchUnreadCount() async {
    if (userId == null) return;

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/user/$userId/unread-count'),
        headers: {"ngrok-skip-browser-warning": "true"},
      );

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        setState(() {
          unreadCount = data['unread_count'] ?? 0;
        });
      }
    } catch (_) {}
  }

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/products/all'),
        headers: {"ngrok-skip-browser-warning": "true"},
      );
      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        setState(() {
          popularProducts = List<Map<String, dynamic>>.from(data['products']);
          isLoadingProducts = false;
        });
      } else {
        setState(() => isLoadingProducts = false);
      }
    } catch (_) {
      setState(() => isLoadingProducts = false);
    }
  }

  Future<void> fetchFavorites() async {
    if (userId == null) {
      setState(() {
        favoriteProductIds.clear();
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/favorites/$userId'),
        headers: {"ngrok-skip-browser-warning": "true"},
      );

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        final favs = List<Map<String, dynamic>>.from(data['favorites'] ?? []);
        setState(() {
          favoriteProductIds = favs.map((e) => e['id'] as int).toSet();
        });
      }
    } catch (_) {}
  }

  Future<void> toggleFavoriteFromHome(Map<String, dynamic> product) async {
    if (userId == null) {
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
          'user_id': userId,
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
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Something went wrong")),
      );
    }
  }

  Future<void> logoutUser() async {
    setState(() {
      userId = null;
      userName = null;
      isLoggedIn = false;
      unreadCount = 0;
      favoriteProductIds.clear();
    });

    Navigator.of(context).pop();
  }

  Future<void> showLogoutDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF6F0E9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: const [
              Icon(Icons.logout, color: Colors.redAccent),
              SizedBox(width: 8),
              Text(
                "Log out",
                style: TextStyle(color: Color(0xFF7D533D)),
              ),
            ],
          ),
          content: const Text(
            "Are you sure you want to log out?\nWe’ll miss you 💔",
            style: TextStyle(
              color: Color(0xFF7D533D),
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                "No",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Yes",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await logoutUser();
    }
  }

  void _handleMenuPressed(BuildContext context) {
    if (!isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please log in first!")),
      );
      return;
    }

    Scaffold.of(context).openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      drawer: isLoggedIn
          ? Drawer(
              width: 290,
              child: Container(
                color: bgColor,
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 55, 20, 24),
                      decoration: BoxDecoration(
                        color: darkBrown,
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(28),
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            child: const Icon(
                              Icons.person,
                              size: 34,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userName ?? "User",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Welcome back to FurniMatch",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.85),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _drawerItem(
                      icon: Icons.groups_outlined,
                      title: "About Us",
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AboutUsPage(),
                          ),
                        );
                      },
                    ),
                    _drawerItem(
                      icon: Icons.settings_outlined,
                      title: "Settings",
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Settings page coming soon"),
                          ),
                        );
                      },
                    ),
                    _drawerItem(
                      icon: Icons.help_outline,
                      title: "Help",
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Help page coming soon")),
                        );
                      },
                    ),
                    const Spacer(),
                    const Divider(height: 1),
                    _drawerItem(
                      icon: Icons.logout,
                      title: "Log Out",
                      iconColor: Colors.redAccent,
                      textColor: Colors.redAccent,
                      onTap: showLogoutDialog,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            )
          : null,
      drawerEnableOpenDragGesture: isLoggedIn,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: InkWell(
          onTap: () {
            if (!isLoggedIn) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Please log in first!")),
              );
              return;
            }

            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatScreen()),
            );
          },
          child: SizedBox(
            height: 75,
            width: 75,
            child: Image.asset(
              'assets/images/ai_bot.png',
              errorBuilder: (c, e, s) => const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.smart_toy, size: 40, color: Colors.blue),
              ),
            ),
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        toolbarHeight: 65,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: darkBrown, size: 28),
            onPressed: () => _handleMenuPressed(context),
          ),
        ),
        title: Row(
          children: const [
            Icon(Icons.chair_alt, color: Color(0xFF7D533D), size: 24),
            SizedBox(width: 8),
            Text(
              "FurniMatch",
              style: TextStyle(
                color: Color(0xFF7D533D),
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        actions: [
          isLoggedIn
              ? Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Center(
                    child: Text(
                      "Hi, $userName 👋",
                      style: TextStyle(
                        color: darkBrown,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              : Row(
                  children: [
                    _buildTopBtnNav(
                      "Sign Up",
                      darkBrown,
                      Colors.white,
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SignUpPage()),
                        );
                        if (result != null) {
                          setState(() {
                            userId = result['user_id'];
                            userName = result['name'];
                            isLoggedIn = true;
                          });
                          fetchUnreadCount();
                          fetchFavorites();
                        }
                      },
                    ),
                    const SizedBox(width: 6),
                    _buildTopBtnNav(
                      "Log In",
                      Colors.transparent,
                      darkBrown,
                      isOutlined: true,
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                        if (result != null) {
                          setState(() {
                            userId = result['user_id'];
                            userName = result['name'];
                            isLoggedIn = true;
                          });
                          fetchUnreadCount();
                          fetchFavorites();
                        }
                      },
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              child: _buildSearchBar(
                onFavPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FavoritesScreen(
                        userId: userId,
                        userName: userName,
                      ),
                    ),
                  ).then((updatedName) {
                    fetchFavorites();
                    if (updatedName != null && updatedName is String) {
                      setState(() {
                        userName = updatedName;
                      });
                    }
                  });
                },
              ),
            ),
            _buildSimpleSectionHeader("Categories"),
            const SizedBox(height: 12),
            SizedBox(
              height: 85,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 15, right: 15),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildCategoryBox(
                    "Living room",
                    "assets/images/Living_room.jpg",
                    const Color(0xFFE5E5E7),
                  ),
                  _buildCategoryBox(
                    "Bedroom",
                    "assets/images/bedroom.jpg",
                    const Color(0xFFE8E4D9),
                  ),
                  _buildCategoryBox(
                    "Home office",
                    "assets/images/office.jpg",
                    const Color(0xFFDEDEE0),
                  ),
                  _buildCategoryBox(
                    "Kitchen",
                    "assets/images/kitchen.jpg",
                    const Color(0xFFE5E5E7),
                  ),
                  _buildCategoryBox(
                    "Dining room",
                    "assets/images/dining.jpg",
                    const Color(0xFFE8E4D9),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            CarouselSlider(
              options: CarouselOptions(
                height: 175,
                viewportFraction: 0.9,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 5),
                autoPlayAnimationDuration: const Duration(milliseconds: 1500),
                enlargeCenterPage: true,
              ),
              items: [
                _buildSliderItem(
                  "Sell your products\nwith us!",
                  "Become a seller",
                  "assets/images/ad1.jpg",
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SellerRegistrationPage(),
                      ),
                    );
                  },
                ),
                _buildSliderItem(
                  "Customize Your\norder now!",
                  "Chat with Seller →",
                  "assets/images/ad2.jpg",
                  () {
                    if (!isLoggedIn) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please log in first!")),
                      );
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UserChatListPage(
                          currentUserId: userId!,
                          userName: userName,
                        ),
                      ),
                    ).then((_) {
                      fetchUnreadCount();
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 25),
            const SizedBox(height: 25),
            _buildSectionHeader("Furniture in Uniqe Style", () {}),
            isLoadingProducts
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(color: Colors.brown),
                    ),
                  )
                : popularProducts.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            "No products yet",
                            style: TextStyle(color: Colors.brown),
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 12,
                        ),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 18,
                            childAspectRatio: 0.62,
                          ),
                          itemCount: popularProducts.length,
                          itemBuilder: (context, index) {
                            final p = popularProducts[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ProductDetailsPage(
                                      product: p,
                                      userId: userId,
                                      userName: userName,
                                    ),
                                  ),
                                ).then((_) {
                                  fetchFavorites();
                                });
                              },
                              child: _buildProductCardDynamic(p),
                            );
                          },
                        ),
                      ),
            const SizedBox(height: 90),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildProductCardDynamic(Map<String, dynamic> p) {
    final int stock = (p['stock'] ?? 0) is int
        ? (p['stock'] ?? 0)
        : int.tryParse('${p['stock']}') ?? 0;

    final String name = p['name'] ?? '';
    final String description = p['description'] ?? 'No description available';
    final String price = '${p['price'] ?? ''}';
    final bool isFavorite = favoriteProductIds.contains(p['id']);

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
                if (p['sale_price'] != null)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Text(
                        "SALE",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 10,
                  left: 12,
                  child: Row(
                    children: (p['colors'] is List &&
                            (p['colors'] as List).isNotEmpty)
                        ? (p['colors'] as List).take(5).map((colorHex) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: _buildColorDot(
                                hexToColor(colorHex.toString()),
                              ),
                            );
                          }).toList()
                        : [],
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
                        child: p['sale_price'] != null
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '\$$price',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                  Text(
                                    '\$${p['sale_price']}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                '\$$price',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                      ),
                      GestureDetector(
                        onTap: () => toggleFavoriteFromHome(p),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFF1F1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
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

  Widget _buildColorDot(Color color) {
    return Container(
      width: 13,
      height: 13,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBox(String title, String imgPath, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryProductsPage(
              categoryName: title,
              userId: userId,
              userName: userName,
            ),
          ),
        );
      },
      child: Container(
        width: 185,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 15,
              top: 0,
              bottom: 0,
              child: Container(
                width: 95,
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: TextStyle(
                    color: darkBrown,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              top: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
                child: Image.asset(
                  imgPath,
                  width: 75,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) =>
                      Container(width: 75, color: Colors.black12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderItem(
    String title,
    String btnText,
    String imgPath,
    VoidCallback onBtnPressed,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: AssetImage(imgPath),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.05), BlendMode.darken),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              color: darkBrown,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onBtnPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: btnColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              btnText,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar({required VoidCallback onFavPressed}) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFEFE9E2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: "Chair, desk, lamp, etc",
                prefixIcon: Icon(Icons.search, size: 22, color: Colors.black54),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        InkWell(
          onTap: onFavPressed,
          child: Container(
            height: 50,
            width: 50,
            decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle),
            child: Icon(Icons.favorite_border, color: darkBrown, size: 22),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onSeeAll) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: darkBrown,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBtnNav(
    String t,
    Color bg,
    Color tc, {
    bool isOutlined = false,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        side: isOutlined ? BorderSide(color: darkBrown) : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: Text(
        t,
        style: TextStyle(
          color: tc,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: orangeText,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 1) {
            if (!isLoggedIn) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Please log in first!")),
              );
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => UserChatListPage(
                  currentUserId: userId!,
                  userName: userName,
                ),
              ),
            ).then((_) {
              fetchUnreadCount();
            });
            return;
          }

          if (index == 5) {
            if (!isLoggedIn) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Please log in first!")),
              );
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MyProfilePage(
                  userId: userId!,
                  currentName: userName ?? '',
                ),
              ),
            ).then((updatedName) {
              if (updatedName != null && updatedName is String) {
                setState(() {
                  userName = updatedName;
                });
              }
            });
            return;
          }
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.chat_outlined),
                if (unreadCount > 0)
                  Positioned(
                    right: -6,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        unreadCount > 9 ? '9+' : '$unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: "Inbox",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none),
            label: "Notifications",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.view_in_ar),
            label: "3D model",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            label: "Cart",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = const Color(0xFF7D533D),
    Color textColor = const Color(0xFF7D533D),
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: textColor),
      onTap: onTap,
    );
  }

  Widget _buildSimpleSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Text(
        title,
        style: TextStyle(
          color: darkBrown,
          fontSize: 21,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
