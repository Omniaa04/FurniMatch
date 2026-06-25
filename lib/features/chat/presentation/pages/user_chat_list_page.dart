import 'package:flutter/material.dart';
import 'package:furnimatch/features/chat/data/models/chat_repository.dart';
import 'package:furnimatch/features/chat/presentation/pages/user_chat_page.dart';
import 'package:furnimatch/shared/widgets/app_dialog.dart';

class UserChatListPage extends StatefulWidget {
  final int currentUserId;
  final String? userName;
  final ValueChanged<int>? onUnreadCountChanged;
  final VoidCallback? onBackToHome;

  const UserChatListPage({
    super.key,
    required this.currentUserId,
    this.userName,
    this.onUnreadCountChanged,
    this.onBackToHome,
  });

  @override
  State<UserChatListPage> createState() => _UserChatListPageState();
}

class _UserChatListPageState extends State<UserChatListPage> {
  // ── Colors ──
  static const Color _bgColor = Color(0xFFF6F0E9);
  static const Color _darkBrown = Color(0xFF7D533D);
  // ── State ──
  final _repo = ChatRepository();
  int _selectedTab = 0;
  int _unreadCount = 0;
  List<ChatPreview> _chats = [];
  List<ShopPreview> _shops = [];
  bool _isLoadingChats = true;
  bool _isLoadingShops = false;

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  // ── Data ──

  Future<void> _loadChats() async {
    setState(() => _isLoadingChats = true);
    try {
      final results = await Future.wait([
        _repo.fetchUserChats(widget.currentUserId),
        _repo.fetchUnreadCount(widget.currentUserId),
      ]);
      if (!mounted) return;
      setState(() {
        _chats = results[0] as List<ChatPreview>;
        _unreadCount = results[1] as int;
      });
      widget.onUnreadCountChanged?.call(_unreadCount);
    } catch (_) {}
    if (mounted) setState(() => _isLoadingChats = false);
  }

  Future<void> _loadShops() async {
    if (_shops.isNotEmpty) return;
    setState(() => _isLoadingShops = true);
    try {
      final shops = await _repo.fetchAllShops();
      if (mounted) setState(() => _shops = shops);
    } catch (_) {}
    if (mounted) setState(() => _isLoadingShops = false);
  }

  Future<void> _deleteChat(ChatPreview chat) async {
    final confirmed = await _showDeleteDialog(chat.storeName);
    if (confirmed != true) return;

    await _repo.deleteChat(
      storeId: chat.storeId,
      userId: widget.currentUserId,
    );
    _loadChats();
  }

  Future<void> _openChat(ChatPreview chat) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserChatDetailsPage(
          currentUserId: widget.currentUserId,
          storeId: chat.storeId,
          storeName: chat.storeName,
          sellerUserId: chat.sellerUserId,
          userName: widget.userName,
        ),
      ),
    );
    _loadChats();
  }

  Future<void> _openShopChat(ShopPreview shop) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserChatDetailsPage(
          currentUserId: widget.currentUserId,
          storeId: shop.id,
          storeName: shop.storeName,
          sellerUserId: shop.userId,
          userName: widget.userName,
        ),
      ),
    );
    _loadChats();
  }

  void _onRefresh() {
    if (_selectedTab == 0) {
      _loadChats();
    } else {
      setState(() => _shops.clear());
      _loadShops();
    }
  }

  void _onTabChanged(int index) {
    setState(() => _selectedTab = index);
    if (index == 1) {
      _loadShops();
    } else {
      _loadChats();
    }
  }

  // ── Dialogs ──

  Future<bool?> _showDeleteDialog(String storeName) {
    return AppDialog.confirm(
      context: context,
      title: 'Delete Chat',
      message: 'Remove conversation with $storeName?',
      icon: Icons.delete_outline,
      cancelText: 'Cancel',
      confirmText: 'Delete',
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
          onPressed: widget.onBackToHome ?? () => Navigator.pop(context),
        ),
        title: const Text(
          'Chats',
          style: TextStyle(color: _darkBrown, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: _darkBrown),
            onPressed: _onRefresh,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _TabButton(
                  label: 'Chats',
                  active: _selectedTab == 0,
                  onTap: () => _onTabChanged(0),
                ),
                const SizedBox(width: 10),
                _TabButton(
                  label: 'All Shops',
                  active: _selectedTab == 1,
                  onTap: () => _onTabChanged(1),
                ),
              ],
            ),
          ),
          Expanded(
            child: _selectedTab == 0 ? _buildChatsList() : _buildShopsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildChatsList() {
    if (_isLoadingChats) {
      return const Center(child: CircularProgressIndicator(color: _darkBrown));
    }
    if (_chats.isEmpty) {
      return Center(
        child: Text(
          'No conversations yet.\nTap "All Shops" to start one!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _darkBrown.withValues(alpha: 0.6),
            height: 1.6,
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _chats.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final chat = _chats[i];
        return _ChatTile(
          name: chat.storeName,
          subtitle: chat.subtitle,
          hasUnread: chat.hasUnread,
          onTap: () => _openChat(chat),
          onDelete: () => _deleteChat(chat),
        );
      },
    );
  }

  Widget _buildShopsList() {
    if (_isLoadingShops) {
      return const Center(child: CircularProgressIndicator(color: _darkBrown));
    }
    if (_shops.isEmpty) {
      return Center(
        child: Text(
          'No shops available.',
          style: TextStyle(color: _darkBrown.withValues(alpha: 0.6)),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _shops.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final shop = _shops[i];
        return _ChatTile(
          name: shop.storeName,
          subtitle: 'Shop',
          hasUnread: false,
          onTap: () => _openShopChat(shop),
        );
      },
    );
  }
}

// ─── Private Widgets ─────────────────────────────────────────

class _TabButton extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF5C3317) : const Color(0xFFE5D5C5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : const Color(0xFF7D533D),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  final String name;
  final String subtitle;
  final bool hasUnread;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _ChatTile({
    required this.name,
    required this.subtitle,
    required this.hasUnread,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    const darkBrown = Color(0xFF7D533D);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFEAD9C9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 26,
              backgroundColor: Color(0xFF5C3317),
              child: Icon(Icons.storefront, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
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
}
