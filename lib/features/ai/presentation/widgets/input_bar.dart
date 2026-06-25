import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'pending_image_preview.dart';

class InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final XFile? pendingImage;
  final Uint8List? pendingImageBytes;
  final VoidCallback onPickImage;
  final VoidCallback onSendMessage;
  final VoidCallback onClearPendingImage;

  const InputBar({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.pendingImage,
    required this.pendingImageBytes,
    required this.onPickImage,
    required this.onSendMessage,
    required this.onClearPendingImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PendingImagePreview(
            pendingImage: pendingImage,
            pendingImageBytes: pendingImageBytes,
            isLoading: isLoading,
            onClearPendingImage: onClearPendingImage,
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.image, color: Color(0xFF8B6354)),
                onPressed: isLoading ? null : onPickImage,
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: pendingImage == null
                        ? "Send message..."
                        : "Write a message for this image...",
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => onSendMessage(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Color(0xFF8B6354)),
                onPressed: isLoading ? null : onSendMessage,
              ),
            ],
          ),
        ],
      ),
    );
  }
}