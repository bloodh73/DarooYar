import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'notification_service.dart';  // تغییر به سرویس جدید
import 'main_page.dart';
import 'theme/app_theme.dart';

void main() async {
  // اطمینان از مقداردهی اولیه Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // مقداردهی اولیه سرویس اعلان‌ها
  try {
    await NotificationService.initialize();  // تغییر به سرویس جدید
    print("سرویس اعلان با موفقیت راه‌اندازی شد");
  } catch (e) {
    print("خطا در راه‌اندازی سرویس اعلان: $e");
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'دارو یار',
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.system,
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
