import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:skyguardmobileapp/services/fcm_api_service.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    await _requestPermission();

    await _initializeLocalNotifications();

    await _getToken();

    _listenForegroundMessages();
  }

  Future<void> _requestPermission() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('NOTIFICATION PERMISSION: ${settings.authorizationStatus}');
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(
      settings: settings,
    );
  }

  Future<void> _getToken() async {
    final token = await _firebaseMessaging.getToken();

    print('FCM TOKEN: $token');

    if (token != null) {
      await FcmApiService().saveFcmToken(
        email: 'test@gmail.com',
        fcmToken: token,
      );
    }
  }

  void _listenForegroundMessages() {
    FirebaseMessaging.onMessage.listen((message) {
      print('FOREGROUND MESSAGE RECEIVED');
      print(message.notification?.title);
      print(message.notification?.body);

      _showNotification(
        title: message.notification?.title ?? 'SkyGuard',
        body: message.notification?.body ?? 'New Notification',
      );
    });
  }

  Future<void> _showNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'skyguard_channel',
      'SkyGuard Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(
      android: androidDetails,
    );

    await _localNotifications.show(
      id: 0,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }
}