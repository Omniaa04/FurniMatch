import 'package:flutter/material.dart';

class ShareCartOverlay extends StatelessWidget {
  const ShareCartOverlay({super.key});

  static const List<String> _contacts = [
    'Omnia Abdelhamid',
    'Shahd Elsayed',
    'Shahd Alaa',
    'Rana Ahmed',
    'Haidy Ayman',
  ];

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
            color: Colors.black.withOpacity(0.08),
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
            'share cart to:',
            style: TextStyle(
              fontSize: 12,
              fontFamily: "Baloo2",
              color: Color(0xFF9E9E9E),
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          ..._contacts.map((name) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: GestureDetector(
                  onTap: () {},
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: "Baloo2",
                      color: Color(0xFF3A2E26),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )),
          const SizedBox(height: 12),
          const Text(
            'share via',
            style: TextStyle(
              fontSize: 12,
              fontFamily: "Baloo2",
              color: Color(0xFF9E9E9E),
            ),
          ),
          const SizedBox(height: 10),
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SocialIcon(icon: Icons.link, color: Color(0xFF8B7355)),
              SizedBox(width: 10),
              _SocialIcon(
                  icon: Icons.message,
                  color: Color(0xFF25D366),
                  isWhatsApp: true),
              SizedBox(width: 10),
              _SocialIcon(icon: Icons.facebook, color: Color(0xFF1877F2)),
              SizedBox(width: 10),
              _SocialIcon(
                  icon: Icons.camera_alt, color: Color(0xFFE1306C)),
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

  const _SocialIcon({
    required this.icon,
    required this.color,
    this.isWhatsApp = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
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
