// product_details/presentation/widget/product_image_section.dart

import 'package:flutter/material.dart';

class ProductImageSection extends StatelessWidget {
  const ProductImageSection({super.key});

  @override
  Widget build(BuildContext context) {
  
    final screenWidth = MediaQuery.of(context).size.width; 
    
    return Container(
     
      color: const Color(0xFFF5F5F5), 
      width: screenWidth,
    
      height: screenWidth * 0.9, 
      
      child: Stack(
        
        children: [
      
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(top: 50.0),
              child: Image.asset(
               
                'assets/images/sofa.webp', 
                fit: BoxFit.cover,
             
              ),
            ),
          ),
          
        
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
            ),
          ),
          
         
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.share, color: Colors.black),
              onPressed: () {
             
              },
            ),
          ),
          
         
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              
              decoration: const BoxDecoration(
            
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}