// ============================================================
// user_chat_details_page.dart
//
// صفحة المحادثة من طرف الـ User مع Shop معين.
// بتعرض:
//   - التاريخ الكامل للمحادثة (رسائل نص + صور)
//   - حقل كتابة رسالة مع زر إرسال صورة
// API endpoints المستخدمة:
//   GET  /messages/<store_id>/<user_id>  → جلب الرسائل
//   POST /messages/send                  → إرسال رسالة نص
//   POST /messages/send-image            → إرسال صورة مع نص اختياري
// ============================================================

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:furnimatch/api_config.dart';
import 'package:furnimatch/features/home/pages/home_page.dart';
import 'package:furnimatch/features/profile/pages/profile_page.dart';

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
  // ألوان التطبيق
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
  int _unreadCount = 0;

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _messageText(Map<String, dynamic> msg) {
    final dynamic rawText =
        msg['text'] ?? msg['message'] ?? msg['content'] ?? msg['body'];
    return rawText?.toString() ?? '';
  }

  String? _messageImageUrl(Map<String, dynamic> msg) {
    final dynamic rawImage =
        msg['image_url'] ?? msg['image'] ?? msg['imageUrl'];
    final imageUrl = rawImage?.toString();
    if (imageUrl == null || imageUrl.isEmpty) return null;
    return imageUrl;
  }

  bool _isRemoteImage(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
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

  Map<String, dynamic> _normalizeMessage(Map<String, dynamic> msg) {
    return {
      ...msg,
      'text': _messageText(msg),
      'image_url': _messageImageUrl(msg),
    };
  }

  void _clearPendingImage() {
    setState(() {
      _pendingImage = null;
      _pendingImageBytes = null;
    });
  }

  void _appendLocalMessage({
    required String text,
    String? imageUrl,
    Uint8List? imageBytes,
    bool isPending = false,
  }) {
    final now = DateTime.now().toIso8601String();
    setState(() {
      _messages.add({
        'sender_id': widget.currentUserId,
        'receiver_id': widget.sellerUserId,
        'store_id': widget.storeId,
        'text': text,
        'image_url': imageUrl,
        'image_bytes': imageBytes,
        'created_at': now,
        'is_local': true,
        'is_pending': isPending,
      });
    });
    _scrollToBottom();
  }

  void _removePendingLocalMessage({
    required String text,
    String? imageUrl,
  }) {
    final index = _messages.lastIndexWhere(
      (message) =>
          message['is_local'] == true &&
          message['is_pending'] == true &&
          message['text'] == text &&
          message['image_url'] == imageUrl,
    );
    if (index == -1) return;

    setState(() {
      _messages.removeAt(index);
    });
  }

  bool _hasValidChatIds() {
    return widget.currentUserId > 0 &&
        widget.storeId > 0 &&
        widget.sellerUserId > 0;
  }

  bool _hasDistinctParticipants() {
    return widget.currentUserId != widget.sellerUserId;
  }

  bool _validateChatSetup({bool showMessage = true}) {
    if (!_hasValidChatIds()) {
      if (showMessage) {
        _showSnack(
          'Chat data is incomplete. user=${widget.currentUserId}, store=${widget.storeId}, seller=${widget.sellerUserId}',
        );
      }
      debugPrint(
        '🔴 INVALID CHAT IDS: user=${widget.currentUserId}, store=${widget.storeId}, seller=${widget.sellerUserId}',
      );
      return false;
    }

    if (!_hasDistinctParticipants()) {
      if (showMessage) {
        _showSnack(
          'You are opening this chat with the same account. Please log in as a different user account.',
        );
      }
      debugPrint(
        '🔴 SAME USER AND SELLER IDS: user=${widget.currentUserId}, seller=${widget.sellerUserId}',
      );
      return false;
    }

    return true;
  }

  Future<http.Response> _postTextMessage(String text) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/messages/send');
    final payload = {
      'sender_id': widget.currentUserId.toString(),
      'receiver_id': widget.sellerUserId.toString(),
      'store_id': widget.storeId.toString(),
      'text': text,
    };

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response;
      }

      debugPrint(
        '🟠 JSON SEND FAILED, TRYING FORM. STATUS=${response.statusCode}, BODY=${response.body}',
      );
    } catch (e) {
      debugPrint('🟠 JSON SEND EXCEPTION, TRYING FORM: $e');
    }

    return http.post(
      uri,
      headers: {
        'ngrok-skip-browser-warning': 'true',
      },
      body: payload,
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _validateChatSetup();
    });
    _fetchMessages();
    _fetchUnreadCount();
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ─── جلب الرسائل ─────────────────────────────────────────
  Future<void> _fetchMessages() async {
    setState(() => _isLoading = true);
    try {
      await _markMessagesAsRead();
      await _fetchUnreadCount();
      final url =
          '${ApiConfig.baseUrl}/messages/${widget.storeId}/${widget.currentUserId}';
      debugPrint('🔵 FETCH MESSAGES URL: $url');
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      );
      debugPrint('🔵 FETCH MESSAGES STATUS: ${response.statusCode}');
      debugPrint('🔵 FETCH MESSAGES BODY: ${response.body}');
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final fetchedMessages = List<Map<String, dynamic>>.from(
          data['messages'] ?? const [],
        ).map(_normalizeMessage).toList();
        setState(() {
          _messages = fetchedMessages;
        });
        debugPrint('🟢 MESSAGES COUNT: ${_messages.length}');
        _scrollToBottom();
      } else {
        debugPrint('🔴 FETCH FAILED: $data');
      }
    } catch (e) {
      debugPrint('🔴 FETCH EXCEPTION: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _markMessagesAsRead() async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/messages/mark-read'),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({
          'store_id': widget.storeId,
          'user_id': widget.currentUserId,
        }),
      );
      debugPrint('🟤 MARK READ STATUS: ${response.statusCode}');
      debugPrint('🟤 MARK READ BODY: ${response.body}');
    } catch (e) {
      debugPrint('🔴 MARK READ EXCEPTION: $e');
    }
  }

  Future<void> _fetchUnreadCount() async {
    try {
      final response = await http.get(
        Uri.parse(
            '${ApiConfig.baseUrl}/user/${widget.currentUserId}/unread-count'),
        headers: {
          'ngrok-skip-browser-warning': 'true',
        },
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true && mounted) {
        setState(() {
          _unreadCount = data['unread_count'] ?? 0;
        });
      }
    } catch (e) {
      debugPrint('Unread count error: $e');
    }
  }

  // ─── إرسال رسالة نص فقط ──────────────────────────────────
  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty && _pendingImage == null) return;
    if (!_validateChatSetup()) {
      return;
    }
    if (_pendingImage != null) {
      await _sendImageWithText();
      return;
    }
    _msgController.clear();
    _appendLocalMessage(text: text, isPending: true);
    setState(() => _isSending = true);

    try {
      final url = '${ApiConfig.baseUrl}/messages/send';
      debugPrint('🔵 SENDING TO URL: $url');
      debugPrint(
        '🔵 SENDING DATA: sender_id=${widget.currentUserId}, receiver_id=${widget.sellerUserId}, store_id=${widget.storeId}, text=$text',
      );

      final res = await _postTextMessage(text);

      debugPrint('🔵 RESPONSE STATUS: ${res.statusCode}');
      debugPrint('🔵 RESPONSE BODY: ${res.body}');

      if (res.statusCode == 200 || res.statusCode == 201) {
        dynamic data;
        try {
          data = jsonDecode(res.body);
        } catch (_) {
          data = null;
        }

        final bool isSuccess =
            data is Map<String, dynamic> ? data['success'] != false : true;

        if (isSuccess) {
          _removePendingLocalMessage(text: text);
          await _fetchMessages();
        } else {
          _removePendingLocalMessage(text: text);
          _msgController.text = text;
          _showSnack(data['message']?.toString() ?? 'Failed to send message');
          debugPrint('🔴 SEND FAILED LOGICALLY: $data');
        }
      } else {
        _removePendingLocalMessage(text: text);
        _msgController.text = text;
        _showSnack('Server error: ${res.statusCode}');
        debugPrint('🔴 SERVER ERROR: ${res.body}');
      }
    } catch (e) {
      _removePendingLocalMessage(text: text);
      _msgController.text = text;
      _showSnack('Could not send message: ${e.toString()}');
      debugPrint('🔴 SEND EXCEPTION: $e');
      debugPrint('🔴 EXCEPTION DETAILS: ${e.toString()}');
    }

    if (mounted) {
      setState(() => _isSending = false);
    }
  }

  // ─── إرسال صورة + نص اختياري ─────────────────────────────
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

  Future<void> _sendImageWithText() async {
    final pickedFile = _pendingImage;
    final imageBytes = _pendingImageBytes;
    if (pickedFile == null || imageBytes == null) return;
    if (!_validateChatSetup()) {
      return;
    }

    final text = _msgController.text.trim();

    _msgController.clear();

    _appendLocalMessage(
      text: text,
      imageUrl: pickedFile.name,
      imageBytes: imageBytes,
      isPending: true,
    );
    setState(() => _isSending = true);

    try {
      final imageMediaType = _mediaTypeFromPath(pickedFile.name);
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/messages/send-image'),
      )
        ..fields['sender_id'] = widget.currentUserId.toString()
        ..fields['receiver_id'] = widget.sellerUserId.toString()
        ..fields['store_id'] = widget.storeId.toString()
        ..fields['text'] = text
        ..headers['ngrok-skip-browser-warning'] = 'true'
        ..files.add(http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: pickedFile.name,
          contentType: imageMediaType,
        ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      debugPrint('🟣 SEND IMAGE STATUS: ${response.statusCode}');
      debugPrint('🟣 SEND IMAGE BODY: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        _removePendingLocalMessage(text: text, imageUrl: pickedFile.name);
        _clearPendingImage();
        await _fetchMessages();
      } else {
        _removePendingLocalMessage(text: text, imageUrl: pickedFile.name);
        _msgController.text = text;
        String errorMessage = 'Server error: ${response.statusCode}';
        try {
          final data = jsonDecode(response.body);
          errorMessage = data['message']?.toString() ?? errorMessage;
        } catch (_) {}
        _showSnack(errorMessage);
      }
    } catch (e) {
      _removePendingLocalMessage(text: text, imageUrl: pickedFile.name);
      _msgController.text = text;
      _showSnack('Could not send image: ${e.toString()}');
      debugPrint('🔴 SEND IMAGE EXCEPTION: $e');
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

  void _handleBottomNavTap(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            userId: widget.currentUserId,
            userName: widget.userName,
          ),
        ),
      );
      return;
    }

    if (index == 1) {
      Navigator.pop(context);
      return;
    }

    if (index == 5) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MyProfilePage(
            userId: widget.currentUserId,
            currentName: widget.userName ?? '',
          ),
        ),
      );
      return;
    }

    _showSnack('This section is not ready yet');
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
          widget.storeName,
          style: TextStyle(color: darkBrown, fontWeight: FontWeight.w600),
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
          // ─── قائمة الرسائل ──────────────────────────────
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: darkBrown))
                : _messages.isEmpty
                    ? Center(
                        child: Text(
                          'No messages yet. Say hi! 👋',
                          style: TextStyle(
                              color: darkBrown.withValues(alpha: 0.5)),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        itemCount: _messages.length,
                        itemBuilder: (_, i) =>
                            _buildMessageBubble(_messages[i]),
                      ),
          ),

          // ─── حقل الإرسال ────────────────────────────────
          _buildInputBar(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ─── فقاعة الرسالة (تدعم صورة + نص معاً) ─────────────────
  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    final bool isMine =
        int.tryParse(msg['sender_id'].toString()) == widget.currentUserId;
    final String? imageUrl = _messageImageUrl(msg);
    final Uint8List? imageBytes = msg['image_bytes'] as Uint8List?;
    final String text = _messageText(msg);

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // عرض الصورة إذا وجدت
            if (imageUrl != null && imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: imageBytes != null
                    ? Image.memory(
                        imageBytes,
                        width: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image, color: Colors.grey),
                      )
                    : _isRemoteImage(imageUrl)
                        ? Image.network(
                            imageUrl,
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
                            File(imageUrl),
                            width: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                                Icons.broken_image,
                                color: Colors.grey),
                          ),
              ),
            // عرض النص إذا وجد
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
        ),
      ),
    );
  }

  // ─── شريط الإرسال ────────────────────────────────────────
  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
      color: bgColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_pendingImageBytes != null)
            Container(
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
            ),
          Row(
            children: [
              GestureDetector(
                onTap: _isSending ? null : _pickImage,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                      color: Colors.transparent, shape: BoxShape.circle),
                  child: Icon(Icons.image_outlined, color: darkBrown, size: 28),
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
                  decoration: BoxDecoration(
                    color: sentBubble,
                    shape: BoxShape.circle,
                  ),
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

  Widget _buildBottomNav() {
    return Container(
      height: 75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: BottomNavigationBar(
        currentIndex: 1,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: const Color(0xFFEBA46E),
        unselectedItemColor: Colors.grey,
        onTap: _handleBottomNavTap,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.chat_outlined),
                if (_unreadCount > 0)
                  Positioned(
                    right: -6,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        _unreadCount > 9 ? '9+' : '$_unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Inbox',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none),
            label: 'Notifications',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.view_in_ar),
            label: '3D model',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Cart',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
