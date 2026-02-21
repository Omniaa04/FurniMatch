import 'package:flutter/material.dart';
import '../../domain/notification_model.dart';
import '../widgets/notification_card.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _showUnreadOnly = false;

  static const List<NotificationItem> _allNotifications = [
    NotificationItem(
      id: '1',
      type: NotificationType.order,
      text:
          'Order #1203 Confirmed: Your delivery is scheduled for tomorrow between 10 AM and 2 PM.',
      time: '1 hour ago',
      isUnread: true,
    ),
    NotificationItem(
      id: '2',
      type: NotificationType.message,
      text:
          "New Message from 'Home Furniture': We are ready to accept your negotiated price offer!",
      time: 'Yesterday, 10:44m',
    ),
    NotificationItem(
      id: '3',
      type: NotificationType.order,
      text:
          'Order #1203 Confirmed: Your delivery is scheduled for tomorrow between 10 AM and 2 PM.',
      time: 'Yesterday, 9:20m',
    ),
    NotificationItem(
      id: '4',
      type: NotificationType.message,
      text:
          "New Message from 'Home Furniture': We are ready to accept your negotiated price offer!",
      time: 'Mon, 10:00m',
    ),
  ];

  List<NotificationItem> get _filtered => _showUnreadOnly
      ? _allNotifications.where((n) => n.isUnread).toList()
      : _allNotifications;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Tab Switcher ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Container(
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFEDE8E3),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  _buildTab('All', !_showUnreadOnly),
                  _buildTab('Unread', _showUnreadOnly),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Today Label ──
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

          // ── List ──
          Expanded(
            child: _filtered.isEmpty
                ? const Center(
                    child: Text(
                      'No unread notifications',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      return NotificationCard(item: _filtered[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, bool isActive) {
    return Expanded(
      child: GestureDetector(
        onTap: () =>
            setState(() => _showUnreadOnly = label == 'Unread'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFFC4845A)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }
}