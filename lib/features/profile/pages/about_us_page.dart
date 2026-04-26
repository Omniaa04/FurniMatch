import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: const Icon(
                      Icons.chevron_left,
                      color: Color(0xFF5C3A1E),
                      size: 28,
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'About Us',
                        style: TextStyle(
                          color: Color(0xFF5C3A1E),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 28),
                ],
              ),

              const SizedBox(height: 24),

              // Hero Image Section
              Center(
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0E4D0),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Stack(
                    children: [
                      Positioned(
                        top: -20,
                        left: -20,
                        child: Container(
                          width: 220,
                          height: 220,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEDD9B8),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          width: 220,
                          height: 150,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8D5B7),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.weekend_outlined,
                            size: 80,
                            color: Color(0xFFB89070),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Our Mission Card
              _InfoCard(
                title: 'Our Mission:',
                child: const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'To Make Furniture Trading Simple, Sustainable, And Stylish'
                    'Helping People Refresh Their Spaces While Reducing Waste.',
                    style: TextStyle(
                      color: Color(0xFF5C3A1E),
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Our Promise Card
              _InfoCard(
                title: 'Our Promise:',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SizedBox(height: 10),
                    _PromiseItem(emoji: '🪑', text: 'Safe Transactions'),
                    SizedBox(height: 8),
                    _PromiseItem(emoji: '🎁', text: 'Verified Buyers And Sellers'),
                    SizedBox(height: 8),
                    _PromiseItem(
                        emoji: '💬',
                        text: 'Friendly Community And Easy Communication'),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _InfoCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5C3A1E).withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF5C3A1E),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _PromiseItem extends StatelessWidget {
  final String emoji;
  final String text;

  const _PromiseItem({required this.emoji, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF5C3A1E),
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}