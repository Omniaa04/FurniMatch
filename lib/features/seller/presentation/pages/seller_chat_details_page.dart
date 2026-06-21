import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

import 'package:furnimatch/api_config.dart';

class SellerChatDetailsPage extends StatefulWidget {
  final String customerName;
  final int customerId;
  final int storeId;
  final int sellerUserId;

  const SellerChatDetailsPage({
    super.key,
    required this.customerName,
    required this.customerId,
    required this.storeId,
    required this.sellerUserId,
  });

  @override
  State<SellerChatDetailsPage> createState() => _SellerChatDetailsPageState();
}

class _SellerChatDetailsPageState extends State<SellerChatDetailsPage> {
  final Color bgColor = const Color(0xFFF6F0E9);
  final Color darkBrown = const Color(0xFF7D533D);
  final Color sentBubble = const Color(0xFF7D533D);
  final Color receivedBubble = const Color(0xFFEFE9E2);

  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _messages = [];
  XFile? _pendingImage;
  Uint8List? _pendingImageBytes;
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  MediaType _mediaTypeFromPath(String path) {
    final extension = path.split('.').last.toLowerCase();
    switch (extension) {
      case 'png':
        return MediaType('image', 'png');
      case 'webp':
        return MediaType('image', 'webp');
      case 'heic':
        return MediaType('image', 'heic');
      case 'heif':
        return MediaType('image', 'heif');
      case 'jpg':
      case 'jpeg':
      default:
        return MediaType('image', 'jpeg');
    }
  }

  void _clearPendingImage() {
    setState(() {
      _pendingImage = null;
      _pendingImageBytes = null;
    });
  }

  Future<void> _fetchMessages() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/messages/${widget.storeId}/${widget.customerId}',
        ),
        headers: {'ngrok-skip-browser-warning': 'true'},
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (data['success'] == true) {
        setState(() {
          _messages = List<Map<String, dynamic>>.from(data['messages'] ?? []);
        });
        _scrollToBottom();
      }
    } catch (_) {
      if (!mounted) return;
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);

    if (pickedFile == null) return;

    final imageBytes = await pickedFile.readAsBytes();
    setState(() {
      _pendingImage = pickedFile;
      _pendingImageBytes = imageBytes;
    });
  }

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty && _pendingImage == null) return;

    if (_pendingImage != null) {
      await _sendImageWithText();
      return;
    }

    _msgController.clear();
    setState(() => _isSending = true);

    try {
      await http.post(
        Uri.parse('${ApiConfig.baseUrl}/messages/send'),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({
          'sender_id': widget.sellerUserId,
          'receiver_id': widget.customerId,
          'store_id': widget.storeId,
          'text': text,
        }),
      );

      await _fetchMessages();
    } catch (e) {
      _showSnack('Could not send message: ${e.toString()}');
    }

    if (mounted) {
      setState(() => _isSending = false);
    }
  }

  Future<void> _sendImageWithText() async {
    final pickedFile = _pendingImage;
    final imageBytes = _pendingImageBytes;

    if (pickedFile == null || imageBytes == null) return;

    final text = _msgController.text.trim();
    _msgController.clear();
    setState(() => _isSending = true);

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/messages/send-image'),
      )
        ..fields['sender_id'] = widget.sellerUserId.toString()
        ..fields['receiver_id'] = widget.customerId.toString()
        ..fields['store_id'] = widget.storeId.toString()
        ..fields['text'] = text
        ..headers['ngrok-skip-browser-warning'] = 'true'
        ..files.add(
          http.MultipartFile.fromBytes(
            'image',
            imageBytes,
            filename: pickedFile.name,
            contentType: _mediaTypeFromPath(pickedFile.name),
          ),
        );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200 && response.statusCode != 201) {
        String errorMessage = 'Server error: ${response.statusCode}';
        try {
          final data = jsonDecode(response.body);
          errorMessage = data['message']?.toString() ?? errorMessage;
        } catch (_) {}

        _showSnack(errorMessage);
        _msgController.text = text;
        return;
      }

      _clearPendingImage();
      await _fetchMessages();
    } catch (e) {
      _msgController.text = text;
      _showSnack('Could not send image: ${e.toString()}');
    }

    if (mounted) {
      setState(() => _isSending = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: darkBrown),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.customerName,
          style: TextStyle(
            color: darkBrown,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: darkBrown),
            onPressed: _fetchMessages,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(color: darkBrown),
                  )
                : _messages.isEmpty
                    ? Center(
                        child: Text(
                          'No messages yet.',
                          style: TextStyle(
                            color: darkBrown.withValues(alpha: 0.5),
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        itemCount: _messages.length,
                        itemBuilder: (_, index) =>
                            _buildMessageBubble(_messages[index]),
                      ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    final bool isMine =
        int.tryParse(msg['sender_id'].toString()) == widget.sellerUserId;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        decoration: BoxDecoration(
          color: isMine ? sentBubble : receivedBubble,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMine ? 16 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 16),
          ),
        ),
        padding: const EdgeInsets.all(10),
        child: _buildBubbleContent(msg, isMine),
      ),
    );
  }

  Widget _buildBubbleContent(Map<String, dynamic> msg, bool isMine) {
    final String? imageUrl = msg['image_url']?.toString();
    final String text = (msg['text'] ?? '').toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (imageUrl != null && imageUrl.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: imageUrl.startsWith('http://') ||
                    imageUrl.startsWith('https://')
                ? Image.network(
                    imageUrl,
                    headers: const {'ngrok-skip-browser-warning': 'true'},
                    width: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.broken_image, color: Colors.grey),
                  )
                : Image.file(
                    File(imageUrl),
                    width: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.broken_image, color: Colors.grey),
                  ),
          ),
        if (text.isNotEmpty)
          Padding(
            padding: imageUrl != null && imageUrl.isNotEmpty
                ? const EdgeInsets.only(top: 8)
                : EdgeInsets.zero,
            child: Text(
              text,
              style: TextStyle(
                color: isMine ? Colors.white : darkBrown,
                fontSize: 14,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPendingImagePreview() {
    if (_pendingImageBytes == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFEFE9E2),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              _pendingImageBytes!,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _pendingImage?.name ?? 'Selected image',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: darkBrown,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed: _isSending ? null : _clearPendingImage,
            icon: Icon(Icons.close, color: darkBrown),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
      color: bgColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPendingImagePreview(),
          Row(
            children: [
              GestureDetector(
                onTap: _isSending ? null : _pickImage,
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(
                    Icons.image_outlined,
                    color: darkBrown,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFE9E2),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: TextField(
                    controller: _msgController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: _pendingImage == null
                          ? 'Type a message...'
                          : 'Add a caption...',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _isSending ? null : _sendMessage,
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: sentBubble,
                    shape: BoxShape.circle,
                  ),
                  child: _isSending
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
