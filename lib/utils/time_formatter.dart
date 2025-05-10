import 'package:flutter/material.dart';

class TimeFormatter {
  /// تبدیل زمان به فرمت 12 ساعته با قالب فارسی
  static String formatTo12Hour(TimeOfDay time) {
    final int hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final String minute = time.minute < 10 ? '0${time.minute}' : '${time.minute}';
    String period = _getPersianPeriod(time.hour);

    return '$hour:$minute $period';
  }

  /// تبدیل زمان به فرمت کوتاه و زیبا
  static String formatToShort(TimeOfDay time) {
    final int hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final String minute = time.minute < 10 ? '0${time.minute}' : '${time.minute}';
    String period = time.hour < 12 ? 'ص' : 'ع';

    return '$hour:$minute$period';
  }

  /// تبدیل ساعت به دوره زمانی فارسی (صبح، ظهر، عصر، شب)
  static String _getPersianPeriod(int hour) {
    if (hour >= 0 && hour < 12) {
      return 'صبح';
    } else if (hour >= 12 && hour < 17) {
      return 'عصر';
    } else if (hour >= 17 && hour < 20) {
      return 'غروب';
    } else {
      return 'شب';
    }
  }

  /// تبدیل رشته زمان به شیء TimeOfDay
  static TimeOfDay stringToTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}


