import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:furnimatch/features/cart/data/datasources/cart_local_datasource.dart';
import 'package:furnimatch/features/cart/injection_container.dart';
import 'package:furnimatch/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:furnimatch/features/cart/presentation/pages/cart_page.dart';
import 'package:furnimatch/providers/cart_provider.dart';
import 'package:provider/provider.dart';

class CartIconWithBadge extends StatelessWidget {
  final int userId;

  const CartIconWithBadge({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                sl<CartLocalDataSource>().setUserId(userId);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                      create: (_) => sl<CartBloc>(),
                      child: const CartPage(),
                    ),
                  ),
                );
              },
            ),
            if (cartProvider.cartCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    cartProvider.cartCount > 99
                        ? '99+'
                        : '${cartProvider.cartCount}',
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
        );
      },
    );
  }
}
