import 'package:flutter/material.dart';
import '../../domain/entities/cart_item.dart';
import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:furnimatch/shared/widgets/app_dialog.dart';

class CartItemCard extends StatelessWidget {
  final CartItem item;

  const CartItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      confirmDismiss: (_) async {
        return await AppDialog.confirm(
          context: context,
          title: 'Delete Item',
          message: 'Are you sure you want to delete this item?',
          icon: Icons.delete_outline,
          cancelText: 'Cancel',
          confirmText: 'Delete',
        );
      },
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF7D533D),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      onDismissed: (_) {
        context.read<CartBloc>().add(RemoveItemEvent(item.id));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                item.imageUrl,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8E0D8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.chair, color: Color(0xFF7D533D)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Item details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontFamily: "Baloo2",
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C2C2C),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: "Baloo2",
                      color: Color(0xFF9E9E9E),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '\$ ${item.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontFamily: "Baloo2",
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2C2C2C),
                    ),
                  ),
                ],
              ),
            ),
            // Quantity controls
            FittedBox(
              fit: BoxFit.scaleDown,
              child: _QuantityControl(item: item),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityControl extends StatelessWidget {
  final CartItem item;

  const _QuantityControl({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CircleButton(
          icon: Icons.remove,
          onTap: () {
            if (item.quantity > 1) {
              context.read<CartBloc>().add(
                    UpdateQuantityEvent(item.id, item.quantity - 1),
                  );
            }
          },
        ),
        SizedBox(
          width: 24,
          child: Text(
            '${item.quantity}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontFamily: "Baloo2",
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C2C2C),
            ),
          ),
        ),
        _CircleButton(
          icon: Icons.add,
          filled: true,
          onTap: () {
            context.read<CartBloc>().add(
                  UpdateQuantityEvent(item.id, item.quantity + 1),
                );
          },
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  const _CircleButton({
    required this.icon,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: filled ? const Color(0xFF7D533D) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: filled
              ? null
              : Border.all(color: const Color(0xFFD0C4B8), width: 1.5),
        ),
        child: Icon(
          icon,
          size: 16,
          color: filled ? Colors.white : const Color(0xFF7D533D),
        ),
      ),
    );
  }
}
