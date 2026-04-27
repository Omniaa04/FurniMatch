import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PendingImagePreview extends StatelessWidget {
  final XFile? pendingImage;
  final Uint8List? pendingImageBytes;
  final bool isLoading;
  final VoidCallback onClearPendingImage;

  const PendingImagePreview({
    super.key,
    required this.pendingImage,
    required this.pendingImageBytes,
    required this.isLoading,
    required this.onClearPendingImage,
  });

  @override
  Widget build(BuildContext context) {
    if (pendingImageBytes == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              pendingImageBytes!,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              pendingImage?.name ?? 'Selected image',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.brown.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed: isLoading ? null : onClearPendingImage,
            icon: const Icon(Icons.close, color: Color(0xFF8B6354)),
          ),
        ],
      ),
    );
  }
}