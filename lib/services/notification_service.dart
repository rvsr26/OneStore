import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

// 🟢 BACKGROUND HANDLER (Must be outside the class, top-level)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  // 1. INITIALIZE
  Future<void> initNotifications() async {
    // Request Permission (Required for Android 13+ & iOS)
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    }

    // Get Device Token (You need this to send notifications to this specific phone)
    final fCMToken = await _firebaseMessaging.getToken();
    print('=======================================');
    print('FCM TOKEN: $fCMToken'); 
    print('=======================================');

    // Setup Local Notifications (For Foreground)
    _initLocalNotifications();

    // Handle Background Messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      if (message.notification != null) {
        _showLocalNotification(message);
      }
    });
  }

  // 2. SETUP LOCAL NOTIFICATIONS (Android/iOS)
  void _initLocalNotifications() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(initSettings);
  }

  // 3. SHOW NOTIFICATION (When App is Open)
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'high_importance_channel', // Channel ID
      'High Importance Notifications', // Channel Name
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      notificationDetails,
    );
  }
}