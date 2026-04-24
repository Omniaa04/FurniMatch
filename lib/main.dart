import 'package:flutter/material.dart';
import 'features/RoomMeasurement/presentation/screen/room_setup_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FurniMatch 3D',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFCF8D5B)),
        useMaterial3: true,
      ),
      home: const RoomSetupScreen(),
    );
  }
}