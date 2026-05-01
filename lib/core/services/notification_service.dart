import 'package:flutter/material.dart';
import '../models/app_notification.dart';
import '../storage/token_storage.dart';
import 'notifications_store.dart';

class NotificationService {
  NotificationService({
    required GlobalKey<NavigatorState> navigatorKey,
    required TokenStorage tokenStorage,
  }) : _navigatorKey = navigatorKey,
       _tokenStorage = tokenStorage;

  final GlobalKey<NavigatorState> _navigatorKey;
  final TokenStorage _tokenStorage;

  Future<void> init() async {
    NotificationsStore.instance.seedDemoNotifications();
  }

  Future<void> syncFcmTokenToBackend({String? currentToken}) async {
    final token = currentToken;
    if (token != null && token.isNotEmpty) {
      await _tokenStorage.saveFcmToken(token);
    }
  }

  Future<void> removeFcmTokenFromBackend() async {
    await _tokenStorage.clearFcmToken();
  }

  void pushLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic> data = const <String, dynamic>{},
  }) {
    NotificationsStore.instance.addNotification(
      AppNotification(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: title,
        body: body,
        data: Map<String, dynamic>.from(data),
        receivedAt: DateTime.now(),
      ),
    );
  }

  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;
}
