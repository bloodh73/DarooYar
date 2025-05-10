// import 'package:daroo/services/update_service.dart';
// import 'package:flutter/material.dart';
// import 'package:package_info_plus/package_info_plus.dart';
// import 'package:dio/dio.dart';

// class UpdatePage extends StatefulWidget {
//   @override
//   _UpdatePageState createState() => _UpdatePageState();
// }

// class _UpdatePageState extends State<UpdatePage> {
//   bool _isLoading = true;
//   String _currentVersion = '';
//   Map<String, dynamic>? _updateInfo;
//   String _errorMessage = '';

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }

//   Future<void> _loadData() async {
//     try {
//       final packageInfo = await PackageInfo.fromPlatform();
//       setState(() {
//         _currentVersion = packageInfo.version;
//       });

//       final updateInfo = await _fetchUpdateInfo();
//       setState(() {
//         _isLoading = false;
//         _updateInfo = updateInfo;
//       });
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//         _errorMessage = 'خطا در بررسی بروزرسانی: $e';
//       });
//     }
//   }

//   bool _isNewVersionAvailable(String currentVersion, String latestVersion) {
//     final current = currentVersion.split('.').map(int.parse).toList();
//     final latest = latestVersion.split('.').map(int.parse).toList();

//     for (var i = 0; i < 3; i++) {
//       if (latest[i] > current[i]) return true;
//       if (latest[i] < current[i]) return false;
//     }
//     return false;
//   }

//   Future<Map<String, dynamic>> _fetchUpdateInfo() async {
//     try {
//       final packageInfo = await PackageInfo.fromPlatform();
//       final currentVersion = packageInfo.version;

//       final response = await Dio().get(UpdateChecker.GITHUB_API);
//       final latestVersion = response.data['tag_name'].toString().replaceAll(
//         'v',
//         '',
//       );
//       final downloadUrl = response.data['assets']?[0]?['browser_download_url'];
//       final releaseNotes = response.data['body'] ?? '';

//       final hasUpdate = _isNewVersionAvailable(currentVersion, latestVersion);

//       return {
//         'hasUpdate': hasUpdate,
//         'latestVersion': latestVersion,
//         'downloadUrl': downloadUrl,
//         'releaseNotes': releaseNotes,
//       };
//     } catch (e) {
//       throw Exception('Failed to fetch update info: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('بروزرسانی برنامه'), centerTitle: true),
//       body:
//           _isLoading
//               ? Center(child: CircularProgressIndicator())
//               : _errorMessage.isNotEmpty
//               ? _buildErrorView()
//               : _buildUpdateView(),
//     );
//   }

//   Widget _buildErrorView() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.error_outline, size: 48, color: Colors.red),
//           SizedBox(height: 16),
//           Text(_errorMessage),
//           SizedBox(height: 24),
//           ElevatedButton(
//             onPressed: () {
//               setState(() {
//                 _isLoading = true;
//                 _errorMessage = '';
//               });
//               _loadData();
//             },
//             child: Text('تلاش مجدد'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildUpdateView() {
//     final hasUpdate = _updateInfo != null && _updateInfo!['hasUpdate'] == true;

//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildVersionInfoCard(),
//           SizedBox(height: 24),
//           if (hasUpdate) _buildUpdateInfoCard() else _buildNoUpdateCard(),
//           Spacer(),
//           if (hasUpdate) _buildDownloadButton(),
//         ],
//       ),
//     );
//   }

//   Widget _buildVersionInfoCard() {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'نسخه فعلی',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 8),
//             Row(
//               children: [
//                 Icon(Icons.info_outline, color: Colors.blue),
//                 SizedBox(width: 8),
//                 Text('نسخه $_currentVersion', style: TextStyle(fontSize: 16)),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildUpdateInfoCard() {
//     return Card(
//       elevation: 4,
//       color: Colors.green.shade50,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(Icons.new_releases, color: Colors.green),
//                 SizedBox(width: 8),
//                 Text(
//                   'بروزرسانی جدید در دسترس است',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.green.shade700,
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 16),
//             Text(
//               'نسخه ${_updateInfo!['latestVersion']}',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 16),
//             Text(
//               'تغییرات:',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             Container(
//               margin: EdgeInsets.only(top: 8),
//               padding: EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.green.shade200),
//               ),
//               child: Text(_updateInfo!['releaseNotes']),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildNoUpdateCard() {
//     return Card(
//       elevation: 4,
//       color: Colors.blue.shade50,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(Icons.check_circle, color: Colors.blue),
//                 SizedBox(width: 8),
//                 Text(
//                   'برنامه به‌روز است',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.blue.shade700,
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 16),
//             Text(
//               'شما از آخرین نسخه برنامه استفاده می‌کنید.',
//               style: TextStyle(fontSize: 16),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDownloadButton() {
//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton.icon(
//         onPressed: () {
//           UpdateChecker.launchDownload(_updateInfo!['downloadUrl']);
//         },
//         icon: Icon(Icons.download),
//         label: Text('دریافت و نصب', style: TextStyle(fontSize: 16)),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.green,
//           foregroundColor: Colors.white,
//           padding: EdgeInsets.symmetric(vertical: 12),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//       ),
//     );
//   }
// }
