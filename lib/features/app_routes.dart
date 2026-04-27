// lib/app_routes.dart
import 'package:flutter/material.dart';
import 'package:furnimatch/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:furnimatch/features/splash/presentation/pages/splash_screen.dart';
import 'package:furnimatch/features/buttom_nav/main_shell.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String mainShell = '/mainShell';
  static const String home = '/home'; // Keep for backward compatibility

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case mainShell:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => MainShell(
            userId: args?['userId'],
            userName: args?['userName'],
            initialIndex: args?['initialIndex'] ?? 0,
          ),
        );
      case home:
        // Fallback for backward compatibility
        return MaterialPageRoute(
          builder: (_) => MainShell(
            userId: null,
            userName: null,
            initialIndex: 0,
          ),
        );
      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}