import 'package:flutter/material.dart';


import '../widget/product_image_section.dart';
import '../widget/product_info_section.dart';
import '../widget/color_selector.dart';
import '../widget/try_in_room_button.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      
      backgroundColor: Color(0xFFF6F0E9), 
      body: SingleChildScrollView(
        //padding: EdgeInsets.only(bottom: 20), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductImageSection(), 
            ProductInfoSection(), 
            ColorSelector(),
            TryInRoomButton(), 
          ],
        ),
      ),
    );
  }
}