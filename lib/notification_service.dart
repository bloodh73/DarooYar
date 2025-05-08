import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'dart:io' show Platform;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz_data.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // اینجا می‌توانید کد مربوط به کلیک روی اعلان را قرار دهید
      },
    );

    // درخواست مجوزهای لازم
    await _requestPermissions();
  }

  static Future<void> _requestPermissions() async {
    try {
      if (Platform.isAndroid) {
        // درخواست مجوز برای اندروید
        final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
            _notifications
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >();

        // درخواست مجوز اعلان‌های دقیق برای اندروید 12 و بالاتر
        await androidPlugin?.requestExactAlarmsPermission();
        await androidPlugin?.requestNotificationsPermission();
      } else if (Platform.isIOS) {
        // درخواست مجوز برای iOS
        final IOSFlutterLocalNotificationsPlugin? iosPlugin =
            _notifications
                .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin
                >();
        await iosPlugin?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      }
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
      // Continue execution even if permission request fails
    }
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    required List<int> weekDays,
    String sound = 'alarm_sound',
  }) async {
    try {
      for (int weekDay in weekDays) {
        // ایجاد شناسه منحصر به فرد در محدوده مجاز 32 بیتی
        final int notificationId = _generateUniqueId(id, weekDay, time);

        final scheduledDate = _nextInstanceOfWeekDay(weekDay, time);

        final androidDetails = AndroidNotificationDetails(
          'medicine_reminder_channel',
          'یادآوری دارو',
          channelDescription: 'اعلان‌های مربوط به یادآوری مصرف دارو',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          sound: RawResourceAndroidNotificationSound(sound),
          playSound: true,
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 500, 200, 500, 200, 500]),
          fullScreenIntent: true,
          category: AndroidNotificationCategory.alarm,
        );

        final iosDetails = DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: '$sound.aiff',
          interruptionLevel: InterruptionLevel.timeSensitive,
        );

        final notificationDetails = NotificationDetails(
          android: androidDetails,
          iOS: iosDetails,
        );

        // برای اندروید 12 و بالاتر، از روش متفاوتی استفاده می‌کنیم
        if (Platform.isAndroid) {
          // استفاده از روش جایگزین برای اندروید
          await _notifications.zonedSchedule(
            notificationId,
            title,
            body,
            tz.TZDateTime.from(scheduledDate, tz.local),
            notificationDetails,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          );
        } else {
          await _notifications.zonedSchedule(
            notificationId,
            title,
            body,
            tz.TZDateTime.from(scheduledDate, tz.local),
            notificationDetails,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          );
        }
      }
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // ایجاد شناسه منحصر به فرد در محدوده مجاز 32 بیتی
  static int _generateUniqueId(int baseId, int weekDay, TimeOfDay time) {
    // استفاده از روشی که شناسه کوچکتری تولید می‌کند
    int timeComponent = time.hour * 100 + time.minute;
    int id = ((baseId % 1000) * 1000) + (timeComponent * 10) + weekDay;

    // اطمینان از اینکه شناسه در محدوده مجاز 32 بیتی باشد
    return id % 0x7FFFFFFF; // 2^31 - 1 (حداکثر مقدار مجاز)
  }

  static DateTime _nextInstanceOfWeekDay(int weekDay, TimeOfDay time) {
    DateTime now = DateTime.now();

    // تبدیل روز هفته از فرمت ایرانی (شنبه=0) به فرمت میلادی (دوشنبه=1)
    // در فرمت میلادی: دوشنبه=1، سه‌شنبه=2، ...، یکشنبه=7
    // در فرمت ایرانی: شنبه=0، یکشنبه=1، ...، جمعه=6
    int targetWeekDay = (weekDay + 2) % 7; // تبدیل به فرمت میلادی
    if (targetWeekDay == 0) targetWeekDay = 7; // یکشنبه در فرمت میلادی 7 است

    DateTime scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    while (scheduledDate.weekday != targetWeekDay ||
        scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(Duration(days: 1));
    }

    return scheduledDate;
  }

  // روش برای نمایش صفحه تنظیمات اعلان‌ها
  static Future<void> openNotificationSettings() async {
    try {
      await _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    } catch (e) {
      debugPrint('Error opening notification settings: $e');
      // Continue execution even if opening settings fails
    }
  }
}
