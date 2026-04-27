import 'package:flutter/material.dart';
import 'package:furnimatch/features/notifications/services/notification_service.dart';

class NotificationsController extends ChangeNotifier {
  List<dynamic> notifications = [];
  bool showUnreadOnly = false;
  bool isLoading = false;

  List<dynamic> get filtered => showUnreadOnly
      ? notifications.where((n) => n['is_unread'] == true).toList()
      : notifications;

  int get unreadCount => notifications.where((n) => n['is_unread'] == true).length;

  Future<void> loadNotifications(int userId) async {
    isLoading = true;
    notifyListeners();

    notifications = await NotificationService.fetchNotifications(userId);
    await NotificationService.markAllAsRead(userId); //  mark all as read

    isLoading = false;
    notifyListeners();
  }

  void toggleFilter(bool unreadOnly) {
    showUnreadOnly = unreadOnly;
    notifyListeners();
  }
}