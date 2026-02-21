import 'package:flutter/material.dart';

class LocationServicesScreen extends StatelessWidget {
  const LocationServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Logo
              Container(
                width: 140,
                height: 140,
                decoration: const BoxDecoration(
                  color: Color(0xFF8B5A3C),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on,
                  size: 70,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 50),
              // Title
              const Text(
                'Welcome to FurniMatch',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // Subtitle
              const Text(
                'Location Services',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8B5A3C),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              // Description
              Text(
                'Uses Location Services In Order To\nDetermine Proximity Of Listed Businesses\nAnd Only While You Are Using\nThe Application',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                  height: 1.8,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}