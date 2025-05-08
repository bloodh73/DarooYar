import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'notification_service.dart';
import 'main_page.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // مقداردهی اولیه سرویس اعلان‌ها
  await NotificationService.initialize();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'دارو یار',
      theme: AppTheme.lightTheme,

      themeMode: ThemeMode.system, // استفاده از تم سیستم
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('fa', 'IR'), // فارسی
      ],
      locale: Locale('fa', 'IR'),
      home: MainPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
