import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F3EE),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF2C2416), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Help Center',
          style: TextStyle(
            color: Color(0xFF2C2416),
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF4A7C59),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.support_agent_rounded, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('How can we help?', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                      SizedBox(height: 2),
                      Text('Find answers or contact us', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // FAQ Section
          _sectionTitle('Frequently Asked Questions'),
          const SizedBox(height: 10),
          _faqCard([
            _FaqItem('How do I place furniture in AR?',
                'Open any product, tap "Try in Room", point your camera at a flat floor surface and wait for the yellow dots to appear, then tap to place.'),
            _FaqItem('Can I change the furniture color in AR?',
                'Yes! Tap the color swatches below the product before entering AR mode, or use the color panel inside AR view.'),
            _FaqItem('Why is AR not detecting my floor?',
                'Make sure the area is well-lit. Slowly move your camera across the floor in a scanning motion. Shiny or plain white floors may take longer to detect.'),
            _FaqItem('Can I save my AR room arrangement?',
                'Tap the camera icon in AR mode to take a screenshot. It saves directly to your phone gallery.'),
            _FaqItem('How do I use the room measurement tool?',
                'Go to the Measure tab inside AR, tap two points on the floor or wall to get an accurate distance reading.'),
            _FaqItem('Is the furniture size accurate in AR?',
                'Yes! All 3D models are built to the exact real-world dimensions listed on the product page.'),
          ]),
          const SizedBox(height: 24),

          // Contact Support
          _sectionTitle('Contact Support'),
          const SizedBox(height: 10),
          _contactCard(
            icon: Icons.email_outlined,
            color: const Color(0xFF3D4A6B),
            title: 'Email Us',
            subtitle: 'support@furnit.app',
            note: 'We reply within 24 hours',
          ),
          const SizedBox(height: 10),
          _contactCard(
            icon: Icons.chat_bubble_outline_rounded,
            color: const Color(0xFF4A7C59),
            title: 'Live Chat',
            subtitle: 'Chat with an agent',
            note: 'Available Sun–Thu, 9am – 6pm',
          ),
          const SizedBox(height: 10),
          _contactCard(
            icon: Icons.phone_outlined,
            color: const Color(0xFF8B6914),
            title: 'Call Us',
            subtitle: '+20 100 000 0000',
            note: 'Available Sun–Thu, 10am – 5pm',
          ),
          const SizedBox(height: 24),

          // Tutorial Section
          _sectionTitle('Video Tutorials'),
          const SizedBox(height: 10),
          _tutorialTile(Icons.play_circle_outline_rounded, 'Getting Started with AR', '2 min'),
          const SizedBox(height: 8),
          _tutorialTile(Icons.play_circle_outline_rounded, 'How to Measure Your Room', '3 min'),
          const SizedBox(height: 8),
          _tutorialTile(Icons.play_circle_outline_rounded, 'Browsing & Filtering Products', '2 min'),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) => Text(t,
      style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF8B6914), letterSpacing: 0.8));

  Widget _faqCard(List<_FaqItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: items.map((item) {
          final isLast = items.last == item;
          return Column(
            children: [
              ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                title: Text(item.q,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF2C2416))),
                children: [
                  Text(item.a,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.6))
                ],
              ),
              if (!isLast)
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Divider(height: 1, color: Colors.grey.shade100),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _contactCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String note,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF2C2416))),
              Text(subtitle, style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w500)),
              Text(note, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            ]),
          ),
          Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  Widget _tutorialTile(IconData icon, String title, String duration) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF8B6914), size: 26),
          const SizedBox(width: 14),
          Expanded(
              child: Text(title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF2C2416)))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF8B6914).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(duration,
                style: const TextStyle(fontSize: 12, color: Color(0xFF8B6914), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _FaqItem {
  final String q, a;
  const _FaqItem(this.q, this.a);
}