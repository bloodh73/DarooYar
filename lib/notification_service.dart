import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/material.dart';
import 'dart:io';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // اینجا می‌توانید کد مربوط به کلیک روی اعلان را قرار دهید
      },
    );

    print('سرویس اعلان با موفقیت راه‌اندازی شد');
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    required List<int> weekDays,
    required String sound,
  }) async {
    try {
      // بررسی مجوز اعلان‌های دقیق
      bool hasPermission = await checkExactAlarmPermission();
      if (!hasPermission) {
        print('مجوز اعلان‌های دقیق وجود ندارد');
        return;
      }

      // تنظیم زمان اعلان
      final now = DateTime.now();
      final scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      // اگر زمان گذشته است، به روز بعد منتقل می‌شود
      final scheduleTime =
          scheduledDate.isBefore(now)
              ? scheduledDate.add(Duration(days: 1))
              : scheduledDate;

      // تنظیم صدای اعلان
      AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'medicine_reminder_channel',
        'یادآوری دارو',
        channelDescription: 'کانال اعلان برای یادآوری مصرف دارو',
        importance: Importance.max,
        priority: Priority.high,
        sound: RawResourceAndroidNotificationSound(sound),
        playSound: true,
      );

      NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
      );

      // برای هر روز هفته یک اعلان جداگانه تنظیم می‌کنیم
      for (int weekDay in weekDays) {
        int daysToAdd = (weekDay - now.weekday) % 7;
        if (daysToAdd == 0 && scheduledDate.isBefore(now)) {
          daysToAdd = 7;
        }

        final dayScheduleTime = tz.TZDateTime.from(
          scheduleTime.add(Duration(days: daysToAdd)),
          tz.local,
        );

        // ایجاد شناسه منحصر به فرد برای هر اعلان در محدوده مجاز 32 بیتی
        final notificationId = (id * 10 + weekDay) % 100000;

        await _notifications.zonedSchedule(
          notificationId,
          title,
          body,
          dayScheduleTime,
          platformDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
    } catch (e) {
      print('خطا در تنظیم اعلان: $e');
      rethrow; // انتشار خطا برای مدیریت در لایه بالاتر
    }
  }

  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  static Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'medicine_reminder_channel',
      'یادآوری دارو',
      channelDescription: 'کانال اعلان برای یادآوری مصرف دارو',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(id, title, body, platformDetails);

    print('اعلان فوری با موفقیت ارسال شد: $id');
  }

  static Future<bool> requestExactAlarmPermission() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
          FlutterLocalNotificationsPlugin()
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      // بررسی آیا مجوز اعلان‌های دقیق وجود دارد
      final bool? hasPermission =
          await androidPlugin?.canScheduleExactNotifications();

      if (hasPermission != true) {
        // درخواست مجوز اعلان‌های دقیق
        await androidPlugin?.requestExactAlarmsPermission();
        return false;
      }
      return true;
    }
    return true; // در پلتفرم‌های دیگر نیازی به مجوز خاصی نیست
  }

  static Future<bool> checkExactAlarmPermission() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
          FlutterLocalNotificationsPlugin()
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      final bool? hasPermission =
          await androidPlugin?.canScheduleExactNotifications();
      return hasPermission ?? false;
    }
    return true; // در پلتفرم‌های دیگر نیازی به مجوز خاصی نیست
  }
}
