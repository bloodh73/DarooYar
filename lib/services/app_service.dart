import 'dart:async';
import 'package:flutter/material.dart';
import 'update_service.dart';

class AppService {
  static Timer? _updateTimer;
  
  static void startPeriodicUpdateCheck(BuildContext context) {
    // بررسی هر 7 روز یکبار
    _updateTimer = Timer.periodic(Duration(days: 7), (_) {
      UpdateChecker.checkForUpdate(context);
    });
  }
  
  static void stopPeriodicUpdateCheck() {
    _updateTimer?.cancel();
    _updateTimer = null;
  }
}