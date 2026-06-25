import 'package:flutter/material.dart';

class ShareCartOverlay extends StatelessWidget {
  final VoidCallback onShare;

  const ShareCartOverlay({super.key, required this.onShare});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 235, 217, 203),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'share via',
            style: TextStyle(
              fontSize: 12,
              fontFamily: "Baloo2",
              color: Color(0xFF9E9E9E),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SocialIcon(
                icon: Icons.ios_share,
                color: const Color(0xFF8B7355),
                onTap: onShare,
              ),
              const SizedBox(width: 10),
              _SocialIcon(
                icon: Icons.message,
                color: const Color(0xFF25D366),
                isWhatsApp: true,
                onTap: onShare,
              ),
              const SizedBox(width: 10),
              _SocialIcon(
                icon: Icons.facebook,
                color: const Color(0xFF1877F2),
                onTap: onShare,
              ),
              const SizedBox(width: 10),
              _SocialIcon(
                icon: Icons.camera_alt,
                color: const Color(0xFFE1306C),
                onTap: onShare,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool isWhatsApp;
  final VoidCallback onTap;

  const _SocialIcon({
    required this.icon,
    required this.color,
    required this.onTap,
    this.isWhatsApp = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isWhatsApp ? color : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE0D8D0), width: 1),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isWhatsApp ? Colors.white : color,
        ),
      ),
    );
  }
}