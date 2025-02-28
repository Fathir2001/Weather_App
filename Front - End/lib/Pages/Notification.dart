import 'package:flutter/material.dart';
import 'Notification_service.dart';

class NotificationItem {
  final String message;
  final DateTime timestamp;
  final String priority;
  final IconData icon;

  NotificationItem({
    required this.message,
    required this.timestamp,
    required this.priority,
    required this.icon,
  });
}

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<NotificationItem> get notifications => NotificationService.notifications;

  bool _isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 360;
  }

  void _removeNotification(int index) {
    setState(() {
      notifications.removeAt(index);
    });
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = _isSmallScreen(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        title: Text(
          'Notifications',
          style: TextStyle(
            color: Colors.white,
            fontSize: isSmall ? 18 : 20,
          ),
        ),
        actions: [
          if (notifications.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.clear_all,
                color: Colors.white,
                size: isSmall ? 22 : 24,
              ),
              onPressed: () {
                setState(() {
                  notifications.clear();
                });
              },
            ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off,
                    size: isSmall ? 48 : 64,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: isSmall ? 12 : 16),
                  Text(
                    'No notifications',
                    style: TextStyle(
                      fontSize: isSmall ? 16 : 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Dismissible(
                  key: Key('notification_$index'),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: isSmall ? 8 : 16),
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: isSmall ? 20 : 24,
                    ),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => _removeNotification(index),
                  child: Card(
                    margin: EdgeInsets.symmetric(
                      horizontal: isSmall ? 8 : 16,
                      vertical: isSmall ? 4 : 8,
                    ),
                    elevation: 2,
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isSmall ? 8 : 16,
                        vertical: isSmall ? 4 : 8,
                      ),
                      leading: CircleAvatar(
                        radius: isSmall ? 16 : 20,
                        backgroundColor:
                            _getPriorityColor(notification.priority).withOpacity(0.2),
                        child: Icon(
                          notification.icon,
                          size: isSmall ? 16 : 20,
                          color: _getPriorityColor(notification.priority),
                        ),
                      ),
                      title: Text(
                        notification.message,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: isSmall ? 14 : 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        _getTimeAgo(notification.timestamp),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: isSmall ? 12 : 14,
                        ),
                      ),
                      trailing: Wrap(
                        spacing: isSmall ? 4 : 8,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmall ? 4 : 8,
                              vertical: isSmall ? 2 : 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getPriorityColor(notification.priority)
                                  .withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              notification.priority,
                              style: TextStyle(
                                color: _getPriorityColor(notification.priority),
                                fontSize: isSmall ? 10 : 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: isSmall ? 20 : 24,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(
                              minWidth: isSmall ? 32 : 40,
                              minHeight: isSmall ? 32 : 40,
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(
                                      'Delete Notification',
                                      style: TextStyle(
                                        fontSize: isSmall ? 18 : 20,
                                      ),
                                    ),
                                    content: Text(
                                      'Are you sure you want to delete this notification?',
                                      style: TextStyle(
                                        fontSize: isSmall ? 14 : 16,
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(
                                          'Cancel',
                                          style: TextStyle(
                                            fontSize: isSmall ? 14 : 16,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          _removeNotification(index);
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          'Delete',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: isSmall ? 14 : 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}