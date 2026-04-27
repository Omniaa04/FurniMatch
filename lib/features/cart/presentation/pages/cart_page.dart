import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';
import '../bloc/cart_state.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/cart_summary_card.dart';
import '../widgets/share_cart_overlay.dart';

class CartPage extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const CartPage({super.key, this.onBackToHome});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    context.read<CartBloc>().add(LoadCartEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2ED),
      body: SafeArea(
        child: BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
            if (state is CartLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF7A5C3E)),
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
                      onBackToHome: widget.onBackToHome,
                    ),
                    const Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_cart_outlined,
                                size: 80, color: Color(0xFFD0C4B8)),
                            SizedBox(height: 16),
                            Text(
                              'Your cart is empty',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF7A5C3E),
                                fontFamily: "Baloo2",
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Add products from the home page',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF9E9E9E),
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
                      // App Bar
                      _CartAppBar(
                        isShareVisible: state.isShareVisible,
                        onBackToHome: widget.onBackToHome,
                      ),
                      // Items list
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          children: [
                            const SizedBox(height: 8),
                            ...state.items.map(
                              (item) => Column(
                                children: [
                                  CartItemCard(item: item),
                                  const Divider(
                                    color: Color.fromARGB(255, 189, 154, 137),
                                    thickness: 1,
                                    height: 20,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                      // Summary
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: CartSummaryCard(summary: state.summary),
                      ),
                    ],
                  ),
                  // Share overlay
                  if (state.isShareVisible)
                    const Positioned(
                      top: 70,
                      right: 16,
                      child: ShareCartOverlay(),
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
  final VoidCallback? onBackToHome;

  const _CartAppBar({
    required this.isShareVisible,
    this.onBackToHome,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBackToHome ?? () => Navigator.maybePop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: Color(0xFF2C2C2C),
              ),
            ),
          ),
          const Expanded(
            child: Text(
              'My Cart',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontFamily: "Baloo2",
                fontWeight: FontWeight.w700,
                color: Color(0xFF2C2C2C),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => context.read<CartBloc>().add(ShareCartEvent()),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isShareVisible
                    ? const Color(0xFF7D533D)
                    : const Color(0xFFCF8D5B),
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
