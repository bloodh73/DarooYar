import 'package:flutter/material.dart';
import '../services/update_service.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          // سایر آیتم‌های منو
          ListTile(
            leading: Icon(Icons.system_update),
            title: Text('بررسی به‌روزرسانی'),
            onTap: () {
              Navigator.pop(context); // بستن منو
              UpdateChecker.checkForUpdate(context);
            },
          ),
        ],
      ),
    );
  }
}