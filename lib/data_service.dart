import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'medicine_model.dart';

class DataService {
  static const String MEDICINES_KEY = 'medicines';

  static Future<void> saveMedicines(List<Medicine> medicines) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> medicinesMap =
        medicines.map((medicine) {
          return {
            'id': medicine.id,
            'name': medicine.name,
            'dosage': medicine.dosage,
            'reminderTimes':
                medicine.reminderTimes
                    .map((time) => '${time.hour}:${time.minute}')
                    .toList(),
            'weekDays': medicine.weekDays,
            'startDate': medicine.startDate.toIso8601String(),
            'endDate': medicine.endDate?.toIso8601String(),
            'isActive': medicine.isActive,
          };
        }).toList();

    await prefs.setString(MEDICINES_KEY, jsonEncode(medicinesMap));
  }

  static Future<List<Medicine>> loadMedicines() async {
    final prefs = await SharedPreferences.getInstance();
    final String? medicinesJson = prefs.getString(MEDICINES_KEY);

    if (medicinesJson == null) {
      return [];
    }

    final List<dynamic> medicinesMap = jsonDecode(medicinesJson);
    return medicinesMap.map<Medicine>((map) {
      return Medicine(
        id: map['id'],
        name: map['name'],
        dosage: map['dosage'],
        medicineType: map['medicineType'] ?? 'قرص',
        reminderTimes:
            (map['reminderTimes'] as List<dynamic>).map<TimeOfDay>((timeStr) {
              final parts = timeStr.split(':');
              return TimeOfDay(
                hour: int.parse(parts[0]),
                minute: int.parse(parts[1]),
              );
            }).toList(),
        weekDays: List<int>.from(map['weekDays']),
        startDate: DateTime.parse(map['startDate']),
        endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
        isActive: map['isActive'],
        notes: map['notes'] ?? '',
      );
    }).toList();
  }
}

