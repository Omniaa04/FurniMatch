import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:furnimatch/api_config.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChatScreen(),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final String? imageBase64;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.imageBase64,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
      'imageBase64': imageBase64,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'] ?? '',
      isUser: json['isUser'] ?? false,
      imageBase64: json['imageBase64'],
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<ChatMessage> _messages = [];
  bool _isLoading = false;

  XFile? _pendingImage;
  Uint8List? _pendingImageBytes;

  final String apiUrl = "${ApiConfig.baseUrl}/analyze";
  static const String chatStorageKey = "furnimatch_ai_chat_messages";

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _setDefaultWelcomeMessage() {
    _messages = [
      ChatMessage(
        text:
            "Hello! I'm your AI Furniture Assistant.\nHow can I help you today?",
        isUser: false,
      ),
    ];
  }

  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(chatStorageKey);

    if (saved == null || saved.isEmpty) {
      setState(() {
        _setDefaultWelcomeMessage();
      });
      await _saveMessages();
      _scrollToBottom();
      return;
    }

    try {
      final List<dynamic> decoded = jsonDecode(saved);

      setState(() {
        _messages = decoded
            .map((item) => ChatMessage.fromJson(item as Map<String, dynamic>))
            .toList();

        if (_messages.isEmpty) {
          _setDefaultWelcomeMessage();
        }
      });
    } catch (_) {
      setState(() {
        _setDefaultWelcomeMessage();
      });
      await _saveMessages();
    }

    _scrollToBottom();
  }

  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_messages.map((m) => m.toJson()).toList());
    await prefs.setString(chatStorageKey, encoded);
  }

  Future<void> _clearChat() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _setDefaultWelcomeMessage();
      _pendingImage = null;
      _pendingImageBytes = null;
    });

    await prefs.setString(
      chatStorageKey,
      jsonEncode(_messages.map((m) => m.toJson()).toList()),
    );

    _scrollToBottom();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Chat cleared"),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _clearPendingImage() {
    setState(() {
      _pendingImage = null;
      _pendingImageBytes = null;
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    final pendingImage = _pendingImage;
    final pendingImageBytes = _pendingImageBytes;

    if (text.isEmpty && pendingImage == null) return;

    setState(() {
      _messages.add(
        ChatMessage(
          text: text,
          isUser: true,
          imageBase64: pendingImageBytes != null
              ? base64Encode(pendingImageBytes)
              : null,
        ),
      );
      _isLoading = true;
      _controller.clear();
      _pendingImage = null;
      _pendingImageBytes = null;
    });

    await _saveMessages();
    _scrollToBottom();

    try {
      final request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers['ngrok-skip-browser-warning'] = 'true';
      request.fields['text'] = text;

      if (pendingImage != null && pendingImageBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            pendingImageBytes,
            filename: pendingImage.name,
          ),
        );
      }

      final streamedResponse =
          await request.send().timeout(const Duration(seconds: 60));

      final responseBody = await streamedResponse.stream.bytesToString();

      Map<String, dynamic> data = {};
      try {
        data = jsonDecode(responseBody);
      } catch (_) {
        data = {};
      }

      if (!mounted) return;

      setState(() {
        if (streamedResponse.statusCode == 200) {
          _messages.add(
            ChatMessage(
              text: data['response'] ?? data['error'] ?? 'No response',
              isUser: false,
            ),
          );
        } else {
          _messages.add(
            ChatMessage(
              text: data['error'] ??
                  data['message'] ??
                  "Server error: ${streamedResponse.statusCode}",
              isUser: false,
            ),
          );
        }

        _isLoading = false;
      });

      await _saveMessages();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _messages.add(
          ChatMessage(
            text: "Error: $e",
            isUser: false,
          ),
        );
        _isLoading = false;
      });

      await _saveMessages();
    }

    _scrollToBottom();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    setState(() {
      _pendingImage = picked;
      _pendingImageBytes = bytes;
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Uint8List? _decodeImage(String? imageBase64) {
    if (imageBase64 == null || imageBase64.isEmpty) return null;
    try {
      return base64Decode(imageBase64);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EDE8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5EDE8),
        elevation: 0,
        title: const Text(
          "AI Assistant",
          style: TextStyle(
            color: Colors.brown,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _clearChat,
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.brown,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text("AI is thinking..."),
                  );
                }
                return _buildMessage(_messages[index]);
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    final imageBytes = _decodeImage(message.imageBase64);

    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: message.isUser ? const Color(0xFF8B6354) : Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageBytes != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  imageBytes,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
              if (message.text.isNotEmpty) const SizedBox(height: 8),
            ],
            if (message.text.isNotEmpty)
              Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.brown.shade800,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingImagePreview() {
    if (_pendingImageBytes == null) {
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
                color: Colors.brown.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed: _isLoading ? null : _clearPendingImage,
            icon: const Icon(Icons.close, color: Color(0xFF8B6354)),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPendingImagePreview(),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.image, color: Color(0xFF8B6354)),
                onPressed: _isLoading ? null : _pickImage,
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: _pendingImage == null
                        ? "Send message..."
                        : "Write a message for this image...",
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Color(0xFF8B6354)),
                onPressed: _isLoading ? null : _sendMessage,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
