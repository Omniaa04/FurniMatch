import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:furnimatch/features/buttom_nav/CustomBottomNav.dart';
import 'package:furnimatch/features/buttom_nav/main_shell.dart';
import 'package:furnimatch/features/chat/data/models/chat_repository.dart';

class UserChatDetailsPage extends StatefulWidget {
  final int currentUserId;
  final int storeId;
  final String storeName;
  final int sellerUserId;
  final String? userName;

  const UserChatDetailsPage({
    super.key,
    required this.currentUserId,
    required this.storeId,
    required this.storeName,
    required this.sellerUserId,
    this.userName,
  });

  @override
  State<UserChatDetailsPage> createState() => _UserChatDetailsPageState();
}

class _UserChatDetailsPageState extends State<UserChatDetailsPage> {
  // ── Colors ──
  static const Color _bgColor = Color(0xFFF6F0E9);
  static const Color _darkBrown = Color(0xFF7D533D);
  static const Color _sentBubble = Color(0xFF7D533D);
  static const Color _receivedBubble = Color(0xFFEFE9E2);
  // ── State ──
  final _repo = ChatRepository();
  final _msgController = TextEditingController();
  final _scrollController = ScrollController();

  List<ChatMessage> _messages = [];
  XFile? _pendingImage;
  Uint8List? _pendingImageBytes;
  bool _isLoading = true;
  bool _isSending = false;
  int _unreadCount = 0;

  // ── Validation ──

  bool get _isValidChat =>
      widget.currentUserId > 0 &&
      widget.storeId > 0 &&
      widget.sellerUserId > 0 &&
      widget.currentUserId != widget.sellerUserId;

  // ── Lifecycle ──

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isValidChat) {
        _showSnack(
          widget.currentUserId == widget.sellerUserId
              ? 'You are opening this chat with the same account.'
              : 'Chat data is incomplete.',
        );
      }
    });
    _loadMessages();
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ── Data ──

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);
    try {
      await _repo.markMessagesAsRead(
        storeId: widget.storeId,
        userId: widget.currentUserId,
      );
      final results = await Future.wait([
        _repo.fetchMessages(
          storeId: widget.storeId,
          userId: widget.currentUserId,
        ),
        _repo.fetchUnreadCount(widget.currentUserId),
      ]);
      if (!mounted) return;
      setState(() {
        _messages = results[0] as List<ChatMessage>;
        _unreadCount = results[1] as int;
      });
      _scrollToBottom();
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  // ── Sending ──

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty && _pendingImage == null) return;
    if (!_isValidChat) return;

    if (_pendingImage != null) {
      await _sendImageWithCaption(text);
      return;
    }

    _msgController.clear();
    _appendOptimisticMessage(text: text);
    setState(() => _isSending = true);

    final ok = await _repo.sendTextMessage(
      senderId: widget.currentUserId,
      receiverId: widget.sellerUserId,
      storeId: widget.storeId,
      text: text,
    );

    if (ok) {
      _removeOptimisticMessage(text: text);
      await _loadMessages();
    } else {
      _removeOptimisticMessage(text: text);
      _msgController.text = text;
      _showSnack('Failed to send message');
    }

    if (mounted) setState(() => _isSending = false);
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );
    if (picked == null) return;
    setState(() {
      _pendingImage = picked;
    });
    _pendingImageBytes = await picked.readAsBytes();
    setState(() {});
  }

  Future<void> _sendImageWithCaption(String text) async {
    final image = _pendingImage!;
    final bytes = _pendingImageBytes!;

    _msgController.clear();
    _appendOptimisticMessage(
        text: text, imageUrl: image.name, imageBytes: bytes);
    setState(() => _isSending = true);

    final ok = await _repo.sendImageMessage(
      senderId: widget.currentUserId,
      receiverId: widget.sellerUserId,
      storeId: widget.storeId,
      text: text,
      image: image,
      imageBytes: bytes,
    );

    _removeOptimisticMessage(text: text, imageUrl: image.name);
    _clearPendingImage();

    if (ok) {
      await _loadMessages();
    } else {
      _msgController.text = text;
      _showSnack('Failed to send image');
    }

    if (mounted) setState(() => _isSending = false);
  }

  // ── Optimistic UI ──

  void _appendOptimisticMessage({
    required String text,
    String? imageUrl,
    Uint8List? imageBytes,
  }) {
    setState(() {
      _messages.add(ChatMessage(
        senderId: widget.currentUserId,
        receiverId: widget.sellerUserId,
        storeId: widget.storeId,
        text: text,
        imageUrl: imageUrl,
        imageBytes: imageBytes,
        createdAt: DateTime.now().toIso8601String(),
        isLocal: true,
        isPending: true,
      ));
    });
    _scrollToBottom();
  }

  void _removeOptimisticMessage({required String text, String? imageUrl}) {
    final index = _messages.lastIndexWhere(
      (m) =>
          m.isLocal && m.isPending && m.text == text && m.imageUrl == imageUrl,
    );
    if (index != -1) setState(() => _messages.removeAt(index));
  }

  void _clearPendingImage() {
    setState(() {
      _pendingImage = null;
      _pendingImageBytes = null;
    });
  }

  // ── Helpers ──

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

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _handleBottomNavTap(int index) {
    MainShell.openTab(
      context,
      index: index,
      userId: widget.currentUserId,
      userName: widget.userName,
    );
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: _darkBrown),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.storeName,
          style:
              const TextStyle(color: _darkBrown, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: _darkBrown),
            onPressed: _loadMessages,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessagesList()),
          _buildInputBar(),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 1,
        inboxCount: _unreadCount,
         notifCount: 0, 
        onTap: _handleBottomNavTap,
      ),
    );
  }

  Widget _buildMessagesList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: _darkBrown));
    }
    if (_messages.isEmpty) {
      return Center(
        child: Text(
          'No messages yet. Say hi! 👋',
          style: TextStyle(color: _darkBrown.withValues(alpha: 0.5)),
        ),
      );
    }
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _messages.length,
      itemBuilder: (_, i) => _MessageBubble(
        message: _messages[i],
        currentUserId: widget.currentUserId,
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
      color: _bgColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_pendingImageBytes != null) _buildImagePreview(),
          Row(
            children: [
              GestureDetector(
                onTap: _isSending ? null : _pickImage,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                      color: Colors.transparent, shape: BoxShape.circle),
                  child: const Icon(Icons.image_outlined,
                      color: _darkBrown, size: 28),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
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
                  decoration: const BoxDecoration(
                      color: _sentBubble, shape: BoxShape.circle),
                  child: _isSending
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.send_rounded,
                          color: Colors.white, size: 22),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
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
              style: const TextStyle(
                  color: _darkBrown, fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            onPressed: _isSending ? null : _clearPendingImage,
            icon: const Icon(Icons.close, color: _darkBrown),
          ),
        ],
      ),
    );
  }
}

// ─── Private Widgets ─────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final int currentUserId;

  const _MessageBubble({
    required this.message,
    required this.currentUserId,
  });

  bool get _isMine => message.senderId == currentUserId;

  bool _isRemoteImage(String path) =>
      path.startsWith('http://') || path.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    const darkBrown = Color(0xFF7D533D);
    const sentBubble = Color(0xFF7D533D);
    const receivedBubble = Color(0xFFEFE9E2);

    return Align(
      alignment: _isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        decoration: BoxDecoration(
          color: _isMine ? sentBubble : receivedBubble,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(_isMine ? 16 : 4),
            bottomRight: Radius.circular(_isMine ? 4 : 16),
          ),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.imageUrl != null && message.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: message.imageBytes != null
                    ? Image.memory(
                        message.imageBytes!,
                        width: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image, color: Colors.grey),
                      )
                    : _isRemoteImage(message.imageUrl!)
                        ? Image.network(
                            message.imageUrl!,
                            headers: const {
                              'ngrok-skip-browser-warning': 'true'
                            },
                            width: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                                Icons.broken_image,
                                color: Colors.grey),
                          )
                        : Image.file(
                            File(message.imageUrl!),
                            width: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                                Icons.broken_image,
                                color: Colors.grey),
                          ),
              ),
            if (message.text.isNotEmpty)
              Padding(
                padding:
                    message.imageUrl != null && message.imageUrl!.isNotEmpty
                        ? const EdgeInsets.only(top: 8)
                        : EdgeInsets.zero,
                child: Text(
                  message.text,
                  style: TextStyle(
                    color: _isMine ? Colors.white : darkBrown,
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
