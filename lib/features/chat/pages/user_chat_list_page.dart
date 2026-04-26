import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:furnimatch/api_config.dart';
import 'package:furnimatch/features/chat/pages/user_chat_page.dart';
import 'package:furnimatch/features/home/pages/home_page.dart';
import 'package:furnimatch/features/profile/pages/profile_page.dart';

class UserChatListPage extends StatefulWidget {
  final int currentUserId;
  final String? userName;

  const UserChatListPage({
    super.key,
    required this.currentUserId,
    this.userName,
  });

  @override
  State<UserChatListPage> createState() => _UserChatListPageState();
}

class _UserChatListPageState extends State<UserChatListPage> {
  final Color bgColor = const Color(0xFFF6F0E9);
  final Color darkBrown = const Color(0xFF7D533D);
  final Color cardColor = const Color(0xFFEAD9C9);
  final Color iconBg = const Color(0xFF5C3317);
  final Color selectedNavColor = const Color(0xFFEBA46E);

  int _selectedTab = 0;
  int _unreadCount = 0;

  List<Map<String, dynamic>> _userChats = [];
  bool _isLoadingChats = true;

  List<Map<String, dynamic>> _allShops = [];
  bool _isLoadingShops = false;

  @override
  void initState() {
    super.initState();
    _fetchUserChats();
    _fetchUnreadCount();
  }

  Future<void> _fetchUserChats() async {
    setState(() => _isLoadingChats = true);
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/user/${widget.currentUserId}/chats'),
        headers: {'ngrok-skip-browser-warning': 'true'},
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true && mounted) {
        setState(() {
          _userChats = List<Map<String, dynamic>>.from(data['chats'] ?? []);
        });
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _isLoadingChats = false);
    }
  }

  Future<void> _fetchUnreadCount() async {
    try {
      final response = await http.get(
        Uri.parse(
            '${ApiConfig.baseUrl}/user/${widget.currentUserId}/unread-count'),
        headers: {'ngrok-skip-browser-warning': 'true'},
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true && mounted) {
        setState(() {
          _unreadCount = data['unread_count'] ?? 0;
        });
      }
    } catch (_) {}
  }

  Future<void> _fetchAllShops() async {
    if (_allShops.isNotEmpty) return;

    setState(() => _isLoadingShops = true);
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/stores'),
        headers: {'ngrok-skip-browser-warning': 'true'},
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true && mounted) {
        setState(() {
          _allShops = List<Map<String, dynamic>>.from(data['stores'] ?? []);
        });
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _isLoadingShops = false);
    }
  }

  Future<void> _deleteChat(Map<String, dynamic> chat) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Delete Chat',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Remove conversation with ${chat['store_name']}?',
          style: TextStyle(color: darkBrown),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await http.post(
      Uri.parse('${ApiConfig.baseUrl}/messages/delete-chat'),
      headers: {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
      body: jsonEncode({
        'store_id': chat['store_id'],
        'user_id': widget.currentUserId,
      }),
    );

    _fetchUserChats();
    _fetchUnreadCount();
  }

  Future<void> _openChat({
    required int storeId,
    required String storeName,
    required int sellerUserId,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserChatDetailsPage(
          currentUserId: widget.currentUserId,
          storeId: storeId,
          storeName: storeName,
          sellerUserId: sellerUserId,
          userName: widget.userName,
        ),
      ),
    );

    _fetchUserChats();
    _fetchUnreadCount();
  }

  String _buildSubtitle(Map<String, dynamic> chat) {
    final String lastMessage = (chat['last_message'] ?? '').toString().trim();
    final bool hasImage = chat['last_message_has_image'] == true;
    final bool fromShop = chat['last_message_from_shop'] == true;

    String content = lastMessage;
    if (content.isEmpty && hasImage) {
      content = 'sent a photo';
    } else if (content.isNotEmpty && hasImage) {
      content = 'sent a photo: $content';
    } else if (content.isEmpty) {
      content = 'Open conversation';
    }

    return fromShop ? 'Shop: $content' : 'You: $content';
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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('This section is not ready yet')),
    );
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
          'Chats',
          style: TextStyle(color: darkBrown, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: darkBrown),
            onPressed: () {
              if (_selectedTab == 0) {
                _fetchUserChats();
                _fetchUnreadCount();
              } else {
                setState(() => _allShops.clear());
                _fetchAllShops();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _tabBtn('Chats', 0),
                const SizedBox(width: 10),
                _tabBtn('All Shops', 1),
              ],
            ),
          ),
          Expanded(
            child: _selectedTab == 0 ? _buildChatsList() : _buildAllShops(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _tabBtn(String label, int index) {
    final bool active = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedTab = index);
        if (index == 1) {
          _fetchAllShops();
        } else {
          _fetchUserChats();
          _fetchUnreadCount();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: active ? iconBg : const Color(0xFFE5D5C5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : darkBrown,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildChatsList() {
    if (_isLoadingChats) {
      return Center(child: CircularProgressIndicator(color: darkBrown));
    }

    if (_userChats.isEmpty) {
      return Center(
        child: Text(
          'No conversations yet.\nTap "All Shops" to start one!',
          textAlign: TextAlign.center,
          style:
              TextStyle(color: darkBrown.withValues(alpha: 0.6), height: 1.6),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _userChats.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final chat = _userChats[i];
        return _chatTile(
          name: chat['store_name'] ?? 'Shop',
          subtitle: _buildSubtitle(chat),
          storeId: chat['store_id'] ?? 0,
          sellerUserId: chat['seller_user_id'] ?? 0,
          hasUnread: chat['has_unread'] == true,
          onDelete: () => _deleteChat(chat),
        );
      },
    );
  }

  Widget _buildAllShops() {
    if (_isLoadingShops) {
      return Center(child: CircularProgressIndicator(color: darkBrown));
    }

    if (_allShops.isEmpty) {
      return Center(
        child: Text(
          'No shops available.',
          style: TextStyle(color: darkBrown.withValues(alpha: 0.6)),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _allShops.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final shop = _allShops[i];
        return _chatTile(
          name: shop['store_name'] ?? 'Shop',
          subtitle: 'Shop',
          storeId: shop['id'],
          sellerUserId: shop['user_id'] ?? 0,
          hasUnread: false,
        );
      },
    );
  }

  Widget _chatTile({
    required String name,
    required String subtitle,
    required int storeId,
    required int sellerUserId,
    required bool hasUnread,
    VoidCallback? onDelete,
  }) {
    return GestureDetector(
      onTap: () => _openChat(
        storeId: storeId,
        storeName: name,
        sellerUserId: sellerUserId,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: iconBg,
              child: const Icon(
                Icons.storefront,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: darkBrown,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: hasUnread
                          ? darkBrown
                          : darkBrown.withValues(alpha: 0.6),
                      fontSize: 13,
                      fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            if (hasUnread)
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(right: 8),
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
              ),
            if (onDelete != null)
              IconButton(
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                  size: 22,
                ),
              ),
          ],
        ),
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
        selectedItemColor: selectedNavColor,
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
