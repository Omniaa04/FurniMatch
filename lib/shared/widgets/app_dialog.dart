import 'package:flutter/material.dart';

class AppDialog {
  static const background = Color(0xFFF6F0E9);
  static const brown = Color(0xFF7D533D);
  static const red = Color(0xFFFF5A5F);
  static const muted = Color(0xFF9E9E9E);

  static Future<bool?> confirm({
    required BuildContext context,
    required String title,
    required String message,
    IconData icon = Icons.info_outline,
    String cancelText = 'No',
    String confirmText = 'Yes',
    Color accentColor = red,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
        contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        title: Row(
          children: [
            Icon(icon, color: accentColor, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: brown,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(
            color: brown,
            fontSize: 16,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            style: TextButton.styleFrom(
              foregroundColor: muted,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
            child: Text(
              cancelText,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              confirmText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
