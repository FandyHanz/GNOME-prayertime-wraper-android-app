import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const int persistentId = 101;

  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    final initSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(settings: initSettings);

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  // 1. Notifikasi nempel terus (Ongoing status)
  static Future<void> showPersistentNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'prayer_persistent_channel_v2',
      'Ongoing Prayer Info',
      channelDescription: 'Status bar ongoing prayer countdown',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      ongoing: true,
      autoCancel: false,
      playSound: false,
      enableVibration: false,
      icon: '@mipmap/ic_launcher',
    );

    final details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      id: persistentId,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }

  // 2. Notifikasi pop-up alert saat waktu salat tiba (bisa diswipe)
  static Future<void> showBanner({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'prayer_alerts',
      'Prayer Alerts',
      channelDescription: 'Prayer alerts notifications',
      importance: Importance.max,
      priority: Priority.high,
      ongoing: false,
      autoCancel: true,
      playSound: false,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    final details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }

  // 3. Batalkan notifikasi tetap saat opsi dimatikan
  static Future<void> cancelPersistent() async {
    await _notifications.cancel(id: persistentId);
  }
}
