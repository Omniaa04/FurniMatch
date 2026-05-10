import 'package:flutter/material.dart';
import 'features/RoomMeasurement/room_measurement_injector.dart';
import 'features/RoomMeasurement/presentation/screen/ar_measurement_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Room Measurement',
      home: RoomMeasurementInjector.provideBloc(
        child: const ArMeasurementScreen(),
      ),
    );
  }
}
