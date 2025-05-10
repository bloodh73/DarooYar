import 'package:flutter/material.dart';

class Medicine {
  final String id;
  final String name;
  final String dosage; // توضیحات دارو (مثلاً قبل از غذا، بعد از غذا و...)
  final String medicineType; // نوع دارو (قرص، شربت، آمپول و...)
  final List<TimeOfDay> reminderTimes;
  final List<int> weekDays;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final String alarmTone; // زنگ هشدار

  Medicine({
    required this.id,
    required this.name,
    required this.dosage,
    required this.medicineType,
    required this.reminderTimes,
    required this.weekDays,
    required this.startDate,
    this.endDate,
    this.isActive = true,
    this.alarmTone = 'notification_sound',
    required notes,
  });

  // تبدیل به Map برای ذخیره‌سازی
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'medicineType': medicineType,
      'reminderTimes':
          reminderTimes.map((time) => '${time.hour}:${time.minute}').toList(),
      'weekDays': weekDays,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate?.millisecondsSinceEpoch,
      'isActive': isActive,
      'alarmTone': alarmTone,
    };
  }

  // ایجاد نمونه از Map
  factory Medicine.fromMap(Map<String, dynamic> map) {
    List<TimeOfDay> times =
        (map['reminderTimes'] as List).map((timeStr) {
          final parts = timeStr.split(':');
          return TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        }).toList();

    return Medicine(
      id: map['id'],
      name: map['name'],
      dosage: map['dosage'],
      medicineType: map['medicineType'] ?? 'قرص',
      reminderTimes: times,
      weekDays: List<int>.from(map['weekDays']),
      startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate']),
      endDate:
          map['endDate'] != null
              ? DateTime.fromMillisecondsSinceEpoch(map['endDate'])
              : null,
      isActive: map['isActive'] ?? true,
      alarmTone: map['alarmTone'] ?? 'notification_sound',
      notes: map['notes'] ?? '',
    );
  }

  get notes => null;
}
