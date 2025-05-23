import 'package:flutter/material.dart';
import 'app_colors.dart';

class MedicineCardStyle {
  static Color getColorByType(String medicineType) {
    switch (medicineType) {
      case 'قرص':
        return AppColors.pill; // آبی تیره (1D737E)
      case 'کپسول':
        return AppColors.capsule; // نارنجی مایل به قرمز (EE724C)
      case 'شربت':
        return AppColors.syrup; // نارنجی (FE9836)
      case 'آمپول':
        return AppColors.injection; // آبی خیلی تیره (053F5A)
      case 'قطره':
        return AppColors.drops; // آبی تیره (1D737E)
      case 'پماد':
        return AppColors.topical; // نارنجی (FE9836)
      default:
        return AppColors.primary; // آبی تیره (1D737E)
    }
  }

  static String getImagePathByType(String medicineType) {
    switch (medicineType) {
      case 'قرص':
        return 'assets/images/ghors.png';
      case 'کپسول':
        return 'assets/images/capsule.png';
      case 'شربت':
        return 'assets/images/syrup.png';
      case 'آمپول':
        return 'assets/images/syringe.png';
      case 'پماد':
        return 'assets/images/ointment.png';
      case 'قطره':
        return 'assets/images/eyedrops.png';
      case 'اسپری':
        return 'assets/images/medicine.png'; // تغییر به تصویر موجود
      default:
        return 'assets/images/all.png';
    }
  }

  static IconData getIconByType(String medicineType) {
    switch (medicineType) {
      case 'قرص':
        return Icons.medication_rounded;
      case 'کپسول':
        return Icons.medication_liquid_rounded;
      case 'شربت':
        return Icons.local_drink_rounded;
      case 'آمپول':
        return Icons.vaccines_rounded;
      case 'پماد':
        return Icons.healing_rounded;
      case 'قطره':
        return Icons.opacity_rounded;
      case 'اسپری':
        return Icons.air_rounded;
      default:
        return Icons.medical_services_rounded;
    }
  }

  static BoxDecoration getCardDecoration(Color backgroundColor) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: backgroundColor.withOpacity(0.2),
          blurRadius: 12,
          offset: Offset(0, 6),
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

  static BoxDecoration getIconDecoration(Color color) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      color: color.withOpacity(0.15),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.2),
          blurRadius: 10,
          offset: Offset(0, 4),
          spreadRadius: 1,
        ),
        BoxShadow(
          color: Colors.white.withOpacity(0.7),
          blurRadius: 5,
          offset: Offset(-2, -2),
          spreadRadius: 0,
        ),
      ],
    );
  }

  static TextStyle getTitleStyle() {
    return TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Color(0xFF2D2D3A),
    );
  }

  static TextStyle getSubtitleStyle() {
    return TextStyle(fontSize: 14, color: Color(0xFF7C7C8A));
  }

  static TextStyle getChipTextStyle() {
    return TextStyle(fontSize: 12, fontWeight: FontWeight.bold);
  }

  static BoxDecoration getTimeChipDecoration() {
    return BoxDecoration(
      color: Color(0xFFFBF3C1).withOpacity(0.5),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Color(0xFFDC8BE0).withOpacity(0.3), width: 1),
    );
  }
}
