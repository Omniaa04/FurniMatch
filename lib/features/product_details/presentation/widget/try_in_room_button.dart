// lib/features/product_details/presentation/widget/try_in_room_button.dart

import 'package:flutter/material.dart';

class TryInRoomButton extends StatelessWidget {
  const TryInRoomButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: SizedBox(
        width: double.infinity, 
        height: 50, 
        child: ElevatedButton.icon(
          onPressed: () {
           
          },
          
          icon: const Icon(Icons.view_in_ar, color: Colors.white),
         
          label: const Text(
            'Try in My Room',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7D533D), 
            shape: const StadiumBorder(), 
            elevation: 0, 
          ),
        ),
      ),
    );
  }
}