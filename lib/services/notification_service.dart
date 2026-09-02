import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

/// Notification Service for local notifications & real-time message alerts
class NotificationService {
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Function(String route, Map<String, dynamic> data)? onNotificationClicked;

  /// Initialize local notification channels
  Future<void> initialize({
    Function(String route, Map<String, dynamic> data)? onSelectNotification,
  }) async {
    onNotificationClicked = onSelectNotification;

    // Initialize Local Notifications
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null && onNotificationClicked != null) {
          onNotificationClicked?.call(response.payload!, {});
        }
      },
    );
  }

  /// Show Local Heads-Up Notification Banner
  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'pyp_channel',
        'PYP Notifications',
        channelDescription: 'Updates for bookings and messages',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        id,
        title,
        body,
        details,
        payload: payload,
      );
    } catch (e) {
      debugPrint('NotificationService.showLocalNotification error: $e');
    }
  }
}
