import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:furnimatch/api_config.dart';
import 'package:furnimatch/features/home/pages/home_page.dart';
import 'package:furnimatch/features/chat/pages/user_chat_list_page.dart';
import 'package:furnimatch/features/profile/pages/profile_page.dart';

class ProductDetailsPage extends StatefulWidget {
  final Map<String, dynamic> product;
  final int? userId;
  final String? userName;

  const ProductDetailsPage({
    super.key,
    required this.product,
    this.userId,
    this.userName,
  });

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int selectedColorIndex = 0;
  bool isFavorite = false;
  bool isCheckingFavorite = true;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    checkFavoriteStatus();
  }

  Color hexToColor(String hex) {
    final cleanedHex = hex.replaceAll('#', '');
    return Color(int.parse('FF$cleanedHex', radix: 16));
  }

  Future<void> checkFavoriteStatus() async {
    if (widget.userId == null) {
      setState(() {
        isFavorite = false;
        isCheckingFavorite = false;
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/favorite/check'),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({
          'user_id': widget.userId,
          'product_id': widget.product['id'],
        }),
      );

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        setState(() {
          isFavorite = data['is_favorite'] ?? false;
          isCheckingFavorite = false;
        });
      } else {
        setState(() => isCheckingFavorite = false);
      }
    } catch (_) {
      setState(() => isCheckingFavorite = false);
    }
  }

  Future<void> toggleFavorite() async {
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
          'product_id': widget.product['id'],
        }),
      );

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        setState(() {
          isFavorite = data['is_favorite'] ?? false;
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

  Future<void> buyProduct(BuildContext context) async {
    if (widget.userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please log in first!")),
      );
      return;
    }

    if ((widget.product['stock'] ?? 0) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sorry, this product is out of stock!")),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/product/buy'),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({
          'product_id': widget.product['id'],
          'customer_id': widget.userId,
          'customer_name': widget.userName ?? 'Customer',
        }),
      );

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Order placed successfully! ✅")),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Something went wrong')),
        );
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Server error, try again later")),
      );
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
    final product = widget.product;
    final darkBrown = const Color(0xFF8B5E3C);
    final bgColor = const Color(0xFFF6F0E9);

    final List<dynamic> productColors =
        (product['colors'] is List) ? product['colors'] : [];

    if (productColors.isNotEmpty && selectedColorIndex >= productColors.length) {
      selectedColorIndex = 0;
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(26),
                            bottomRight: Radius.circular(26),
                          ),
                          child: product['image_url'] != null &&
                                  product['image_url'].toString().isNotEmpty
                              ? Image.network(
                                  product['image_url'],
                                  width: double.infinity,
                                  height: 370,
                                  fit: BoxFit.cover,
                                  headers: const {
                                    "ngrok-skip-browser-warning": "true"
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: double.infinity,
                                      height: 370,
                                      color: const Color(0xffe8cdb8),
                                      child: const Center(
                                        child: Icon(
                                          Icons.image,
                                          size: 80,
                                          color: Colors.brown,
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  width: double.infinity,
                                  height: 370,
                                  color: const Color(0xffe8cdb8),
                                  child: const Center(
                                    child: Icon(
                                      Icons.image,
                                      size: 80,
                                      color: Colors.brown,
                                    ),
                                  ),
                                ),
                        ),
                        Positioned(
                          top: 18,
                          left: 18,
                          child: _circleIconButton(
                            icon: Icons.arrow_back,
                            onTap: () => Navigator.pop(context),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product['category']?.toString().isNotEmpty == true
                                ? product['category']
                                : "Furniture",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  product['name'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Row(
                                children: const [
                                  Icon(Icons.star,
                                      color: Colors.amber, size: 22),
                                  SizedBox(width: 4),
                                  Text(
                                    "4.5",
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "\$ ${product['price']}",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              _squareIconButton(
                                icon: Icons.shopping_cart_outlined,
                                onTap: () => buyProduct(context),
                              ),
                              const SizedBox(width: 12),
                              _squareIconButton(
                                icon: isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                onTap: isCheckingFavorite ? () {} : toggleFavorite,
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: (product['stock'] ?? 0) > 0
                                    ? const Color(0xFFE8F5E9)
                                    : const Color(0xFFFFEBEE),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    (product['stock'] ?? 0) > 0
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    color: (product['stock'] ?? 0) > 0
                                        ? Colors.green
                                        : Colors.red,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    (product['stock'] ?? 0) > 0
                                        ? "In Stock (${product['stock']} left)"
                                        : "Out of Stock",
                                    style: TextStyle(
                                      color: (product['stock'] ?? 0) > 0
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Product Details",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            product['description']?.toString().isNotEmpty == true
                                ? product['description']
                                : "No description available",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 28),
                          Row(
                            children: [
                              const Text(
                                "Select Color : ",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                productColors.isNotEmpty
                                    ? productColors[selectedColorIndex]
                                        .toString()
                                        .toUpperCase()
                                    : "No color",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: darkBrown,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (productColors.isNotEmpty)
                            Row(
                              children:
                                  List.generate(productColors.length, (index) {
                                final isSelected = selectedColorIndex == index;
                                final color =
                                    hexToColor(productColors[index].toString());

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedColorIndex = index;
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 14),
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: color,
                                      border: Border.all(
                                        color: isSelected
                                            ? darkBrown
                                            : Colors.transparent,
                                        width: 3,
                                      ),
                                    ),
                                    child: isSelected
                                        ? const Center(
                                            child: CircleAvatar(
                                              radius: 7,
                                              backgroundColor: Colors.white,
                                            ),
                                          )
                                        : null,
                                  ),
                                );
                              }),
                            )
                          else
                            Text(
                              "No colors available",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          const SizedBox(height: 26),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black, width: 1.5),
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("AR feature coming soon"),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: darkBrown,
                                elevation: 0,
                                minimumSize: const Size(double.infinity, 58),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(35),
                                ),
                              ),
                              child: const Text(
                                "Try in My Room",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
          currentIndex: currentIndex,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFFEBA46E),
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

  Widget _circleIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black12),
        ),
        child: Icon(icon, color: Colors.black, size: 28),
      ),
    );
  }

  Widget _squareIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 62,
        height: 62,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF8B5E3C), width: 1.6),
        ),
        child: Icon(
          icon,
          color: const Color(0xFF8B5E3C),
          size: 30,
        ),
      ),
    );
  }
}