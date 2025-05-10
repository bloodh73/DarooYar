import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/material.dart';
import 'dart:io';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static bool _permissionRequestInProgress = false;

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
        await requestExactAlarmPermission();
        return;
      }

      // لغو اعلان‌های قبلی با همین شناسه
      for (int i = 0; i < 7; i++) {
        await _notifications.cancel(((id * 10) + i) % 100000);
      }

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
        // تبدیل به فرمت Flutter (1-7)
        int flutterWeekDay = weekDay == 6 ? 7 : weekDay + 2;

        // محاسبه روز بعدی در هفته که باید اعلان ارسال شود
        final now = DateTime.now();
        final currentTime = TimeOfDay.now();

        // تعداد روزهایی که باید اضافه شود تا به روز مورد نظر برسیم
        int daysToAdd = (flutterWeekDay - now.weekday) % 7;

        // اگر امروز همان روز هفته است و زمان اعلان گذشته، به هفته بعد منتقل شود
        if (daysToAdd == 0 &&
            (time.hour < currentTime.hour ||
                (time.hour == currentTime.hour &&
                    time.minute <= currentTime.minute))) {
          daysToAdd = 7;
        }

        // ایجاد تاریخ و زمان دقیق اعلان
        final scheduledDate = DateTime(
          now.year,
          now.month,
          now.day + daysToAdd,
          time.hour,
          time.minute,
        );

        final scheduledDateTime = tz.TZDateTime.from(scheduledDate, tz.local);

        // ایجاد شناسه منحصر به فرد برای هر اعلان
        final notificationId = ((id * 10) + weekDay) % 100000;

        print(
          'زمان‌بندی اعلان: ${scheduledDateTime.toString()} برای روز $weekDay با شناسه $notificationId',
        );

        // اعلان تکراری هفتگی
        await _notifications.zonedSchedule(
          notificationId,
          title,
          body,
          scheduledDateTime,
          platformDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );

        // اعلان یکبار مصرف برای اولین بار (اگر زمان آن نرسیده باشد)
        if (scheduledDateTime.isAfter(tz.TZDateTime.now(tz.local))) {
          await _notifications.zonedSchedule(
            notificationId + 100000, // شناسه متفاوت برای اعلان یکبار مصرف
            title,
            body,
            scheduledDateTime,
            platformDetails,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          );
        }
      }
    } catch (e) {
      print('خطا در تنظیم اعلان: $e');
      rethrow;
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
      // Check if a permission request is already in progress
      if (_permissionRequestInProgress) {
        print('Permission request already in progress, skipping');
        return false;
      }

      try {
        _permissionRequestInProgress = true;
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
      } finally {
        _permissionRequestInProgress = false;
      }
    }
    return true; // در پلتفرم‌های دیگر نیازی به مجوز خاصی نیست
  }

  static Future<List<PendingNotificationRequest>>
  getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  static Future<bool> checkExactAlarmPermission() async {
    if (Platform.isAndroid) {
      // Don't check if a request is already in progress
      if (_permissionRequestInProgress) {
        print('Permission check skipped - request in progress');
        return false;
      }

      final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
          _notifications
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      final bool? hasPermission =
          await androidPlugin?.canScheduleExactNotifications();

      print('وضعیت مجوز اعلان‌های دقیق: $hasPermission');

      return hasPermission ?? false;
    }
    return true;
  }

  static Future<void> testScheduleNotification() async {
    try {
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

      // تنظیم اعلان برای 10 ثانیه بعد
      final now = tz.TZDateTime.now(tz.local);
      final scheduledTime = now.add(Duration(seconds: 10));

      await _notifications.zonedSchedule(
        9999,
        'تست اعلان زمان‌بندی شده',
        'این اعلان باید 10 ثانیه بعد نمایش داده شود',
        scheduledTime,
        platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      print('اعلان تست برای ${scheduledTime.toString()} تنظیم شد');
      return;
    } catch (e) {
      print('خطا در تنظیم اعلان تست: $e');
      rethrow;
    }
  }
}
