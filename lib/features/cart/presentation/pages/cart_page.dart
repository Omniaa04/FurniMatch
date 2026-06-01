// // import 'package:flutter/material.dart';
// // import 'package:flutter_bloc/flutter_bloc.dart';
// // import '../bloc/cart_bloc.dart';
// // import '../bloc/cart_event.dart';
// // import '../bloc/cart_state.dart';
// // import '../widgets/cart_item_card.dart';
// // import '../widgets/cart_summary_card.dart';
// // import '../widgets/share_cart_overlay.dart';

// // class CartPage extends StatefulWidget {
// //   final VoidCallback? onBackToHome;

// //   const CartPage({super.key, this.onBackToHome});

// //   @override
// //   State<CartPage> createState() => _CartPageState();
// // }

// // class _CartPageState extends State<CartPage> {
// //   @override
// //   void initState() {
// //     super.initState();
// //     context.read<CartBloc>().add(LoadCartEvent());
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color(0xFFF7F2ED),
// //       body: SafeArea(
// //         child: BlocBuilder<CartBloc, CartState>(
// //           builder: (context, state) {
// //             if (state is CartLoading) {
// //               return const Center(
// //                 child: CircularProgressIndicator(color: Color(0xFF7A5C3E)),
// //               );
// //             }

// //             if (state is CartError) {
// //               return Center(child: Text(state.message));
// //             }

// //             if (state is CartLoaded) {
// //               if (state.items.isEmpty) {
// //                 return Column(
// //                   children: [
// //                     _CartAppBar(
// //                       isShareVisible: false,
// //                       onBackToHome: widget.onBackToHome,
// //                     ),
// //                     const Expanded(
// //                       child: Center(
// //                         child: Column(
// //                           mainAxisAlignment: MainAxisAlignment.center,
// //                           children: [
// //                             Icon(Icons.shopping_cart_outlined,
// //                                 size: 80, color: Color(0xFFD0C4B8)),
// //                             SizedBox(height: 16),
// //                             Text(
// //                               'Your cart is empty',
// //                               style: TextStyle(
// //                                 fontSize: 18,
// //                                 fontWeight: FontWeight.w600,
// //                                 color: Color(0xFF7A5C3E),
// //                                 fontFamily: "Baloo2",
// //                               ),
// //                             ),
// //                             SizedBox(height: 8),
// //                             Text(
// //                               'Add products from the home page',
// //                               style: TextStyle(
// //                                 fontSize: 14,
// //                                 color: Color(0xFF9E9E9E),
// //                                 fontFamily: "Baloo2",
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 );
// //               }
// //               return Stack(
// //                 children: [
// //                   Column(
// //                     children: [
// //                       // App Bar
// //                       _CartAppBar(
// //                         isShareVisible: state.isShareVisible,
// //                         onBackToHome: widget.onBackToHome,
// //                       ),
// //                       // Items list
// //                       Expanded(
// //                         child: ListView(
// //                           padding: const EdgeInsets.symmetric(horizontal: 20),
// //                           children: [
// //                             const SizedBox(height: 8),
// //                             ...state.items.map(
// //                               (item) => Column(
// //                                 children: [
// //                                   CartItemCard(item: item),
// //                                   const Divider(
// //                                     color: Color.fromARGB(255, 189, 154, 137),
// //                                     thickness: 1,
// //                                     height: 20,
// //                                   ),
// //                                 ],
// //                               ),
// //                             ),
// //                             const SizedBox(height: 16),
// //                           ],
// //                         ),
// //                       ),
// //                       // Summary
// //                       Padding(
// //                         padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
// //                         child: CartSummaryCard(summary: state.summary),
// //                       ),
// //                     ],
// //                   ),
// //                   // Share overlay
// //                   if (state.isShareVisible)
// //                     const Positioned(
// //                       top: 70,
// //                       right: 16,
// //                       child: ShareCartOverlay(),
// //                     ),
// //                 ],
// //               );
// //             }

// //             return const SizedBox.shrink();
// //           },
// //         ),
// //       ),
// //     );
// //   }
// // }

// // class _CartAppBar extends StatelessWidget {
// //   final bool isShareVisible;
// //   final VoidCallback? onBackToHome;

// //   const _CartAppBar({
// //     required this.isShareVisible,
// //     this.onBackToHome,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
// //       child: Row(
// //         children: [
// //           GestureDetector(
// //             onTap: onBackToHome ?? () => Navigator.maybePop(context),
// //             child: Container(
// //               width: 40,
// //               height: 40,
// //               decoration: BoxDecoration(
// //                 color: Colors.white,
// //                 borderRadius: BorderRadius.circular(12),
// //                 boxShadow: [
// //                   BoxShadow(
// //                     color: Colors.black.withOpacity(0.06),
// //                     blurRadius: 8,
// //                     offset: const Offset(0, 2),
// //                   ),
// //                 ],
// //               ),
// //               child: const Icon(
// //                 Icons.arrow_back_ios_new,
// //                 size: 18,
// //                 color: Color(0xFF2C2C2C),
// //               ),
// //             ),
// //           ),
// //           const Expanded(
// //             child: Text(
// //               'My Cart',
// //               textAlign: TextAlign.center,
// //               style: TextStyle(
// //                 fontSize: 18,
// //                 fontFamily: "Baloo2",
// //                 fontWeight: FontWeight.w700,
// //                 color: Color(0xFF2C2C2C),
// //               ),
// //             ),
// //           ),
// //           GestureDetector(
// //             onTap: () => context.read<CartBloc>().add(ShareCartEvent()),
// //             child: Container(
// //               width: 40,
// //               height: 40,
// //               decoration: BoxDecoration(
// //                 color: isShareVisible
// //                     ? const Color(0xFF7D533D)
// //                     : const Color(0xFFCF8D5B),
// //                 borderRadius: BorderRadius.circular(12),
// //               ),
// //               child: const Icon(
// //                 Icons.ios_share,
// //                 size: 20,
// //                 color: Colors.white,
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../domain/entities/cart_summary.dart';
// import '../bloc/cart_bloc.dart';
// import '../bloc/cart_event.dart';
// import 'package:furnimatch/features/checkout/presentation/screen/payment_method_screen.dart';

// class CartSummaryCard extends StatefulWidget {
//   final CartSummary summary;
//   final int userId; // ✅ ضيفي ده

//   const CartSummaryCard({
//     super.key,
//     required this.summary,
//     required this.userId, // ✅
//   });

//   @override
//   State<CartSummaryCard> createState() => _CartSummaryCardState();
// }

// class _CartSummaryCardState extends State<CartSummaryCard> {
//   final _promoController = TextEditingController();

//   @override
//   void dispose() {
//     _promoController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.06),
//             blurRadius: 20,
//             offset: const Offset(0, -4),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: Container(
//                   height: 48,
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFF0EBE5),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: TextField(
//                     controller: _promoController,
//                     decoration: const InputDecoration(
//                       hintText: 'Promo code',
//                       hintStyle: TextStyle(
//                           color: Color(0xFFB0A090),
//                           fontSize: 14,
//                           fontFamily: "Baloo2"),
//                       border: InputBorder.none,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               GestureDetector(
//                 onTap: () {
//                   if (_promoController.text.isNotEmpty) {
//                     context.read<CartBloc>().add(
//                           ApplyPromoCodeEvent(_promoController.text),
//                         );
//                   }
//                 },
//                 child: Container(
//                   height: 48,
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF7D533D),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: const Center(
//                     child: Text(
//                       'Apply',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 14,
//                         fontFamily: "Baloo2",
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           _SummaryRow('Sub - Total', widget.summary.subTotal),
//           const SizedBox(height: 10),
//           _SummaryRow('Delivery Fee', widget.summary.deliveryFee),
//           const SizedBox(height: 10),
//           _SummaryRow('Discount', -widget.summary.discount,
//               isDiscount: widget.summary.discount > 0),
//           const Padding(
//             padding: EdgeInsets.symmetric(vertical: 14),
//             child: Divider(color: Color(0xFFEEE8E0), thickness: 1),
//           ),
//           _SummaryRow('Total Cost', widget.summary.totalCost, isTotal: true),
//           const SizedBox(height: 20),
//           SizedBox(
//             width: double.infinity,
//             height: 54,
//             child: ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => PaymentMethodScreen(userId: widget.userId), // ✅
//                   ),
//                 );
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF7D533D),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 elevation: 0,
//               ),
//               child: const Text(
//                 'Proceed to Checkout',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   fontFamily: "Baloo2",
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _SummaryRow extends StatelessWidget {
//   final String label;
//   final double amount;
//   final bool isTotal;
//   final bool isDiscount;

//   const _SummaryRow(
//     this.label,
//     this.amount, {
//     this.isTotal = false,
//     this.isDiscount = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final displayAmount = isDiscount
//         ? '-\$ ${amount.abs().toStringAsFixed(2)}'
//         : '\$ ${amount.toStringAsFixed(2)}';

//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Expanded(
//           child: Text(
//             label,
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//             style: TextStyle(
//               fontSize: isTotal ? 15 : 14,
//               fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
//               fontFamily: "Baloo2",
//               color: const Color(0xFF3A2E26),
//             ),
//           ),
//         ),
//         const SizedBox(width: 12),
//         Text(
//           displayAmount,
//           style: TextStyle(
//             fontSize: isTotal ? 15 : 14,
//             fontFamily: "Baloo2",
//             fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
//             color: isDiscount
//                 ? const Color(0xFF7A5C3E)
//                 : const Color(0xFF2C2C2C),
//           ),
//         ),
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';
import '../bloc/cart_state.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/cart_summary_card.dart';
import '../widgets/share_cart_overlay.dart';
import 'package:furnimatch/features/cart/injection_container.dart';
import 'package:furnimatch/features/cart/data/datasources/cart_local_datasource.dart';
import 'package:furnimatch/features/buttom_nav/main_shell.dart';
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
  @override
  @override
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      sl<CartLocalDataSource>().setUserId(widget.userId);
      context.read<CartBloc>().add(LoadCartEvent());
    });
  }

  @override
  void didUpdateWidget(covariant CartPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.userId != widget.userId) {
      sl<CartLocalDataSource>().setUserId(widget.userId);
      context.read<CartBloc>().add(LoadCartEvent());
    } else {
      sl<CartLocalDataSource>().setUserId(widget.userId);
      context.read<CartBloc>().add(LoadCartEvent());
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
              context.read<CartProvider>().resetCartCount(count);
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
                      userId: widget.userId,
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
                        userId: widget.userId,
                      ),
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
                                    color: Color(0xFFE8E0D8),
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
                      child: ShareCartOverlay(shareUrl: 'https://chance-impeding-curable.ngrok-free.dev/cart/shared/${widget.userId}'),
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
  final int userId;

  const _CartAppBar({
    required this.isShareVisible,
    required this.userId,
  });


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              MainShell.openTab(
                context,
                index: 0, // ✅ ده الـ Home
                userId: userId, // هنظبطها تحت
              );
            },
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
            onTap: () => context.read<CartBloc>().add(ShareCartEvent()),
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
