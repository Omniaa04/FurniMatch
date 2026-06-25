import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';
import '../bloc/cart_state.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/cart_summary_card.dart';
import '../widgets/share_cart_overlay.dart';
import 'package:furnimatch/features/cart/injection_container.dart';
import 'package:furnimatch/features/cart/data/datasources/cart_local_datasource.dart';
import 'package:furnimatch/providers/cart_provider.dart';

class CartPage extends StatefulWidget {
  final int userId;
  final VoidCallback? onBackToHome;

  const CartPage({
    super.key,
    required this.userId,
    this.onBackToHome,
  });

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    // ✅ بنستخدم initState مش didChangeDependencies
    // عشان didChangeDependencies بتتكال أكتر من مرة وبتسبب مشاكل
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        sl<CartLocalDataSource>().setUserId(widget.userId);
        context.read<CartBloc>().add(LoadCartEvent());
      }
    });
  }

  Future<void> _shareCart() async {
    try {
      final imageBytes = await screenshotController.capture();
      if (imageBytes == null) return;

      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(imageBytes,
                name: 'cart.png', mimeType: 'image/png')
          ],
          text: '🛍️ Check out my FurniMatch cart!',
        ),
      );
    } catch (e) {
      debugPrint('share error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F0E9),
      body: SafeArea(
        child: BlocConsumer<CartBloc, CartState>(
          listener: (context, state) {
            if (state is CartLoaded) {
              final count = state.items.fold<int>(
                0,
                (sum, item) => sum + item.quantity,
              );
              context.read<CartProvider>().setCartCount(count);
            }
          },
          builder: (context, state) {
            if (state is CartLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF7D533D)),
              );
            }

            if (state is CartError) {
              return Center(child: Text(state.message));
            }

            if (state is CartLoaded) {
              if (state.items.isEmpty) {
                return Column(
                  children: [
                    _CartAppBar(
                      isShareVisible: false,
                      onShare: _shareCart,
                      onBack: widget.onBackToHome,
                    ),
                    const Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_cart_outlined,
                                size: 80, color: Color(0xFFAD8B73)),
                            SizedBox(height: 16),
                            Text(
                              'Your cart is empty',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF7D533D),
                                fontFamily: "Baloo2",
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Add products from the home page',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFFAD8B73),
                                fontFamily: "Baloo2",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }

              return Stack(
                children: [
                  Column(
                    children: [
                      _CartAppBar(
                        isShareVisible: state.isShareVisible,
                        onShare: _shareCart,
                        onBack: widget.onBackToHome,
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Screenshot(
                            controller: screenshotController,
                            child: Container(
                              color: const Color(0xFFF6F0E9),
                              child: Column(
                                children: [
                                  const SizedBox(height: 8),
                                  ...state.items.map(
                                    (item) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      child: Column(
                                        children: [
                                          CartItemCard(item: item),
                                          const Divider(
                                            color: Color(0xFFE8E0D8),
                                            thickness: 1,
                                            height: 20,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: CartSummaryCard(
                          summary: state.summary,
                          userId: widget.userId,
                        ),
                      ),
                    ],
                  ),
                  if (state.isShareVisible)
                    Positioned(
                      top: 70,
                      right: 16,
                      child: ShareCartOverlay(onShare: _shareCart),
                    ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _CartAppBar extends StatelessWidget {
  final bool isShareVisible;
  final VoidCallback onShare;
  final VoidCallback? onBack;

  const _CartAppBar({
    required this.isShareVisible,
    required this.onShare,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: Color(0xFF7D533D),
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Cart',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 24,
                fontFamily: "Baloo2",
                fontWeight: FontWeight.w700,
                color: Color(0xFF7D533D),
              ),
            ),
          ),
          GestureDetector(
            onTap: onShare,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isShareVisible
                    ? const Color(0xFF7D533D)
                    : const Color(0xFFAD8B73),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.ios_share,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}