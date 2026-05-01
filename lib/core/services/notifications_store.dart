import 'package:flutter/foundation.dart';

import '../models/app_notification.dart';

class NotificationsStore extends ChangeNotifier {
  NotificationsStore._internal();

  static final NotificationsStore instance = NotificationsStore._internal();

  final List<AppNotification> _items = [];

  List<AppNotification> get items => List.unmodifiable(_items);

  void addNotification(AppNotification notification) {
    _items.insert(0, notification);
    notifyListeners();
  }

  void addMessage({
    required String title,
    required String body,
    Map<String, dynamic> data = const <String, dynamic>{},
  }) {
    addNotification(
      AppNotification(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: title,
        body: body,
        data: Map<String, dynamic>.from(data),
        receivedAt: DateTime.now(),
      ),
    );
  }

  void seedDemoNotifications() {
    if (_items.isNotEmpty) {
      return;
    }

    addMessage(
      title: 'New order #S-1024',
      body: '2 items need packing before 11:30 AM.',
      data: {'type': 'order', 'orderId': 'S-1024'},
    );
    addMessage(
      title: 'Low stock alert',
      body: 'Basic T-shirt / Black is down to 4 units.',
      data: {'type': 'inventory', 'sku': 'TSH-BLK-M'},
    );
    addMessage(
      title: 'Customer message',
      body: 'A buyer asked about size guide for the latest drop.',
      data: {'type': 'message', 'threadId': 'thread-78'},
    );
  }

  void removeAt(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
