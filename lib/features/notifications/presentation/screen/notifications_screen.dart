import 'package:flutter/material.dart';
import 'package:furnimatch/features/notifications/domain/notifications_controller.dart';

class NotificationsScreen extends StatefulWidget {
  final int userId;
  final VoidCallback? onBack;

  const NotificationsScreen({
    super.key,
    required this.userId,
    this.onBack,
  });

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final NotificationsController _controller;
  static const Color _darkBrown = Color(0xFF7D533D);
  static const Color _bgColor = Color(0xFFF6F0E9);
  static const Color _fieldColor = Color(0xFFEFE9E2);
  static const Color _accent = Color(0xFFAD8B73);

  @override
  void initState() {
    super.initState();
    _controller = NotificationsController();
    _controller.addListener(_onControllerUpdate);
    _controller.loadNotifications(widget.userId);
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: _darkBrown,
                size: 22,
              ),
              onPressed: widget.onBack ?? () => Navigator.maybePop(context),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Notifications',
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: _darkBrown,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
          ],
        ),
      ),
      body: _controller.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: _darkBrown),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: _fieldColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        _buildTab('All', !_controller.showUnreadOnly),
                        _buildTab('Unread', _controller.showUnreadOnly),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Today',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: _controller.filtered.isEmpty
                      ? const Center(
                          child: Text(
                            'No notifications',
                            style: TextStyle(color: _accent),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          itemCount: _controller.filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            return _buildNotificationCard(
                                _controller.filtered[index]);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildNotificationCard(dynamic n) {
    final bool isOrder = n['type'] == 'order';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isOrder
                  ? Icons.shopping_cart_outlined
                  : Icons.chat_bubble_outline,
              size: 18,
              color: _darkBrown,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  n['text'] ?? '',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF2C2C2C),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  n['created_at'] ?? '',
                  style: TextStyle(
                    fontSize: 11,
                    color: _accent,
                  ),
                ),
              ],
            ),
          ),
          if (n['is_unread'] == true)
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 4),
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: _darkBrown,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, bool isActive) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _controller.toggleFilter(label == 'Unread'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: isActive ? _darkBrown : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : _darkBrown,
            ),
          ),
        ),
      ),
    );
  }
}
