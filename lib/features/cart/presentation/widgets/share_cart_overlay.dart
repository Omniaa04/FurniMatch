import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class ShareCartOverlay extends StatelessWidget {
  final String shareUrl;

  const ShareCartOverlay({
    super.key,
    required this.shareUrl,
  });

  void _copyLink(BuildContext context) {
    Clipboard.setData(ClipboardData(text: shareUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link copied to clipboard')),
    );
  }

  Future<void> _shareViaWhatsApp() async {
    final uri = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(shareUrl)}');
  await launchUrl(uri);
  }

  void _shareViaFacebook() async {
  final uri = Uri.parse('https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(shareUrl)}');
  await launchUrl(uri);
}

  void _shareViaInstagram(BuildContext context) async {
  // Instagram has no direct share URL, so just copy the link
  Clipboard.setData(ClipboardData(text: shareUrl));
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Link copied — paste it in Instagram')),
  );
}

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
                icon: Icons.link,
                color: const Color(0xFF8B7355),
                onTap: () => _copyLink(context),
              ),
              const SizedBox(width: 10),
              _SocialIcon(
                icon: Icons.message,
                color: const Color(0xFF25D366),
                isWhatsApp: true,
                onTap: _shareViaWhatsApp,
              ),
              const SizedBox(width: 10),
              _SocialIcon(
                icon: Icons.facebook,
                color: const Color(0xFF1877F2),
                onTap: _shareViaFacebook,
              ),
              const SizedBox(width: 10),
              _SocialIcon(
                icon: Icons.camera_alt,
                color: const Color(0xFFE1306C),
                onTap: () => _shareViaInstagram(context),
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