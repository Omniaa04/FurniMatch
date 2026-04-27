import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/datasources/chat_local_datasource.dart';
import '../../data/datasources/chat_remote_datasource.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/usecases/clear_messages.dart';
import '../../domain/usecases/load_messages.dart';
import '../../domain/usecases/save_messages.dart';
import '../../domain/usecases/send_ai_message.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/input_bar.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();

  late final LoadMessages loadMessagesUseCase;
  late final SaveMessages saveMessagesUseCase;
  late final ClearMessages clearMessagesUseCase;
  late final SendAiMessage sendAiMessageUseCase;

  List<ChatMessage> messages = [];
  bool isLoading = false;

  XFile? pendingImage;
  Uint8List? pendingImageBytes;

  @override
  void initState() {
    super.initState();

    final repository = ChatRepositoryImpl(
      localDataSource: ChatLocalDataSource(),
      remoteDataSource: ChatRemoteDataSource(),
    );

    loadMessagesUseCase = LoadMessages(repository);
    saveMessagesUseCase = SaveMessages(repository);
    clearMessagesUseCase = ClearMessages(repository);
    sendAiMessageUseCase = SendAiMessage(repository);

    loadMessages();
  }

  List<ChatMessage> defaultWelcomeMessage() {
    return [
      ChatMessage(
        text: "Hello! I'm your AI Furniture Assistant.\nHow can I help you today?",
        isUser: false,
      ),
    ];
  }

  Future<void> loadMessages() async {
    try {
      final loadedMessages = await loadMessagesUseCase();

      setState(() {
        messages = loadedMessages.isEmpty
            ? defaultWelcomeMessage()
            : loadedMessages;
      });

      if (loadedMessages.isEmpty) {
        await saveMessagesUseCase(messages);
      }
    } catch (_) {
      setState(() {
        messages = defaultWelcomeMessage();
      });

      await saveMessagesUseCase(messages);
    }

    scrollToBottom();
  }

  Future<void> clearChat() async {
    setState(() {
      messages = defaultWelcomeMessage();
      pendingImage = null;
      pendingImageBytes = null;
    });

    await clearMessagesUseCase(messages);

    scrollToBottom();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Chat cleared"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void clearPendingImage() {
    setState(() {
      pendingImage = null;
      pendingImageBytes = null;
    });
  }

  Future<void> sendMessage() async {
    final text = controller.text.trim();
    final selectedImage = pendingImage;
    final selectedImageBytes = pendingImageBytes;

    if (text.isEmpty && selectedImage == null) return;

    setState(() {
      messages.add(
        ChatMessage(
          text: text,
          isUser: true,
          imageBase64: selectedImageBytes != null
              ? base64Encode(selectedImageBytes)
              : null,
        ),
      );

      isLoading = true;
      controller.clear();
      pendingImage = null;
      pendingImageBytes = null;
    });

    await saveMessagesUseCase(messages);
    scrollToBottom();

    try {
      final aiResponse = await sendAiMessageUseCase(
        text: text,
        imageBytes: selectedImageBytes,
        imageName: selectedImage?.name,
      );

      if (!mounted) return;

      setState(() {
        messages.add(
          ChatMessage(
            text: aiResponse,
            isUser: false,
          ),
        );

        isLoading = false;
      });

      await saveMessagesUseCase(messages);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        messages.add(
          ChatMessage(
            text: "Error: $e",
            isUser: false,
          ),
        );

        isLoading = false;
      });

      await saveMessagesUseCase(messages);
    }

    scrollToBottom();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    final bytes = await picked.readAsBytes();

    setState(() {
      pendingImage = picked;
      pendingImageBytes = bytes;
    });
  }

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Uint8List? decodeImage(String? imageBase64) {
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
            onPressed: clearChat,
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
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length + (isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length) {
                  return const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text("AI is thinking..."),
                  );
                }

                return ChatBubble(
                  message: messages[index],
                  imageBytes: decodeImage(messages[index].imageBase64),
                );
              },
            ),
          ),
          InputBar(
            controller: controller,
            isLoading: isLoading,
            pendingImage: pendingImage,
            pendingImageBytes: pendingImageBytes,
            onPickImage: pickImage,
            onSendMessage: sendMessage,
            onClearPendingImage: clearPendingImage,
          ),
        ],
      ),
    );
  }
}