import 'package:flutter/material.dart';
import 'core/app_colors.dart';
import 'photo/reference_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ───────────────────────────────────────────
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.straighten_rounded,
                    color: AppColors.secondary, size: 28),
              ),
              const SizedBox(height: 28),
              const Text(
                'Surface\nMeasure',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                  color: AppColors.textPrimary,
                  letterSpacing: -1.5,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Measure the dimensions of any wall, floor, or ceiling using just your camera.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.55,
                ),
              ),
              const Spacer(),

              // ── How it works ──────────────────────────────────────
              const _HowItWorks(),
              const SizedBox(height: 40),

              // ── CTA ───────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.camera_alt_rounded, size: 20),
                  label: const Text(
                    'Start Measuring',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ReferenceScreen(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _HowItWorks extends StatelessWidget {
  const _HowItWorks();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How it works',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 14),
        _step('1', Icons.category_rounded, 'Pick a reference',
            'Choose a known object to calibrate the scale.'),
        const SizedBox(height: 10),
        _step('2', Icons.camera_alt_rounded, 'Take a photo',
            'Photograph the surface with the reference in frame. Keep the camera as level as possible'),
        const SizedBox(height: 10),
        _step('3', Icons.touch_app_rounded, 'Mark key points',
            'Tap the reference corners, then the surface edges.'),
        const SizedBox(height: 10),
        _step('4', Icons.auto_awesome_rounded, 'Get dimensions',
            'The app calculates and displays precise measurements.'),
      ],
    );
  }

  Widget _step(String num, IconData icon, String title, String sub) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(num,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: AppColors.primary,
                )),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 2),
              Text(sub,
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}
