import 'package:flutter/material.dart';

class ColorSelector extends StatelessWidget {
  final List<dynamic> colors;
  final int selectedColorIndex;
  final ValueChanged<int> onColorSelected;

  const ColorSelector({
    super.key,
    required this.colors,
    required this.selectedColorIndex,
    required this.onColorSelected,
  });

  Color hexToColor(String hex) {
    final cleanedHex = hex.replaceAll('#', '');
    return Color(int.parse('FF$cleanedHex', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    const darkBrown = Color(0xFF8B5E3C);

    if (colors.isEmpty) {
      return Text(
        "No colors available",
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 14,
        ),
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 10,
      children: List.generate(colors.length, (index) {
        final isSelected = selectedColorIndex == index;
        final color = hexToColor(colors[index].toString());

        return GestureDetector(
          onTap: () => onColorSelected(index),
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              border: Border.all(
                color: isSelected ? darkBrown : Colors.transparent,
                width: 3,
              ),
            ),
            child: isSelected
                ? const Center(
                    child: CircleAvatar(
                      radius: 7,
                      backgroundColor: Colors.white,
                    ),
                  )
                : null,
          ),
        );
      }),
    );
  }
}
