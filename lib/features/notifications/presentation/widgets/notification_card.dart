import 'package:flutter/material.dart';
import '../../domain/notification_model.dart';

class NotificationCard extends StatelessWidget {
  final NotificationItem item;

  const NotificationCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final bool isOrder = item.type == NotificationType.order;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5EDE5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Icon ──
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isOrder
                  ? Icons.shopping_cart_outlined
                  : Icons.chat_bubble_outline,
              size: 18,
              color: const Color(0xFFC4845A),
            ),
          ),

          const SizedBox(width: 12),

          // ── Text ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.text,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Colors.black87,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  item.time,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.brown.shade300,
                  ),
                ),
              ],
            ),
          ),

          // ── Unread dot ──
          if (item.isUnread)
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 4),
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFC4845A),
                ),
              ),
            ),
        ],
      ),
    );
  }
}