import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _messaging = FirebaseMessaging.instance;
  static final _localNotifications = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
  }

  static Future<void> _handleForegroundMessage(RemoteMessage msg) async {
    if (msg.notification == null) return;
    await _localNotifications.show(
      msg.hashCode,
      msg.notification!.title,
      msg.notification!.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'water_alerts',
          'Water Alerts',
          channelDescription: 'Groundwater stress notifications',
          importance: Importance.high,
          priority: Priority.high,
          color: Color(0xFF1A6E3C),
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  static Future<String?> getToken() => _messaging.getToken();
}

@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(RemoteMessage msg) async {
  // Handled by the OS notification tray
}

// Needed for Color reference without full Flutter import in background isolate
class Color {
  final int value;
  const Color(this.value);
}
