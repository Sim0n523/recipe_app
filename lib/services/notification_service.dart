import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:math';
import '../models/meal.dart';

// Create the plugin instance globally
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling background message: ${message.messageId}');
}

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Initialize notifications
  Future<void> init() async {
    // Initialize timezone data
    tz.initializeTimeZones();

    // Request Firebase Messaging permissions
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Setup local notifications
    const AndroidInitializationSettings androidInit =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
    InitializationSettings(android: androidInit);

    await flutterLocalNotificationsPlugin.initialize(initSettings);

    // Set up background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Listen to foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showNotification(
        title: message.notification?.title ?? 'Recipe App',
        body: message.notification?.body ?? 'Check out today\'s recipe!',
      );
    });

    print('NotificationService initialized');
  }

  // Show an immediate notification
  Future<void> _showNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'recipe_channel',
      'Recipe Notifications',
      channelDescription: 'Recipe app notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details =
    NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }

  // Schedule daily reminder at specific time (e.g., 9:00 AM)
  Future<void> scheduleDailyReminder({
    int hour = 9,
    int minute = 0,
    String? mealName,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If the scheduled time has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'daily_recipe_channel',
      'Daily Recipe',
      channelDescription: 'Daily random recipe reminder',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details =
    NotificationDetails(android: androidDetails);

    final body = mealName != null
        ? 'Try $mealName today! 🍳'
        : 'Check out today\'s recipe! 🍳';

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Recipe of the Day',
      body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    print('Daily reminder scheduled for $hour:${minute.toString().padLeft(2, '0')}');
  }

  // Schedule daily reminder with a random meal from the list
  Future<void> scheduleDailyReminderWithRandomMeal({
    required List<Meal> meals,
    int hour = 9,
    int minute = 0,
  }) async {
    if (meals.isEmpty) {
      // Schedule without meal name if list is empty
      await scheduleDailyReminder(hour: hour, minute: minute);
      return;
    }

    // Pick a random meal
    final random = Random();
    final randomMeal = meals[random.nextInt(meals.length)];

    await scheduleDailyReminder(
      hour: hour,
      minute: minute,
      mealName: randomMeal.name,
    );
  }

  // Send a test notification immediately
  Future<void> sendTestNotification() async {
    await _showNotification(
      title: 'Test Notification 🍕',
      body: 'If you see this, notifications are working!',
    );
  }

  // Get FCM token (for server-side notifications)
  Future<String?> getToken() async {
    return await _messaging.getToken();
  }
}