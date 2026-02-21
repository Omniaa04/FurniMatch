import 'package:flutter/material.dart';

class PaymentOptionTile extends StatelessWidget {
  final String title;
  final String? image;
  final IconData? icon;
  final VoidCallback? onTap;

  const PaymentOptionTile({
    super.key,
    required this.title,
    this.image,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Row(
          children: [
            if (icon != null)
              Icon(icon, size: 26)
            else if (image != null)
              Image.asset(image!, width: 32),

            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 15),
              ),
            ),
            const Icon(Icons.radio_button_unchecked),
          ],
        ),
      ),
    );
  }
}
