// lib/features/product_details/presentation/widget/color_selector.dart

import 'package:flutter/material.dart';

class ColorSelector extends StatelessWidget {
  const ColorSelector({super.key});

  @override
  Widget build(BuildContext context) {
    
    final List<Color> colors = [
             
     


      const Color(0xFF3430B0), 

       const Color(0xFF8D6E63), 

      
      
      const Color(0xFF989898),            
      
     
      const Color(0xFF4F4D7D), 
      
     
      const Color(0xFF000000),
     
    ];


    int selectedIndex = 1; 

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
       
          const Row(
            children: [
              Text(
                'Select Color: ',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              Text(
                'Brown',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ],
          ),
          const SizedBox(height: 10),
       
          Row(
            children: List.generate(colors.length, (index) {
              return Container(
                margin: const EdgeInsets.only(right: 12), 
                padding: const EdgeInsets.all(2), 
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  
                  border: index == selectedIndex 
                      ? Border.all(color: Colors.grey, width: 1) 
                      : null,
                ),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: colors[index],
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}