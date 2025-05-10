import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateService {
  // نام کاربری و مخزن گیت‌هاب
  static const String _githubUser = 'https://github.com/bloodh73/DarooYar';
  static const String _githubRepo = 'DarooYar';

  // ساختار نسخه
  static int _parseVersionString(String version) {
    // تبدیل نسخه به عدد برای مقایسه راحت‌تر
    // مثال: 1.2.3 -> 10203
    final parts = version.split('.');
    int result = 0;
    for (int i = 0; i < parts.length && i < 3; i++) {
      result = result * 100 + int.parse(parts[i]);
    }
    return result;
  }

  // بررسی وجود بروزرسانی جدید
  static Future<Map<String, dynamic>?> checkForUpdates() async {
    try {
      // دریافت اطلاعات نسخه فعلی برنامه
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      print('نسخه فعلی برنامه: $currentVersion');

      // دریافت آخرین نسخه از گیت‌هاب
      final response = await http.get(
        Uri.parse('https://api.github.com/repos/$_githubUser/$_githubRepo/releases/latest'),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final latestVersion = data['tag_name'].toString().replaceAll('v', '');
        print('آخرین نسخه موجود: $latestVersion');

        // مقایسه نسخه‌ها
        if (_parseVersionString(latestVersion) > _parseVersionString(currentVersion)) {
          return {
            'hasUpdate': true,
            'currentVersion': currentVersion,
            'latestVersion': latestVersion,
            'releaseNotes': data['body'] ?? 'بدون توضیحات',
            'downloadUrl': _getDownloadUrl(data),
          };
        }
      }
      
      return {'hasUpdate': false};
    } catch (e) {
      print('خطا در بررسی بروزرسانی: $e');
      return null;
    }
  }

  // یافتن لینک دانلود مناسب برای اندروید
  static String _getDownloadUrl(Map<String, dynamic> releaseData) {
    // ابتدا سعی می‌کنیم فایل APK را پیدا کنیم
    final assets = releaseData['assets'] as List;
    for (var asset in assets) {
      final name = asset['name'] as String;
      if (name.endsWith('.apk')) {
        return asset['browser_download_url'];
      }
    }
    
    // اگر فایل APK پیدا نشد، لینک صفحه انتشار را برمی‌گردانیم
    return releaseData['html_url'];
  }

  // باز کردن لینک دانلود
  static Future<bool> launchDownload(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }
}