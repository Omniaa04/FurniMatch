import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import 'package:furnimatch/api_config.dart';

import 'package:furnimatch/features/home/presentation/widgets/home_widgets.dart';
import 'package:furnimatch/features/home/data/models/home_repository.dart';
import 'package:furnimatch/features/home/presentation/controller/home_controller.dart';
import 'package:furnimatch/providers/cart_provider.dart';

import 'package:furnimatch/features/profile/presentation/pages/profile_page.dart';
import 'package:furnimatch/features/seller/presentation/pages/seller_registration.dart';
import 'package:furnimatch/features/auth/presentation/pages/login_page.dart';
import 'package:furnimatch/features/auth/presentation/pages/signup_page.dart';
import 'package:furnimatch/features/ai/presentation/pages/chat_screen.dart.dart';
import 'package:furnimatch/features/buttom_nav/main_shell.dart';
import 'package:furnimatch/features/product/presentation/pages/product_details_page.dart';
import 'package:furnimatch/features/profile/presentation/pages/about_us_page.dart';
import 'package:furnimatch/features/Favorite/screen/favorites_screen.dart';
import 'package:furnimatch/features/search/presentation/pages/search_page.dart';

import 'package:furnimatch/features/settings/data/datasource/settings_remote_datasource.dart';
import 'package:furnimatch/features/settings/data/repository/settings_repository_impl.dart';
import 'package:furnimatch/features/settings/domain/usecases/get_settings_usecase.dart';
import 'package:furnimatch/features/settings/domain/usecases/save_settings_usecase.dart';
import 'package:furnimatch/features/settings/domain/usecases/clear_cache_usecase.dart';
import 'package:furnimatch/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:furnimatch/features/settings/presentation/screen/settings_screen.dart';
import 'package:furnimatch/features/settings/presentation/widgets/help_page.dart';

import 'package:furnimatch/features/points/data/datasource/points_remote_datasource.dart';
import 'package:furnimatch/features/points/data/repository/points_repository_impl.dart';
import 'package:furnimatch/features/points/domain/usecases/points_usecases.dart';
import 'package:furnimatch/features/points/presentation/bloc/points_bloc.dart';
import 'package:furnimatch/features/points/presentation/screen/points_screen.dart';

// ── Room Measure ──────────────────────────────────────────────────────────────
import 'package:furnimatch/features/room_measure_rana/presentation/screens/reference_screen.dart';

// ── Orders ────────────────────────────────────────────────────────────────────
import 'package:furnimatch/features/orders/presentation/pages/orders_page.dart';

class HomeScreen extends StatefulWidget {
  final int? userId;
  final String? userName;
  final void Function(int? userId, String? userName)? onAuthChanged;
  final ValueChanged<int>? onTabSelected;

  const HomeScreen({
    super.key,
    this.userId,
    this.userName,
    this.onAuthChanged,
    this.onTabSelected,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color darkBrown = Color(0xFF7D533D);
  static const Color bgColor = Color(0xFFF6F0E9);

  late final HomeController controller;
  String? profileImageUrl;

  // ── Room Measure Popup ────────────────────────────────────────────────────
  bool _showMeasureTip = false;

  final GlobalKey _cameraKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();

    controller = HomeController(repo: HomeRepository());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.init(
        id: widget.userId,
        name: widget.userName,
        cartProvider: context.read<CartProvider>(),
      );

      fetchProfileImage();

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) _showOverlay();
      });
    });
  }

  @override
  void dispose() {
    _removeOverlay();
    controller.dispose();
    super.dispose();
  }

  // ── Overlay helpers ───────────────────────────────────────────────────────

  void _showOverlay() {
    _removeOverlay();
    setState(() => _showMeasureTip = true);

    final RenderBox? box =
        _cameraKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final Offset pos = box.localToGlobal(Offset.zero);
    const double popupWidth = 230;
    final double popupTop = pos.dy + box.size.height + 8;
    final double popupLeft = pos.dx + box.size.width - popupWidth;

    _overlayEntry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _removeOverlay,
            ),
          ),
          Positioned(
            top: popupTop,
            left: popupLeft,
            child: Material(
              color: Colors.transparent,
              child: _MeasurePopup(
                darkBrown: darkBrown,
                onDismiss: _removeOverlay,
                onStart: () {
                  _removeOverlay();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ReferenceScreen(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) setState(() => _showMeasureTip = false);
  }

  void _toggleOverlay() {
  if (_showMeasureTip) {
    _removeOverlay();
  } else {
    // لو الـ popup اتقفل قبل كده، افتح الـ flow مباشرة
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ReferenceScreen(),
      ),
    );
  }
}

  // ─────────────────────────────────────────────────────────────────────────

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.userId != widget.userId ||
        oldWidget.userName != widget.userName) {
      controller.userId = widget.userId;
      controller.userName = widget.userName;
      controller.isLoggedIn = widget.userId != null;
      controller.notifyListeners();

      if (widget.userId != null) {
        controller.loadUserData(context.read<CartProvider>());
        fetchProfileImage();
      }
    }
  }

void showSnack(String message) {
  if (!mounted) return;

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  });
}

  Color hexToColor(String hex) {
    final cleaned = hex.replaceAll('#', '');
    return Color(int.parse('FF$cleaned', radix: 16));
  }

  Future<void> fetchProfileImage() async {
    final id = controller.userId ?? widget.userId;
    if (id == null) return;

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/settings/$id'),
        headers: {"ngrok-skip-browser-warning": "true"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final settings = data['settings'];
          if (!mounted) return;
          setState(() {
            profileImageUrl = settings['profileImagePath'];
          });
        }
      }
    } catch (e) {
      print('FETCH PROFILE IMAGE ERROR: $e');
    }
  }

  void openCart() {
    if (!controller.isLoggedIn || controller.userId == null) {
      showSnack("Please log in first!");
      return;
    }
    widget.onTabSelected?.call(4);
  }

  void openChat() {
    if (!controller.isLoggedIn || controller.userId == null) {
      showSnack("Please log in first!");
      return;
    }
    widget.onTabSelected?.call(1);
  }

  Future<void> openProfile() async {
    if (!controller.isLoggedIn || controller.userId == null) {
      showSnack("Please log in first!");
      return;
    }

    final updatedName = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MyProfilePage(
          userId: controller.userId!,
          currentName: controller.userName ?? '',
        ),
      ),
    );

    await fetchProfileImage();

    if (updatedName != null && updatedName is String) {
      final isNameChanged = updatedName != controller.userName;
      controller.updateName(updatedName);
      if (isNameChanged) {
  widget.onAuthChanged?.call(controller.userId, updatedName);
}
      if (mounted) setState(() {});
    }
  }

  void openSettingsPage() {
    final repository = SettingsRepositoryImpl(
      remoteDataSource: SettingsRemoteDataSource(),
      userId: controller.userId ?? 1,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => SettingsBloc(
            getSettings: GetSettingsUseCase(repository),
            saveSettings: SaveSettingsUseCase(repository),
            clearCache: ClearCacheUseCase(repository),
          )..add(LoadSettingsEvent()),
          child: SettingsScreen(userId: controller.userId ?? 0),
        ),
      ),
    );
  }

  void openHelpPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HelpPage()),
    );
  }

  void openPointsPage() {
    final repository = PointsRepositoryImpl(
      remoteDataSource: PointsRemoteDataSource(),
      userId: controller.userId ?? 1,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => PointsBloc(
            getPoints: GetPointsUseCase(repository),
            earnPoints: EarnPointsUseCase(repository),
            redeemPoints: RedeemPointsUseCase(repository),
            savePoints: SavePointsUseCase(repository),
          )..add(LoadPointsEvent()),
          child: const PointsScreen(),
        ),
      ),
    );
  }

  void openOrdersPage() {
    if (!controller.isLoggedIn || controller.userId == null) {
      showSnack("Please log in first!");
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrdersPage(customerId: controller.userId!),
      ),
    );
  }

  void handleBottomNavTap(int index) {
    switch (index) {
      case 1:
        openChat();
        break;
      case 3:
        showSnack("Open a product first to try it in your room");
        break;
      case 4:
        openCart();
        break;
      case 5:
        openProfile();
        break;
    }
  }

  void completeAuth(Map result) {
    final id = int.tryParse('${result['user_id']}');
    final name = result['name']?.toString();

    if (id == null) {
      showSnack("Login data is incomplete");
      return;
    }

    controller.login({
      ...result,
      'user_id': id,
      'name': name,
    }, context.read<CartProvider>());

    fetchProfileImage();

    if (widget.onAuthChanged != null) {
      widget.onAuthChanged!(id, name);
    } else {
      MainShell.openTab(context, index: 0, userId: id, userName: name);
    }
  }

  Future<void> showLogoutDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.redAccent),
            SizedBox(width: 8),
            Text("Log out", style: TextStyle(color: darkBrown)),
          ],
        ),
        content: const Text(
          "Are you sure you want to log out?\nWe'll miss you 💔",
          style: TextStyle(color: darkBrown, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Yes", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result == true) {
      controller.logout(context.read<CartProvider>());
      widget.onAuthChanged?.call(null, null);
      Navigator.of(context).pop();
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  BUILD
  // ════════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: bgColor,
          drawer: controller.isLoggedIn ? buildDrawer() : null,
          drawerEnableOpenDragGesture: controller.isLoggedIn,
          floatingActionButton: buildAiButton(),
          appBar: buildAppBar(),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildSearchSection(),
                buildSectionHeader("Categories"),
                const SizedBox(height: 12),
                buildCategories(),
                const SizedBox(height: 25),
                buildSlider(),
                const SizedBox(height: 25),
                buildSectionHeader("Furniture in Unique Style"),
                const SizedBox(height: 12),
                buildProductsGrid(),
                const SizedBox(height: 90),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: bgColor,
      elevation: 0,
      toolbarHeight: 65,
      leadingWidth: controller.isLoggedIn ? 48 : 14,
      titleSpacing: 0,
      leading: controller.isLoggedIn
          ? Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu, color: darkBrown, size: 28),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            )
          : const SizedBox.shrink(),
      title: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chair_alt, color: darkBrown, size: 24),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              "FurniMatch",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: darkBrown,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
      actions: [
        if (controller.isLoggedIn)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 120),
              child: Center(
                child: Text(
                  "Hi, ${controller.userName ?? 'User'} 👋",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: darkBrown,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          )
        else
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TopButton(
                label: "Sign Up",
                bg: darkBrown,
                textColor: Colors.white,
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignUpPage()),
                  );
                  if (result != null) completeAuth(result);
                },
              ),
              const SizedBox(width: 8),
              TopButton(
                label: "Log In",
                bg: Colors.transparent,
                textColor: darkBrown,
                isOutlined: true,
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                  if (result != null) completeAuth(result);
                },
              ),
              const SizedBox(width: 10),
            ],
          ),
      ],
    );
  }

  // ── Search Section ────────────────────────────────────────────────────────

  Widget buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: SearchBarWidget(
              onFavPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FavoritesScreen(
                      userId: controller.userId,
                      userName: controller.userName,
                    ),
                  ),
                ).then((updatedName) {
                  controller.loadFavorites();
                  fetchProfileImage();
                  if (updatedName is String) {
                    controller.updateName(updatedName);
                    widget.onAuthChanged?.call(controller.userId, updatedName);
                    if (mounted) setState(() {});
                  }
                });
              },
              onSearchPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SearchPage(
                      userId: controller.userId,
                      userName: controller.userName,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 8),

          // ── Camera Button ───────────────────────────────────────────────
          GestureDetector(
            key: _cameraKey,
            onTap: _toggleOverlay,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Icon(
                      Icons.camera_alt_outlined,
                      color: darkBrown,
                      size: 22,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Categories ────────────────────────────────────────────────────────────

  Widget buildCategories() {
    return SizedBox(
      height: 85,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 15, right: 15),
        physics: const BouncingScrollPhysics(),
        children: [
          CategoryBox(
            title: "Living room",
            imgPath: "assets/images/Living_room.jpg",
            color: const Color(0xFFE5E5E7),
            userId: controller.userId,
            userName: controller.userName,
          ),
          CategoryBox(
            title: "Bedroom",
            imgPath: "assets/images/bedroom.jpg",
            color: const Color(0xFFE8E4D9),
            userId: controller.userId,
            userName: controller.userName,
          ),
          CategoryBox(
            title: "Home office",
            imgPath: "assets/images/office.jpg",
            color: const Color(0xFFDEDEE0),
            userId: controller.userId,
            userName: controller.userName,
          ),
          CategoryBox(
            title: "Kitchen",
            imgPath: "assets/images/kitchen.jpg",
            color: const Color(0xFFE5E5E7),
            userId: controller.userId,
            userName: controller.userName,
          ),
          CategoryBox(
            title: "Dining room",
            imgPath: "assets/images/dining.jpg",
            color: const Color(0xFFE8E4D9),
            userId: controller.userId,
            userName: controller.userName,
          ),
        ],
      ),
    );
  }

  // ── Slider ────────────────────────────────────────────────────────────────

  Widget buildSlider() {
    return CarouselSlider(
      options: CarouselOptions(
        height: 175,
        viewportFraction: 0.9,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 5),
        autoPlayAnimationDuration: const Duration(milliseconds: 1500),
        enlargeCenterPage: true,
      ),
      items: [
        SliderItem(
          title: "Sell your products\nwith us!",
          btnText: "Become a seller",
          imgPath: "assets/images/ad1.jpg",
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SellerRegistrationPage()),
          ),
        ),
        SliderItem(
          title: "Customize Your\norder now!",
          btnText: "Chat with Seller →",
          imgPath: "assets/images/ad2.jpg",
          onPressed: openChat,
        ),

        // ── Orders Slide ──────────────────────────────────────────────────
        SliderItem(
          title: "Track Your\nOrders!",
          btnText: "View Orders →",
          imgPath: "assets/images/ad1.jpg",
          onPressed: openOrdersPage,
        ),
        // ─────────────────────────────────────────────────────────────────
      ],
    );
  }

  // ── Products Grid ─────────────────────────────────────────────────────────

  Widget buildProductsGrid() {
    if (controller.isLoadingProducts) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(color: Colors.brown),
        ),
      );
    }

    if (controller.products.isEmpty) {
      final hasError = controller.productsErrorMessage != null;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                hasError ? Icons.wifi_off_rounded : Icons.inventory_2_outlined,
                size: 40,
                color: Colors.brown,
              ),
              const SizedBox(height: 10),
              Text(
                hasError
                    ? "فشل الاتصال بالسيرفر، حاول تاني"
                    : "No products yet",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.brown),
              ),
              if (hasError) ...[
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: () => controller.loadProducts(),
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: const Text("Retry",
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 18,
          childAspectRatio: 0.56,
        ),
        itemCount: controller.products.length,
        itemBuilder: (_, i) {
          final product = controller.products[i];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetailsPage(
                    product: product.raw,
                    userId: controller.userId,
                    userName: controller.userName,
                  ),
                ),
              ).then((_) {
                controller.loadFavorites();
                fetchProfileImage();
                if (controller.userId != null) {
                  context
                      .read<CartProvider>()
                      .fetchCartCount(controller.userId!);
                }
              });
            },
            child: ProductCardWidget(
              product: product,
              isFavorite: controller.favoriteIds.contains(product.id),
              onFavoriteTap: () async {
                final msg = await controller.toggleFavorite(product);
                showSnack(msg);
              },
             onAddToCart: () async {
  final msg = await controller.addProductToCart(
    product,
    context.read<CartProvider>(),
  );

  if (!mounted) return;

  showSnack(msg);
},
              hexToColor: hexToColor,
            ),
          );
        },
      ),
    );
  }

  // ── Drawer ────────────────────────────────────────────────────────────────

  Widget buildDrawer() {
    return Drawer(
      width: 290,
      child: Container(
        color: bgColor,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 55, 20, 24),
              decoration: const BoxDecoration(
                color: darkBrown,
                borderRadius:
                    BorderRadius.only(bottomRight: Radius.circular(28)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    backgroundImage:
                        profileImageUrl != null && profileImageUrl!.isNotEmpty
                            ? NetworkImage(profileImageUrl!)
                            : null,
                    child: profileImageUrl == null || profileImageUrl!.isEmpty
                        ? const Icon(Icons.person,
                            size: 34, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      controller.userName ?? "User",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            DrawerItem(
              icon: Icons.groups_outlined,
              title: "About Us",
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AboutUsPage()));
              },
            ),
            DrawerItem(
              icon: Icons.shopping_bag_outlined,
              title: "My Orders",
              onTap: () {
                Navigator.pop(context);
                openOrdersPage();
              },
            ),
            DrawerItem(
              icon: Icons.stars_rounded,
              title: "My Points",
              onTap: () {
                Navigator.pop(context);
                openPointsPage();
              },
            ),
            DrawerItem(
              icon: Icons.settings_outlined,
              title: "Settings",
              onTap: () {
                Navigator.pop(context);
                openSettingsPage();
              },
            ),
            DrawerItem(
              icon: Icons.help_outline,
              title: "Help",
              onTap: () {
                Navigator.pop(context);
                openHelpPage();
              },
            ),
            const Spacer(),
            const Divider(height: 1),
            DrawerItem(
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
    );
  }

  // ── AI Button ─────────────────────────────────────────────────────────────

  Widget buildAiButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () {
          if (!controller.isLoggedIn) {
            showSnack("Please log in first!");
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
            errorBuilder: (_, __, ___) => const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.smart_toy, size: 40, color: Colors.blue),
            ),
          ),
        ),
      ),
    );
  }

  // ── Section Header ────────────────────────────────────────────────────────

  Widget buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Text(
        title,
        style: const TextStyle(
          color: darkBrown,
          fontSize: 21,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  Measure Popup Widget
// ══════════════════════════════════════════════════════════════════════════════

class _MeasurePopup extends StatelessWidget {
  final Color darkBrown;
  final VoidCallback onDismiss;
  final VoidCallback onStart;

  const _MeasurePopup({
    required this.darkBrown,
    required this.onDismiss,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Measure your room',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: darkBrown,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: onDismiss,
                        child: Icon(Icons.close,
                            size: 16, color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Use your camera to measure your space easily.',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: onStart,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: darkBrown,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Start measuring →',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF6F0E9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.view_in_ar_outlined,
                color: darkBrown,
                size: 26,
              ),
            ),
          ],
        ),
      ),
    );
  }
}