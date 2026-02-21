enum NotificationType { order, message }

class NotificationItem {
  final String id;
  final NotificationType type;
  final String text;
  final String time;
  final bool isUnread;

  const NotificationItem({
    required this.id,
    required this.type,
    required this.text,
    required this.time,
    this.isUnread = false,
  });
}