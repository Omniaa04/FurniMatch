import 'package:flutter/material.dart';

class PolicyPage extends StatelessWidget {
  const PolicyPage({super.key});

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
          'Our Policy',
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
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2416),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B6914).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.policy_outlined, color: Color(0xFFE8B94A), size: 24),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Our Policy', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                      SizedBox(height: 2),
                      Text('Last updated: January 2025', style: TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _policySection(
            icon: Icons.lock_outline_rounded,
            iconColor: const Color(0xFF3D4A6B),
            title: 'Privacy Policy',
            body:
                'We are committed to protecting your personal information. We collect only the minimum data required to provide our services — your name, email address, and order history.\n\nYour camera feed used during AR sessions is processed entirely on-device and is never transmitted to or stored on our servers. We do not have access to your room scans or spatial data.',
          ),
          const SizedBox(height: 14),

          _policySection(
            icon: Icons.view_in_ar_outlined,
            iconColor: const Color(0xFF4A7C59),
            title: 'AR Data Policy',
            body:
                'All augmented reality features, including room scanning and furniture placement, operate locally on your device. No spatial mapping data, room images, or measurement results are ever uploaded, stored, or shared.\n\nAR previews are for visualization purposes only. Actual product dimensions and colors may vary slightly from what is displayed on screen.',
          ),
          const SizedBox(height: 14),

          _policySection(
            icon: Icons.shopping_bag_outlined,
            iconColor: const Color(0xFF8B6914),
            title: 'Returns & Refunds',
            body:
                'We offer a 30-day return policy on all physical furniture purchases. Items must be unused, unassembled, and returned in their original packaging with proof of purchase.\n\nDigital features such as AR access and in-app customization tools are non-refundable once activated. Custom-order items are final sale and cannot be returned unless damaged upon delivery.',
          ),
          const SizedBox(height: 14),

          _policySection(
            icon: Icons.local_shipping_outlined,
            iconColor: const Color(0xFF4A7C59),
            title: 'Shipping Policy',
            body:
                'Standard delivery takes 5–10 business days within Egypt. Express delivery (2–3 days) is available for an additional fee. White-glove assembly service is available in Cairo, Giza, and Alexandria.\n\nFree delivery applies to all orders above EGP 5,000. Delivery fees are calculated at checkout based on your location.',
          ),
          const SizedBox(height: 14),

          _policySection(
            icon: Icons.gavel_outlined,
            iconColor: const Color(0xFF3D4A6B),
            title: 'Terms of Service',
            body:
                'By using this application you agree to our terms. All content, including 3D models, product images, and designs, is the intellectual property of Furnit and may not be reproduced without written consent.\n\nWe reserve the right to update these terms at any time. Continued use of the app after changes constitutes acceptance of the revised terms.',
          ),
          const SizedBox(height: 14),

          _policySection(
            icon: Icons.shield_outlined,
            iconColor: const Color(0xFF8B6914),
            title: 'Data Security',
            body:
                'Your account data is encrypted in transit using TLS 1.3 and stored on secure, access-controlled servers. We regularly audit our systems for vulnerabilities.\n\nYou can request deletion of your account and all associated data at any time by contacting support@furnit.app. We will process deletion requests within 30 days.',
          ),
          const SizedBox(height: 32),

          // Footer note
          Center(
            child: Text(
              'Questions? Contact us at support@furnit.app',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _policySection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String body,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        title: Text(title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF2C2416))),
        children: [
          Text(body,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.7)),
        ],
      ),
    );
  }
}