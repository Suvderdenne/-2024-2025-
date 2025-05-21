import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/auth_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final notifications = await AuthService.getNotifications();
      setState(() {
        _notifications = List<Map<String, dynamic>>.from(notifications);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Мэдэгдлүүдийг ачаалахад алдаа гарлаа';
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(int notificationId) async {
    try {
      final success = await AuthService.markNotificationAsRead(notificationId);
      if (success) {
        setState(() {
          final notification = _notifications.firstWhere(
            (n) => n['id'] == notificationId,
          );
          notification['read'] = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Мэдэгдлийг уншсан болгоход алдаа гарлаа'),
        ),
      );
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final success = await AuthService.markAllNotificationsAsRead();
      if (success) {
        setState(() {
          for (var notification in _notifications) {
            notification['read'] = true;
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Бүх мэдэгдлийг уншсан болгоход алдаа гарлаа'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }

    if (_notifications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text('Мэдэгдэл байхгүй байна', style: TextStyle(fontSize: 16)),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (_notifications.any((n) => !n['read'])) ...[
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _markAllAsRead,
              icon: const Icon(Icons.done_all),
              label: const Text('Бүгдийг уншсан болгох'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadNotifications,
            child: ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                final isRead = notification['read'] ?? false;
                final createdAt = DateTime.parse(notification['created_at']);

                return Dismissible(
                  key: Key(notification['id'].toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.green,
                    child: const Icon(Icons.done, color: Colors.white),
                  ),
                  onDismissed: (_) => _markAsRead(notification['id']),
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    color: isRead ? null : Colors.deepPurple.shade50,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            isRead ? Colors.grey : Colors.deepPurple,
                        child: Icon(
                          _getNotificationIcon(notification['type'] ?? ''),
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        notification['message'] ?? '',
                        style: TextStyle(
                          fontWeight:
                              isRead ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        timeago.format(createdAt, locale: 'en_short'),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      trailing:
                          !isRead
                              ? IconButton(
                                icon: const Icon(Icons.done),
                                onPressed:
                                    () => _markAsRead(notification['id']),
                              )
                              : null,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'order':
        return Icons.shopping_bag_outlined;
      case 'payment':
        return Icons.payment_outlined;
      case 'delivery':
        return Icons.local_shipping_outlined;
      case 'like':
        return Icons.favorite_outline;
      default:
        return Icons.notifications_outlined;
    }
  }
}
