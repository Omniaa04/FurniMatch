import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/splash/cubit/splash_cubit.dart';
import 'features/splash/presentation/splash_screen.dart';

import 'features/onboarding/presentation/pages/onboarding_screen.dart';

import 'features/home/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FurniMatch',

      theme: ThemeData(
        primaryColor: const Color(0xFFCF8D5B),
      ),

      /// البداية = Splash
      home: BlocProvider(
        create: (_) => SplashCubit(prefs: prefs),
        child: const SplashScreen(),
      ),

      /// Navigation
      routes: {
        '/onboarding': (_) => const OnboardingScreen(),
        '/home': (_) => const Home(),
      },
    );
  }
}