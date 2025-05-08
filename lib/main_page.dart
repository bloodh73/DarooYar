import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'medicine_model.dart';
import 'add_medicine_page.dart';
import 'medicine_detail_page.dart';
import 'notification_service.dart';
import 'utils/time_formatter.dart';
import 'widgets/empty_state.dart';
import 'dart:io' show Platform;
import 'data_service.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'theme/medicine_card_style.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<Medicine> medicines = [];
  bool _hasPermission = true;
  int _selectedIndex = 0; // برای نگهداری ایندکس تب انتخاب شده

  // متغیرهای جدید برای تقویم
  late Jalali _selectedJalaliDate;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _loadSavedMedicines();

    // مقداردهی تاریخ شمسی با تاریخ امروز
    _selectedJalaliDate = Jalali.fromDateTime(DateTime.now());
  }

  Future<void> _loadSavedMedicines() async {
    final savedMedicines = await DataService.loadMedicines();
    setState(() {
      medicines = savedMedicines;
    });
  }

  // ذخیره داروها هر بار که تغییر می‌کنند
  Future<void> _saveMedicines() async {
    await DataService.saveMedicines(medicines);
  }

  Future<void> _checkPermissions() async {
    try {
      if (Platform.isAndroid) {
        // بررسی مجوزها در اندروید
        final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
            FlutterLocalNotificationsPlugin()
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >();

        final bool? hasExactAlarmPermission =
            await androidPlugin?.canScheduleExactNotifications();

        setState(() {
          _hasPermission = hasExactAlarmPermission ?? false;
        });

        if (!_hasPermission) {
          _showPermissionDialog();
        }
      }
    } catch (e) {
      debugPrint('Error checking permissions: $e');
      // If there's an error, assume we need permission to be safe
      setState(() {
        _hasPermission = false;
      });
      _showPermissionDialog();
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Text('نیاز به دسترسی'),
            content: Text(
              'برای یادآوری دقیق زمان مصرف داروها، برنامه نیاز به دسترسی به تنظیم اعلان‌های دقیق دارد. لطفا این دسترسی را در تنظیمات فعال کنید.',
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await NotificationService.openNotificationSettings();
                  // بررسی مجدد مجوزها پس از بازگشت از صفحه تنظیمات
                  _checkPermissions();
                },
                child: Text('باز کردن تنظیمات'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.medication_rounded,
                size: 24,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(width: 12),
            Text(
              'دارو یار',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 2,
        backgroundColor: Colors.white,
        foregroundColor: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined),
            tooltip: 'اعلان‌ها',
            onPressed: () {
              // اینجا می‌توانید کد مربوط به نمایش اعلان‌ها را قرار دهید
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'settings':
                  // اینجا کد مربوط به باز کردن صفحه تنظیمات را قرار دهید
                  break;
                case 'about':
                  _showAboutDialog();
                  break;
                case 'help':
                  _showHelpDialog();
                  break;
              }
            },
            itemBuilder:
                (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(Icons.settings, color: Colors.grey[700]),
                        SizedBox(width: 8),
                        Text('تنظیمات'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'about',
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.grey[700]),
                        SizedBox(width: 8),
                        Text('درباره برنامه'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'help',
                    child: Row(
                      children: [
                        Icon(Icons.help_outline, color: Colors.grey[700]),
                        SizedBox(width: 8),
                        Text('راهنما'),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body:
          _getBody(), // متد جدید برای نمایش محتوای مناسب بر اساس تب انتخاب شده
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.medication_outlined),
                activeIcon: Icon(Icons.medication),
                label: 'داروها',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today_outlined),
                activeIcon: Icon(Icons.calendar_today),
                label: 'تقویم',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'پروفایل',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: Colors.grey,
            backgroundColor: Colors.white,
            elevation: 0,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        ),
      ),
      floatingActionButton:
          _selectedIndex == 0
              ? FloatingActionButton.extended(
                onPressed: _addNewMedicine,
                icon: Icon(Icons.add),
                label: Text('افزودن دارو'),
              )
              : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _addNewMedicine() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddMedicinePage()),
    );

    if (result != null && result is Medicine) {
      setState(() {
        medicines.add(result);
      });

      // ذخیره داروها پس از اضافه کردن داروی جدید
      await _saveMedicines();

      // تنظیم اعلان‌ها برای داروی جدید
      if (result.isActive) {
        for (TimeOfDay time in result.reminderTimes) {
          NotificationService.scheduleNotification(
            id: result.id.hashCode % 10000,
            title: 'یادآوری دارو: ${result.name}',
            body: 'زمان مصرف دارو با دوز ${result.dosage} فرا رسیده است.',
            time: time,
            weekDays: result.weekDays,
            sound: result.alarmTone,
          );
        }
      }
    }
  }

  void _toggleMedicineStatus(int index, bool isActive) {
    setState(() {
      final medicine = medicines[index];
      final updatedMedicine = Medicine(
        id: medicine.id,
        name: medicine.name,
        dosage: medicine.dosage,
        medicineType: medicine.medicineType,
        reminderTimes: medicine.reminderTimes,
        weekDays: medicine.weekDays,
        startDate: medicine.startDate,
        endDate: medicine.endDate,
        isActive: isActive,
        alarmTone: medicine.alarmTone,
      );

      medicines[index] = updatedMedicine;

      // ذخیره داروها پس از تغییر وضعیت
      _saveMedicines();

      // اگر فعال شده، اعلان‌ها را تنظیم کنیم
      if (isActive) {
        for (TimeOfDay time in updatedMedicine.reminderTimes) {
          NotificationService.scheduleNotification(
            id: updatedMedicine.id.hashCode % 10000,
            title: 'یادآوری دارو: ${updatedMedicine.name}',
            body:
                'زمان مصرف دارو با دوز ${updatedMedicine.dosage} فرا رسیده است.',
            time: time,
            weekDays: updatedMedicine.weekDays,
            sound: updatedMedicine.alarmTone,
          );
        }
      } else {
        // اگر غیرفعال شده، اعلان‌ها را لغو کنیم
        for (TimeOfDay time in updatedMedicine.reminderTimes) {
          for (int weekDay in updatedMedicine.weekDays) {
            // استفاده از همان روش تولید شناسه که در NotificationService استفاده شده
            int timeComponent = time.hour * 100 + time.minute;
            int baseId = updatedMedicine.id.hashCode % 10000;
            int notificationId =
                ((baseId * 10000) + (timeComponent * 10) + weekDay) %
                0x7FFFFFFF;

            NotificationService.cancelNotification(notificationId);
          }
        }
      }
    });
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('درباره دارو یار'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('نسخه: 1.0.0'),
                SizedBox(height: 8),
                Text('این برنامه برای یادآوری مصرف داروها طراحی شده است.'),
                SizedBox(height: 8),
                Text('توسعه‌دهنده: حامد کریمی'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('بستن'),
              ),
            ],
          ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('راهنمای استفاده'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'چگونه دارو اضافه کنم؟',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'روی دکمه "افزودن دارو" در پایین صفحه کلیک کنید و اطلاعات دارو را وارد نمایید.',
                  ),
                  SizedBox(height: 12),

                  Text(
                    'چگونه دارو را ویرایش کنم؟',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('روی دکمه "ویرایش" در کارت دارو کلیک کنید.'),
                  SizedBox(height: 12),

                  Text(
                    'چگونه یادآوری را غیرفعال کنم؟',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('از کلید تغییر وضعیت در کنار نام دارو استفاده کنید.'),
                  SizedBox(height: 12),

                  Text(
                    'چگونه دارو را حذف کنم؟',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('روی دکمه "حذف" در کارت دارو کلیک کنید.'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('متوجه شدم'),
              ),
            ],
          ),
    );
  }

  // متد برای نمایش محتوای مناسب بر اساس تب انتخاب شده
  Widget _getBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildMedicinesTab();
      case 1:
        return _buildCalendarTab();
      case 2:
        return _buildProfileTab();
      default:
        return _buildMedicinesTab();
    }
  }

  // تب داروها با طراحی بهینه‌شده
  Widget _buildMedicinesTab() {
    return medicines.isEmpty
        ? EmptyState(
          icon: Icons.medication_outlined,
          title: 'لیست داروها خالی است',
          message: 'برای شروع، داروی جدیدی اضافه کنید.',
          buttonLabel: 'افزودن داروی جدید',
          onPressed: _addNewMedicine,
        )
        : LayoutBuilder(
          builder: (context, constraints) {
            // استفاده از گرید برای صفحات بزرگتر
            return constraints.maxWidth > 600
                ? GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: constraints.maxWidth > 900 ? 3 : 2,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.all(16),
                  itemCount: medicines.length,
                  itemBuilder: (context, index) {
                    return _buildMedicineCard(medicines[index], index);
                  },
                )
                : ListView.builder(
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: 80,
                  ),
                  itemCount: medicines.length,
                  itemBuilder: (context, index) {
                    return _buildMedicineCard(medicines[index], index);
                  },
                );
          },
        );
  }

  Widget _buildMedicineCard(Medicine medicine, int index) {
    final medicineColor = MedicineCardStyle.getColorByType(medicine.medicineType);
    final medicineIcon = MedicineCardStyle.getIconByType(medicine.medicineType);
    final isActive = medicine.isActive;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16, left: 2, right: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: medicineColor.withOpacity(0.15),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          onTap: () => _viewMedicineDetails(medicine, index),
          splashColor: medicineColor.withOpacity(0.1),
          highlightColor: Colors.transparent,
          child: Column(
            children: [
              // هدر کارت با رنگ دارو
              Container(
                height: 8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      medicineColor,
                      Color(0xFFD50B8B), // رنگ اصلی پالت
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // آیکون دارو
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Color(0xFFFBF3C1).withOpacity(0.5), // رنگ زمینه زرد کمرنگ
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: medicineColor.withOpacity(0.1),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            medicineIcon,
                            color: medicineColor,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // اطلاعات دارو
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                medicine.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D2D3A),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: medicineColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      medicine.medicineType,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: medicineColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    medicine.dosage,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF7C7C8A),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        // سوئیچ فعال/غیرفعال
                        Transform.scale(
                          scale: 0.8,
                          child: Switch(
                            value: isActive,
                            onChanged: (value) {
                              _toggleMedicineStatus(index, value);
                            },
                            activeColor: Color(0xFFD50B8B),
                            activeTrackColor: Color(0xFFD50B8B).withOpacity(0.3),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // خط جداکننده با گرادیان
                    Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Color(0xFFDC8BE0).withOpacity(0.5),
                            Colors.transparent,
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // زمان‌های مصرف دارو
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 16,
                          color: Color(0xFF64E2B7),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'زمان مصرف:',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF7C7C8A),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // نمایش زمان‌های مصرف
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: medicine.reminderTimes.map((time) {
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Color(0xFFFBF3C1).withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Color(0xFFDC8BE0).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            TimeFormatter.formatTo12Hour(time),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D2D3A),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // دکمه‌های عملیات
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // دکمه ویرایش
                        Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () => _editMedicine(medicines[index], index),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.edit_outlined,
                                color: Color(0xFF64E2B7),
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        
                        // دکمه حذف
                        Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () => _showDeleteConfirmation(index),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  IconData _getMedicineIcon(String medicineType) {
    switch (medicineType) {
      case 'Tablet':
        return Icons.tablet;
      case 'Capsule':
        return Icons.castle;
      case 'Liquid':
        return Icons.local_drink;
      case 'Pill':
        return Icons.poll;
      default:
        return Icons.medication;
    }
  }

  void _viewMedicineDetails(Medicine medicine, int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicineDetailPage(medicine: medicine),
      ),
    );

    if (result != null) {
      if (result is Map && result['action'] == 'delete') {
        // حذف دارو
        setState(() {
          medicines.removeAt(index);
        });
        await _saveMedicines();

        // نمایش پیام حذف
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('دارو با موفقیت حذف شد'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _editMedicine(Medicine medicine, int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMedicinePage(medicine: medicine),
      ),
    );

    if (result != null && result is Medicine) {
      setState(() {
        medicines[index] = result;
      });
      await _saveMedicines();
    }
  }

  // تب تقویم با تقویم شمسی
  Widget _buildCalendarTab() {
    return Column(
      children: [_buildCalendarHeader(), Expanded(child: _buildCalendarBody())],
    );
  }

  Widget _buildCalendarHeader() {
    final now = DateTime.now();
    final todayJalali = Jalali.fromDateTime(now);
    final isCurrentMonth =
        _selectedJalaliDate.year == todayJalali.year &&
        _selectedJalaliDate.month == todayJalali.month;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  Icons.chevron_left,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                onPressed: () {
                  setState(() {
                    if (_selectedJalaliDate.month > 1) {
                      _selectedJalaliDate = Jalali(
                        _selectedJalaliDate.year,
                        _selectedJalaliDate.month - 1,
                        1,
                      );
                    } else {
                      _selectedJalaliDate = Jalali(
                        _selectedJalaliDate.year - 1,
                        12,
                        1,
                      );
                    }
                  });
                },
                tooltip: 'ماه قبل',
              ),
              GestureDetector(
                onTap: isCurrentMonth ? null : _goToCurrentMonth,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_getJalaliMonthName(_selectedJalaliDate.month)} ${_selectedJalaliDate.year}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                onPressed: _goToNextMonth,
                tooltip: 'ماه بعد',
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              // روزهای هفته از شنبه (0) تا جمعه (6)
              return Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.15),
                ),
                child: Text(
                  _weekDaysShort[index],
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarBody() {
    return medicines.isEmpty
        ? EmptyState(
          icon: Icons.calendar_today_outlined,
          title: 'تقویم خالی است',
          message: 'برای مشاهده تقویم مصرف، ابتدا داروهای خود را اضافه کنید.',
          buttonLabel: 'افزودن داروی جدید',
          onPressed: () {
            setState(() {
              _selectedIndex = 0;
            });
            _addNewMedicine();
          },
        )
        : SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              _buildJalaliMonthCalendar(),
              SizedBox(height: 24),
              _buildTodayMedicines(),
            ],
          ),
        );
  }

  Widget _buildJalaliMonthCalendar() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_month,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  'تقویم ماهانه',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              height: 320, // ارتفاع مناسب برای تقویم
              child: GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7, // 7 روز هفته
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: _getDaysInMonth() + _getFirstDayOfMonth(),
                itemBuilder: (context, index) {
                  // روزهای خالی قبل از شروع ماه
                  if (index < _getFirstDayOfMonth()) {
                    return Container();
                  }

                  // روزهای ماه
                  final day = index - _getFirstDayOfMonth() + 1;
                  final date = Jalali(
                    _selectedJalaliDate.year,
                    _selectedJalaliDate.month,
                    day,
                  );
                  final isToday = _isToday(date);
                  final hasMedicine = _hasMedicineForDate(date);

                  return GestureDetector(
                    onTap: () => _showMedicinesForDate(date.toDateTime()),
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            isToday
                                ? Theme.of(context).colorScheme.primary
                                : hasMedicine
                                ? Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.1)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              hasMedicine && !isToday
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            day.toString(),
                            style: TextStyle(
                              color:
                                  isToday
                                      ? Colors.white
                                      : hasMedicine
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.black87,
                              fontWeight:
                                  isToday || hasMedicine
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                          ),
                          if (hasMedicine && !isToday)
                            Positioned(
                              bottom: 4,
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayMedicines() {
    final today = DateTime.now();
    final weekDay = today.weekday % 7; // 0 = شنبه، 6 = جمعه

    final todayMedicines =
        medicines.where((medicine) {
          return medicine.isActive && medicine.weekDays.contains(weekDay);
        }).toList();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.today,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'داروهای امروز',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${_getJalaliDayName(weekDay)} ${Jalali.fromDateTime(today).day} ${_getJalaliMonthName(Jalali.fromDateTime(today).month)}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Divider(height: 24, thickness: 1),
            todayMedicines.isEmpty
                ? Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 48,
                          color: Colors.green,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'امروز دارویی برای مصرف ندارید',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                : ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: todayMedicines.length,
                  separatorBuilder:
                      (context, index) =>
                          Divider(height: 16, indent: 8, endIndent: 8),
                  itemBuilder: (context, index) {
                    final medicine = todayMedicines[index];
                    final medicineColor = MedicineCardStyle.getColorByType(
                      medicine.medicineType,
                    );

                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      leading: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: medicineColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          MedicineCardStyle.getIconByType(
                            medicine.medicineType,
                          ),
                          color: medicineColor,
                        ),
                      ),
                      title: Text(
                        medicine.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4),
                          Text(medicine.dosage),
                          SizedBox(height: 4),
                          Wrap(
                            spacing: 6,
                            children:
                                medicine.reminderTimes.map((time) {
                                  return Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      TimeFormatter.formatTo12Hour(time),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.arrow_forward_ios, size: 18),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      MedicineDetailPage(medicine: medicine),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
          ],
        ),
      ),
    );
  }

  // تابع کمکی برای بررسی اینکه آیا تاریخ مورد نظر امروز است یا خیر
  bool _isToday(Jalali date) {
    final today = Jalali.fromDateTime(DateTime.now());
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  // تابع کمکی برای بررسی اینکه آیا در تاریخ مورد نظر دارویی برای مصرف وجود دارد یا خیر
  bool _hasMedicineForDate(Jalali date) {
    final weekDay = (date.toDateTime().weekday) % 7; // 0 = شنبه، 6 = جمعه

    return medicines.any(
      (medicine) => medicine.isActive && medicine.weekDays.contains(weekDay),
    );
  }

  // تابع برای نمایش نام روز هفته
  String _getJalaliDayName(int weekDay) {
    final days = [
      'شنبه',
      'یکشنبه',
      'دوشنبه',
      'سه‌شنبه',
      'چهارشنبه',
      'پنج‌شنبه',
      'جمعه',
    ];
    return days[weekDay];
  }

  // نام‌های کوتاه روزهای هفته
  final List<String> _weekDaysShort = ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج'];

  void _showMedicinesForDate(DateTime date) {
    final jalali = Jalali.fromDateTime(date);
    final weekDay = date.weekday % 7; // 0 = شنبه، 6 = جمعه

    final medicinesForDate =
        medicines.where((medicine) {
          if (!medicine.isActive) return false;

          // بررسی روز هفته
          if (!medicine.weekDays.contains(weekDay)) return false;

          // بررسی تاریخ شروع و پایان
          if (date.isBefore(medicine.startDate)) {
            return false;
          }

          if (medicine.endDate != null && date.isAfter(medicine.endDate!)) {
            return false;
          }

          return true;
        }).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${jalali.day} ${_getJalaliMonthName(jalali.month)} ${jalali.year}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'داروهای این روز',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Divider(height: 24),
              medicinesForDate.isEmpty
                  ? Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 48,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'در این روز دارویی برای مصرف ندارید',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  )
                  : Expanded(
                    child: ListView.separated(
                      itemCount: medicinesForDate.length,
                      separatorBuilder: (context, index) => Divider(height: 1),
                      itemBuilder: (context, index) {
                        final medicine = medicinesForDate[index];
                        final medicineColor = MedicineCardStyle.getColorByType(
                          medicine.medicineType,
                        );

                        return ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                          leading: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: medicineColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _getMedicineIcon(medicine.medicineType),
                              color: medicineColor,
                            ),
                          ),
                          title: Text(
                            medicine.name,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 4),
                              Text(medicine.dosage),
                              SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children:
                                    medicine.reminderTimes.map((time) {
                                      return Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          TimeFormatter.formatTo12Hour(time),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.arrow_forward_ios, size: 18),
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => MedicineDetailPage(
                                        medicine: medicine,
                                      ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }

  String _getJalaliMonthName(int month) {
    final months = [
      'فروردین',
      'اردیبهشت',
      'خرداد',
      'تیر',
      'مرداد',
      'شهریور',
      'مهر',
      'آبان',
      'آذر',
      'دی',
      'بهمن',
      'اسفند',
    ];
    return months[month - 1];
  }

  void _goToCurrentMonth() {
    setState(() {
      _selectedJalaliDate = Jalali.fromDateTime(DateTime.now());
    });
  }

  void _goToNextMonth() {
    setState(() {
      if (_selectedJalaliDate.month < 12) {
        _selectedJalaliDate = Jalali(
          _selectedJalaliDate.year,
          _selectedJalaliDate.month + 1,
          1,
        );
      } else {
        _selectedJalaliDate = Jalali(_selectedJalaliDate.year + 1, 1, 1);
      }
    });
  }

  // تابع برای محاسبه تعداد روزهای ماه
  int _getDaysInMonth() {
    // تعداد روزهای ماه‌های شمسی
    final daysInMonth = [31, 31, 31, 31, 31, 31, 30, 30, 30, 30, 30, 29];
    // در سال کبیسه، اسفند 30 روز است
    if (_selectedJalaliDate.month == 12 && _selectedJalaliDate.isLeapYear()) {
      return 30;
    }
    return daysInMonth[_selectedJalaliDate.month - 1];
  }

  // تابع برای محاسبه اولین روز ماه
  int _getFirstDayOfMonth() {
    final firstDayOfMonth = Jalali(
      _selectedJalaliDate.year,
      _selectedJalaliDate.month,
      1,
    );
    // روز هفته از 0 (شنبه) تا 6 (جمعه)
    return firstDayOfMonth.toDateTime().weekday % 7;
  }

  // تب پروفایل
  Widget _buildProfileTab() {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            SizedBox(height: 24),
            _buildUserInfoSection(),
            SizedBox(height: 24),
            _buildMedicationStatistics(),
            SizedBox(height: 24),
            _buildSettingsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Icon(Icons.person, size: 40, color: Colors.white),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'کاربر دارویار',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'برنامه مدیریت داروها',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white),
            onPressed: _editUserProfile,
            tooltip: 'ویرایش پروفایل',
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: 8),
                Text(
                  'اطلاعات شخصی',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Divider(height: 24),
            _buildInfoItem(Icons.person_outline, 'نام', 'تنظیم نشده'),
            _buildInfoItem(Icons.cake_outlined, 'تاریخ تولد', 'تنظیم نشده'),
            _buildInfoItem(Icons.height, 'قد', 'تنظیم نشده'),
            _buildInfoItem(Icons.monitor_weight_outlined, 'وزن', 'تنظیم نشده'),
            _buildInfoItem(Icons.bloodtype_outlined, 'گروه خونی', 'تنظیم نشده'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          SizedBox(width: 12),
          Text(
            '$title:',
            style: TextStyle(fontSize: 14, color: Colors.grey[800]),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationStatistics() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: 8),
                Text(
                  'آمار داروها',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Divider(height: 24),
            _buildStatItem(
              Icons.medication_outlined,
              'تعداد داروها',
              '${medicines.length}',
            ),
            _buildStatItem(
              Icons.notifications_active_outlined,
              'یادآوری‌های فعال',
              '${medicines.where((m) => m.isActive).length}',
            ),
            _buildStatItem(
              Icons.calendar_today_outlined,
              'داروهای روزانه',
              '${_getDailyMedicinesCount()}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(width: 12),
          Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[800])),
          Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.settings_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: 8),
                Text(
                  'تنظیمات',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Divider(height: 24),
            _buildSettingItem(
              Icons.notifications_outlined,
              'تنظیمات اعلان‌ها',
              _openNotificationSettings,
            ),
            _buildSettingItem(
              Icons.color_lens_outlined,
              'تم برنامه',
              _openThemeSettings,
            ),
            _buildSettingItem(
              Icons.backup_outlined,
              'پشتیبان‌گیری',
              _openBackupSettings,
            ),
            _buildSettingItem(
              Icons.info_outline,
              'درباره برنامه',
              _showAboutDialog,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[600]),
            SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(fontSize: 14, color: Colors.grey[800]),
            ),
            Spacer(),
            Icon(Icons.chevron_right, size: 20, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // متدهای کمکی برای پروفایل
  void _editUserProfile() {
    // در نسخه‌های آینده پیاده‌سازی خواهد شد
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('این قابلیت در نسخه‌های آینده اضافه خواهد شد'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  int _getDailyMedicinesCount() {
    final today = DateTime.now().weekday % 7; // 0 for Saturday, 6 for Friday
    return medicines.where((m) => m.weekDays.contains(today)).length;
  }

  void _openNotificationSettings() async {
    await NotificationService.openNotificationSettings();
  }

  void _openThemeSettings() {
    // در نسخه‌های آینده پیاده‌سازی خواهد شد
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('این قابلیت در نسخه‌های آینده اضافه خواهد شد'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openBackupSettings() {
    // در نسخه‌های آینده پیاده‌سازی خواهد شد
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('این قابلیت در نسخه‌های آینده اضافه خواهد شد'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }


  void _showDeleteConfirmation(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('حذف دارو'),
        content: Text('آیا از حذف این دارو اطمینان دارید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('انصراف'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // بستن دیالوگ
              // حذف اعلان‌ها
              NotificationService.cancelNotification(
                medicines[index].id.hashCode % 10000,
              );
              // حذف دارو
              setState(() {
                medicines.removeAt(index);
              });
              _saveMedicines();
              
              // نمایش پیام حذف
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('دارو با موفقیت حذف شد'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
