import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> onDidReceiveNotification(
      NotificationResponse notificationResponse) async {
    print("Notification receive");
  }

  static Future<void> initialize() async {
    tz.initializeTimeZones();
    String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
    debugPrint('Timezone initialized: $timeZoneName');

    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings("@mipmap/ic_launcher");
    const DarwinInitializationSettings iOSInitializationSettings =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
      iOS: iOSInitializationSettings,
    );
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotification,
      onDidReceiveBackgroundNotificationResponse: onDidReceiveNotification,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> _checkNotificationPermission() async {
    PermissionStatus status = await Permission.notification.status;

    if (status.isDenied) {
      // Request permission
      PermissionStatus newStatus = await Permission.notification.request();
      if (newStatus.isGranted) {
        if (kDebugMode) {
          print("Notification permission granted.");
        }
      } else if (newStatus.isPermanentlyDenied) {
        if (kDebugMode) {
          print(
              "Notification permission is permanently denied. Please enable it in settings.");
        }
      } else {
        if (kDebugMode) {
          print("Notification permission denied.");
        }
      }
    } else if (status.isPermanentlyDenied) {
      if (kDebugMode) {
        print(
            "Notification permission is permanently denied. Please enable it in settings.");
      }
    } else if (status.isGranted) {
      if (kDebugMode) {
        print("Notification permission is already granted.");
      }
    }
  }

  static Future<bool?> requestExactAlarmPermission() async {
    _checkNotificationPermission();
    final status = await Permission.scheduleExactAlarm.request();
    if (Platform.isAndroid && (await Permission.scheduleExactAlarm.isDenied)) {
      if (status.isGranted) {
        debugPrint('Exact alarm permission granted');
        return true;
      }
      if (status.isDenied) {
        debugPrint('Exact alarm permission denied');
        return false;
      } else if (status.isPermanentlyDenied) {
        debugPrint('Exact alarm permission permanently denied');
        // Guide user to settings
        openAppSettings();
      }
    }
    return null;
  }

  // Schedule Notification
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    final tz.TZDateTime scheduleDate =
        tz.TZDateTime.from(scheduledTime, tz.local);
    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduleDate,
        const NotificationDetails(
          iOS: DarwinNotificationDetails(),
          android: AndroidNotificationDetails(
            'task_channel',
            'Task Notifications',
            channelDescription: 'Notifications for task reminders',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      debugPrint('Notification scheduled successfully!');
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  // Cancel a notification
  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }
}
