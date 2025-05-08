import 'package:flutter/material.dart';
import 'app_colors.dart';

class MedicineCardStyle {
  static Color getColorByType(String medicineType) {
    switch (medicineType) {
      case 'قرص':
        return AppColors.primary; // سبز تیره اصلی
      case 'کپسول':
        return Color(0xFF00897B); // سبز-آبی تیره
      case 'شربت':
        return Color(0xFF43A047); // سبز روشن
      case 'آمپول':
        return Color(0xFF1565C0); // آبی تیره
      case 'قطره':
        return Color(0xFF00ACC1); // آبی فیروزه‌ای
      case 'پماد':
        return Color(0xFF5E35B1); // بنفش
      default:
        return AppColors.primary;
    }
  }

  static IconData getIconByType(String medicineType) {
    switch (medicineType) {
      case 'قرص':
        return Icons.tablet;
      case 'کپسول':
        return Icons.medication;
      case 'شربت':
        return Icons.local_drink;
      case 'آمپول':
        return Icons.vaccines;
      case 'پماد':
        return Icons.healing;
      case 'قطره':
        return Icons.opacity;
      case 'اسپری':
        return Icons.spa;
      default:
        return Icons.medical_services;
    }
  }

  static BoxDecoration getCardDecoration(Color backgroundColor) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      gradient: LinearGradient(
        colors: [
          backgroundColor,
          HSLColor.fromColor(backgroundColor)
              .withLightness(HSLColor.fromColor(backgroundColor).lightness * 1.2)
              .toColor(),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(
          color: backgroundColor.withOpacity(0.3),
          blurRadius: 8,
          offset: Offset(0, 4),
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Colors.white.withOpacity(0.5),
          blurRadius: 4,
          offset: Offset(-2, -2),
          spreadRadius: 0,
        ),
      ],
    );
  }
}





