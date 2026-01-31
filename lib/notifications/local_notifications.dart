import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import '../services/firestore_paths.dart';

typedef NotificationTapHandler = Future<void> Function(Map<String, dynamic> data);

class LocalNotificationsService {
  static final FlutterLocalNotificationsPlugin plugin =
      FlutterLocalNotificationsPlugin();

  static const String highImportanceChannelId = 'high_importance_channel';
  static const String highImportanceChannelName = 'High Importance Notifications';

  static Future<void> initialize({
    required NotificationTapHandler onNotificationTap,
  }) async {
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings darwinInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
      macOS: darwinInit,
    );

    await plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        final payload = response.payload;
        if (payload == null || payload.isEmpty) return;
        try {
          final decoded = Uri.splitQueryString(payload);
          await onNotificationTap(decoded);
        } catch (e, stack) {
          debugPrint('LocalNotifications: failed to handle tap payload: $e');
          debugPrintStack(stackTrace: stack);
        }
      },
    );

    await requestPermissions();

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      highImportanceChannelId,
      highImportanceChannelName,
      description: 'Important notifications for Akademik App',
      importance: Importance.high,
    );

    await plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static Future<void> requestPermissions() async {
    if (kIsWeb) return;

    await plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    await plugin
        .resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  static Future<void> showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;

    final title =
        notification?.title ?? message.data[FirestoreAnnouncementFields.title]?.toString();
    final body = notification?.body ?? message.data['body']?.toString();
    if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) {
      return;
    }

    String? payload;
    if (message.data.isNotEmpty) {
      try {
        payload = Uri(
          queryParameters:
              message.data.map((k, v) => MapEntry(k, v.toString())),
        ).query;
      } catch (e, stack) {
        debugPrint('LocalNotifications: failed to build payload: $e');
        debugPrintStack(stackTrace: stack);
      }
    }

    await plugin.show(
      (title ?? body).hashCode,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          highImportanceChannelId,
          highImportanceChannelName,
          channelDescription: 'Important notifications for Akademik App',
          importance: Importance.high,
          priority: Priority.high,
          icon: 'ic_notification',
          ticker: 'ticker',
          showWhen: true,
          autoCancel: true,
        ),
      ),
      payload: payload,
    );
  }
}
