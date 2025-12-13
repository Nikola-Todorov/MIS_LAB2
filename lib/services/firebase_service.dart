
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io' show Platform;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (!kIsWeb) {
    await Firebase.initializeApp();
    print('Background message: ${message.messageId}');
  }
}

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();


  Future<String> getUserId() async {
    final auth = FirebaseAuth.instance;

    if (auth.currentUser != null) {
      return auth.currentUser!.uid;
    }

    final userCredential = await auth.signInAnonymously();

    if (userCredential.user != null) {
      return userCredential.user!.uid;
    }

    throw Exception("Firebase Auth: Failed to sign in anonymously.");
  }

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initialize() async {
    if (kIsWeb) {
      print('Running on web - notifications are limited');
      await _initializeWebMessaging();
      return;
    }

    await _initializeMobileNotifications();
  }

  Future<void> _initializeWebMessaging() async {
    try {
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      print('Web notification permission: ${settings.authorizationStatus}');

      // Get FCM token for web
      String? token = await _messaging.getToken(
        vapidKey: 'BEPyr_DsdpQ-gyhueM2MgSq4vDHi9_OUfIqJYzWhG35woT0W4gyniNRx7sYh5cIcc1nCttcMgftrnkfUPkrARBQ', // Get this from Firebase Console
      );
      print('Web FCM Token: $token');

      // Set up foreground message handler
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Web foreground message: ${message.notification?.title}');
        // Show browser notification
        _showWebNotification(message);
      });

      // Subscribe to topic
      await _messaging.subscribeToTopic('daily_recipe');
    } catch (e) {
      print('Web messaging initialization error: $e');
    }
  }

  Future<void> _initializeMobileNotifications() async {
    // Request permissions for iOS
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        print('Notification tapped: ${details.payload}');
      },
    );

    // Create notification channel for Android
    if (!kIsWeb && Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        'recipe_channel',
        'Recipe Notifications',
        description: 'Notifications for daily recipe reminders',
        importance: Importance.high,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    // Set up foreground message handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground message: ${message.notification?.title}');
      _showLocalNotification(message);
    });

    // Set up background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification opened app: ${message.messageId}');
    });

    // Get FCM token
    String? token = await _messaging.getToken();
    print('FCM Token: $token');

    // Subscribe to topic for all users
    await _messaging.subscribeToTopic('daily_recipe');
  }

  // Show web notification (uses browser's notification API)
  void _showWebNotification(RemoteMessage message) {
    print('Would show web notification: ${message.notification?.title}');
    // Browser notifications are handled by service worker
  }

  // Show local notification (mobile only)
  Future<void> _showLocalNotification(RemoteMessage message) async {
    if (kIsWeb) return;

    const androidDetails = AndroidNotificationDetails(
      'recipe_channel',
      'Recipe Notifications',
      channelDescription: 'Notifications for daily recipe reminders',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Recipe App',
      message.notification?.body ?? 'Check out today\'s recipe!',
      details,
      payload: message.data['recipe_id'],
    );
  }

  // Schedule daily notification (mobile only)
  Future<void> scheduleDailyNotification() async {
    if (kIsWeb) {
      print('Daily notifications not supported on web - use push notifications instead');
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'recipe_channel',
      'Recipe Notifications',
      channelDescription: 'Daily recipe reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Schedule notification for 10:00 AM daily
    await _localNotifications.periodicallyShow(
      0,
      'Рецепт на денот! 🍽️',
      'Отвори ја апликацијата и види го денешниот рандом рецепт!',
      RepeatInterval.daily,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // Show immediate notification
  Future<void> showNotification(String title, String body) async {
    if (kIsWeb) {
      print('Notification: $title - $body');
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'recipe_channel',
      'Recipe Notifications',
      channelDescription: 'Recipe notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
    );
  }

  // Firestore methods for favorites
  Future<void> addFavorite(String userId, Map<String, dynamic> meal) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(meal['id'])
        .set(meal);
  }

  Future<void> removeFavorite(String userId, String mealId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(mealId)
        .delete();
  }

  Stream<QuerySnapshot> getFavorites(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .snapshots();
  }

  Future<bool> isFavorite(String userId, String mealId) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(mealId)
        .get();
    return doc.exists;
  }
}