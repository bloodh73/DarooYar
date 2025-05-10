import 'package:flutter/material.dart';
import '../services/update_service.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('تنظیمات')),
      body: ListView(
        children: [
          // سایر تنظیمات
          ListTile(
            leading: Icon(Icons.update),
            title: Text('بررسی به‌روزرسانی'),
            subtitle: Text('آخرین نسخه برنامه را دریافت کنید'),
            onTap: () => UpdateChecker.checkForUpdate(context),
          ),
        ],
      ),
    );
  }
}