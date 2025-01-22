import 'package:flutter/material.dart';
import '../Pages/Notification.dart';

class NotificationService {
  static final List<NotificationItem> notifications = [];
  static final ValueNotifier<bool> hasNewNotifications = ValueNotifier<bool>(false);

  static void addNotification(String message, String priority, IconData icon) {
    notifications.insert(
      0,
      NotificationItem(
        message: message,
        timestamp: DateTime.now(),
        priority: priority,
        icon: icon,
      ),
    );
    hasNewNotifications.value = true;
  }
}