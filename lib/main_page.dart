import 'dart:ui';

import 'package:flutter/material.dart';
import 'medicine_model.dart';
import 'add_medicine_page.dart';
import 'medicine_detail_page.dart';
import 'notification_service.dart';
// استفاده از سرویس جدید
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
  late Jalali _selectedJalaliDate = Jalali.now();

  @override
  void initState() {
    super.initState();
    _loadSavedMedicines();

    // تست اعلان برای بررسی عملکرد
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkNotificationPermissions();
    });
  }

  // بررسی مجوزهای اعلان و نمایش راهنما در صورت نیاز
  void _checkNotificationPermissions() async {
    // تست اعلان برای اطمینان از عملکرد صحیح
    if (medicines.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('در حال بررسی سیستم اعلان‌ها...'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // تاخیر کوتاه برای نمایش اسنک‌بار
      await Future.delayed(Duration(seconds: 2));

      // ارسال اعلان تست
      await NotificationService.initialize();
      await NotificationService.scheduleNotification(
        id: 9999,
        title: 'تست اعلان',
        body: 'این یک اعلان تست است برای بررسی عملکرد سیستم',
        time: TimeOfDay.now(),
        weekDays: [DateTime.now().weekday], // اصلاح شده
        sound: 'notification_sound',
      );
    }
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
        final bool hasExactAlarmPermission =
            await NotificationService.checkExactAlarmPermission();

        setState(() {
          _hasPermission = hasExactAlarmPermission;
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
                  await NotificationService.requestExactAlarmPermission();
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
        // استفاده از شناسه اصلی دارو
        int baseId = int.parse(result.id) % 0x7FFFFFFF;
        NotificationService.scheduleNotification(
          id: baseId,
          title: 'یادآوری دارو: ${result.name}',
          body: 'زمان مصرف دارو با دوز ${result.dosage} فرا رسیده است.',
          time:
              result.reminderTimes.isNotEmpty
                  ? result.reminderTimes[0]
                  : TimeOfDay.now(),
          weekDays: result.weekDays,
          sound: result.alarmTone,
        );
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
        notes: medicine.notes,
      );

      medicines[index] = updatedMedicine;

      // ذخیره داروها پس از تغییر وضعیت
      _saveMedicines();

      // اگر فعال شده، اعلان‌ها را تنظیم کنیم
      if (isActive && updatedMedicine.reminderTimes.isNotEmpty) {
      } else if (!isActive) {
        // اگر غیرفعال شده، اعلان‌ها را لغو کنیم
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
          buttonLabel: '', // حذف متن دکمه
          onPressed: _addNewMedicine, // غیرفعال کردن دکمه
        )
        : GridView.builder(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            80,
          ), // فضای پایین برای دکمه شناور
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 کارت در هر ردیف
            childAspectRatio: 0.75, // نسبت عرض به ارتفاع کارت
            crossAxisSpacing: 12, // فاصله افقی بین کارت‌ها
            mainAxisSpacing: 16, // فاصله عمودی بین کارت‌ها
          ),
          itemCount: medicines.length,
          itemBuilder: (context, index) {
            return _buildCompactMedicineCard(medicines[index], index);
          },
        );
  }

  Widget _buildCompactMedicineCard(Medicine medicine, int index) {
    final baseColor = MedicineCardStyle.getColorByType(medicine.medicineType);
    final accentColor = Color.lerp(baseColor, Colors.white, 0.3)!;

    return GestureDetector(
      onTap: () => _openMedicineDetails(medicine, index),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: baseColor.withOpacity(0.15),
              blurRadius: 8,
              offset: Offset(0, 3),
              spreadRadius: 0,
            ),
          ],
          border: Border.all(color: baseColor.withOpacity(0.1), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // نوار رنگی بالای کارت
            Container(
              height: 10,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [baseColor, accentColor],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(19),
                  topRight: Radius.circular(19),
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // آیکون و نوع دارو
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCompactPillIcon(medicine, baseColor),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(right: 8),
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: baseColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              medicine.medicineType,
                              style: TextStyle(
                                color: baseColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        // وضعیت فعال/غیرفعال
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                medicine.isActive
                                    ? baseColor
                                    : Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 12),

                    // نام دارو
                    Text(
                      medicine.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black.withOpacity(0.8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // دوز دارو
                    if (medicine.dosage.isNotEmpty) ...[
                      SizedBox(height: 4),
                      Text(
                        medicine.dosage,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    SizedBox(height: 10),

                    // زمان یادآوری
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: baseColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: baseColor,
                          ),
                          SizedBox(width: 6),
                          Expanded(
                            child:
                                medicine.reminderTimes.isEmpty
                                    ? Text(
                                      "بدون یادآوری",
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.black54,
                                      ),
                                    )
                                    : _buildReminderTimesWidget(
                                      medicine,
                                      baseColor,
                                    ),
                          ),
                        ],
                      ),
                    ),

                    Spacer(),

                    // دکمه‌های عملیات
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCompactActionButton(
                          icon: Icons.edit_rounded,
                          color: Colors.blue,
                          onTap: () => _editMedicine(medicine, index),
                        ),
                        _buildCompactActionButton(
                          icon: Icons.delete_rounded,
                          color: Colors.red,
                          onTap: () => _showDeleteConfirmation(index),
                        ),
                        _buildCompactActionButton(
                          icon:
                              medicine.isActive
                                  ? Icons.notifications_active
                                  : Icons.notifications_off,
                          color: medicine.isActive ? baseColor : Colors.grey,
                          onTap:
                              () => _toggleMedicineStatus(
                                index,
                                !medicine.isActive,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderTimesWidget(Medicine medicine, Color baseColor) {
    if (medicine.reminderTimes.isEmpty) {
      return Text(
        "بدون یادآوری",
        style: TextStyle(
          fontSize: 11,
          fontStyle: FontStyle.italic,
          color: Colors.black54,
        ),
      );
    }

    if (medicine.reminderTimes.length <= 2) {
      return Row(
        children:
            medicine.reminderTimes.map((time) {
              return Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  TimeFormatter.formatToShort(time),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: baseColor.withOpacity(0.9),
                  ),
                ),
              );
            }).toList(),
      );
    } else {
      return Text(
        "${medicine.reminderTimes.length} یادآوری",
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: baseColor.withOpacity(0.9),
        ),
      );
    }
  }

  Widget _buildCompactPillIcon(Medicine medicine, Color color) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 3),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.8), color],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(5),
            child: Image.asset(
              MedicineCardStyle.getImagePathByType(medicine.medicineType),
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
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

    // نام‌های ماه‌های شمسی
    final persianMonths = [
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

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMonthNavigationButton(
                  icon: Icons.chevron_left,
                  onPressed: _goToPreviousMonth,
                ),
                Column(
                  children: [
                    Text(
                      '${persianMonths[_selectedJalaliDate.month - 1]} ${_selectedJalaliDate.year}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (!isCurrentMonth)
                      TextButton(
                        onPressed: _goToCurrentMonth,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          minimumSize: Size(0, 0),
                          backgroundColor: Colors.white.withOpacity(0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'برگشت به ماه جاری',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                _buildMonthNavigationButton(
                  icon: Icons.chevron_right,
                  onPressed: _goToNextMonth,
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _weekDayLabel('ش'),
                _weekDayLabel('ی'),
                _weekDayLabel('د'),
                _weekDayLabel('س'),
                _weekDayLabel('چ'),
                _weekDayLabel('پ'),
                _weekDayLabel('ج'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthNavigationButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
        tooltip: icon == Icons.chevron_left ? 'ماه قبل' : 'ماه بعد',
        splashRadius: 24,
      ),
    );
  }

  void _goToPreviousMonth() {
    setState(() {
      if (_selectedJalaliDate.month == 1) {
        _selectedJalaliDate = Jalali(_selectedJalaliDate.year - 1, 12, 1);
      } else {
        _selectedJalaliDate = Jalali(
          _selectedJalaliDate.year,
          _selectedJalaliDate.month - 1,
          1,
        );
      }
    });
  }

  void _goToNextMonth() {
    setState(() {
      if (_selectedJalaliDate.month == 12) {
        _selectedJalaliDate = Jalali(_selectedJalaliDate.year + 1, 1, 1);
      } else {
        _selectedJalaliDate = Jalali(
          _selectedJalaliDate.year,
          _selectedJalaliDate.month + 1,
          1,
        );
      }
    });
  }

  void _goToCurrentMonth() {
    setState(() {
      _selectedJalaliDate = Jalali.fromDateTime(DateTime.now());
    });
  }

  Widget _weekDayLabel(String label) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
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
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  final hasMedicines = _hasMedicinesForDate(date);

                  return GestureDetector(
                    onTap: () => _selectDate(date),
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            _isSelectedDate(date)
                                ? Theme.of(context).colorScheme.primary
                                : isToday
                                ? Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.1)
                                : Colors.transparent,
                        shape: BoxShape.circle,
                        border:
                            isToday && !_isSelectedDate(date)
                                ? Border.all(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 1.5,
                                )
                                : null,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            day.toString(),
                            style: TextStyle(
                              color:
                                  _isSelectedDate(date)
                                      ? Colors.white
                                      : isToday
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.black87,
                              fontWeight:
                                  _isSelectedDate(date) || isToday
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                          ),
                          if (hasMedicines)
                            Positioned(
                              bottom: 6,
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color:
                                      _isSelectedDate(date)
                                          ? Colors.white
                                          : Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                  shape: BoxShape.circle,
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

  bool _isSelectedDate(Jalali date) {
    return date.year == _selectedJalaliDate.year && // اصلاح شده
        date.month == _selectedJalaliDate.month && // اصلاح شده
        date.day == _selectedJalaliDate.day; // اصلاح شده
  }

  void _selectDate(Jalali date) {
    setState(() {
      _selectedJalaliDate = date; // اصلاح شده
      _showDayMedicines(date);
    });
  }

  bool _hasMedicinesForDate(Jalali date) {
    // تبدیل تاریخ جلالی به میلادی
    final gregorianDate = date.toDateTime();
    final weekDay = gregorianDate.weekday % 7; // 0 for Saturday, 6 for Friday

    // بررسی وجود دارو برای روز هفته
    return medicines.any(
      (medicine) => medicine.isActive && medicine.weekDays.contains(weekDay),
    );
  }

  void _showDayMedicines(Jalali date) {
    // تبدیل تاریخ جلالی به میلادی
    final gregorianDate = date.toDateTime();
    final weekDay = gregorianDate.weekday % 7; // 0 for Saturday, 6 for Friday

    // فیلتر داروها برای روز انتخاب شده
    final dayMedicines =
        medicines
            .where(
              (medicine) =>
                  medicine.isActive && medicine.weekDays.contains(weekDay),
            )
            .toList();

    if (dayMedicines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('داروی فعالی برای این روز وجود ندارد'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // نمایش داروهای روز انتخاب شده
    _showDayMedicinesBottomSheet(date, weekDay, dayMedicines);
  }

  Widget _buildTodayMedicines() {
    final now = DateTime.now();
    final today = now.weekday % 7; // 0 for Saturday, 6 for Friday
    final todayMedicines =
        medicines
            .where(
              (medicine) =>
                  medicine.isActive && medicine.weekDays.contains(today),
            )
            .toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.today_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 22,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'داروهای امروز',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Text(
                  '${_getPersianWeekDay(now.weekday)} ${Jalali.fromDateTime(now).day} ${_getPersianMonth(Jalali.fromDateTime(now).month)}',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
            SizedBox(height: 16),
            todayMedicines.isEmpty
                ? _buildEmptyTodayMedicines()
                : Column(
                  children:
                      todayMedicines
                          .map((medicine) => _buildTodayMedicineItem(medicine))
                          .toList(),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyTodayMedicines() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 24),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 48,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16),
          Text(
            'امروز داروی فعالی ندارید',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'می‌توانید از صفحه داروها، داروی جدیدی اضافه کنید',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTodayMedicineItem(Medicine medicine) {
    final baseColor = MedicineCardStyle.getColorByType(medicine.medicineType);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: baseColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: baseColor.withOpacity(0.1)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: baseColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Image.asset(
            MedicineCardStyle.getImagePathByType(medicine.medicineType),
            width: 24,
            height: 24,
            color: baseColor,
          ),
        ),
        title: Text(
          medicine.name,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(medicine.dosage, style: TextStyle(fontSize: 14)),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time_rounded, size: 14, color: baseColor),
                SizedBox(width: 4),
                Text(
                  medicine.reminderTimes.isEmpty
                      ? "بدون یادآوری"
                      : medicine.reminderTimes
                          .map((t) => TimeFormatter.formatToShort(t))
                          .join(' - '),
                  style: TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                Icons.check_circle_outline,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () => _markAsTaken(medicine),
              tooltip: 'علامت‌گذاری به عنوان مصرف‌شده',
            ),
            IconButton(
              icon: Icon(Icons.info_outline, color: Colors.grey.shade600),
              onPressed: () => _viewMedicineDetails(medicine),
              tooltip: 'مشاهده جزئیات',
            ),
          ],
        ),
        onTap: () => _viewMedicineDetails(medicine),
      ),
    );
  }

  void _markAsTaken(Medicine medicine) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${medicine.name} به عنوان مصرف‌شده علامت‌گذاری شد'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'لغو',
          onPressed: () {
            // کد لغو علامت‌گذاری
          },
        ),
      ),
    );
  }

  void _viewMedicineDetails(Medicine medicine) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicineDetailPage(medicine: medicine),
      ),
    );
  }

  String _getPersianWeekDay(int weekDay) {
    final weekDays = [
      'دوشنبه',
      'سه‌شنبه',
      'چهارشنبه',
      'پنج‌شنبه',
      'جمعه',
      'شنبه',
      'یکشنبه',
    ];
    return weekDays[weekDay % 7];
  }

  String _getPersianMonth(int month) {
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

  void _showDayMedicinesBottomSheet(
    Jalali date,
    int weekDay,
    List<Medicine> dayMedicines,
  ) {
    final weekDays = [
      'شنبه',
      'یکشنبه',
      'دوشنبه',
      'سه‌شنبه',
      'چهارشنبه',
      'پنج‌شنبه',
      'جمعه',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        margin: EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Text(
                        'داروهای روز ${weekDays[weekDay]}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${date.day} ${_getPersianMonth(date.month)} ${date.year}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: dayMedicines.length,
                    itemBuilder: (context, index) {
                      final medicine = dayMedicines[index];
                      return _buildTodayMedicineItem(medicine);
                    },
                  ),
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
      child: Column(
        children: [
          _buildProfileHeader(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildQuickActions(),
                SizedBox(height: 20),
                _buildUserInfoSection(),
                SizedBox(height: 20),
                _buildHealthMetricsSection(),
                SizedBox(height: 20),
                _buildMedicationStatistics(),
                SizedBox(height: 20),
                _buildSettingsSection(),
                SizedBox(height: 20),
                _buildSupportSection(),
                SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: EdgeInsets.only(top: 30, bottom: 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Color.lerp(
              Theme.of(context).colorScheme.primary,
              Colors.purple,
              0.3,
            )!,
          ],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _editUserProfile,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(Icons.edit, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
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
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildQuickActionItem(Icons.medication_outlined, 'داروهای من', () {
          setState(() {
            _selectedIndex = 0;
          });
        }),
        _buildQuickActionItem(
          Icons.notifications_active_outlined,
          'یادآوری‌ها',
          _openNotificationSettings,
        ),
        _buildQuickActionItem(
          Icons.settings_outlined,
          'تنظیمات',
          _openThemeSettings,
        ),
      ],
    );
  }

  Widget _buildQuickActionItem(
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoSection() {
    return Card(
      elevation: 2,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: _editUserProfile,
                  child: Text('ویرایش'),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
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
      elevation: 2,
      shadowColor: Colors.black26,
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard(
                  Icons.medication_outlined,
                  'تعداد داروها',
                  '${medicines.length}',
                ),
                _buildStatCard(
                  Icons.notifications_active_outlined,
                  'یادآوری‌های فعال',
                  '${medicines.where((m) => m.isActive).length}',
                ),
                _buildStatCard(
                  Icons.calendar_today_outlined,
                  'داروهای روزانه',
                  '${_getDailyMedicinesCount()}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String title, String value) {
    return Container(
      width: 90,
      padding: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 10, color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Card(
      elevation: 2,
      shadowColor: Colors.black26,
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Divider(height: 24),
            _buildSettingItem(
              Icons.notifications_outlined,
              'تنظیمات اعلان‌ها',
              'مدیریت یادآوری‌ها',
              _openNotificationSettings,
            ),
            _buildSettingItem(
              Icons.color_lens_outlined,
              'تم برنامه',
              'تغییر ظاهر برنامه',
              _openThemeSettings,
            ),
            _buildSettingItem(
              Icons.backup_outlined,
              'پشتیبان‌گیری',
              'ذخیره و بازیابی اطلاعات',
              _openBackupSettings,
            ),
            _buildSettingItem(
              Icons.info_outline,
              'درباره برنامه',
              'اطلاعات نسخه و توسعه‌دهنده',
              _showAboutDialog,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 20, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportSection() {
    return Card(
      elevation: 2,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.support_agent,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: 8),
                Text(
                  'پشتیبانی',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Divider(height: 24),
            _buildSettingItem(
              Icons.help_outline,
              'راهنمای استفاده',
              'آموزش استفاده از برنامه',
              _showHelpDialog,
            ),
            _buildSettingItem(
              Icons.email_outlined,
              'تماس با پشتیبانی',
              'ارسال پیام به تیم پشتیبانی',
              _contactSupport,
            ),
            _buildSettingItem(
              Icons.star_outline,
              'امتیاز به برنامه',
              'نظر خود را با ما در میان بگذارید',
              _rateApp,
            ),
          ],
        ),
      ),
    );
  }

  void _contactSupport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('این قابلیت در نسخه‌های آینده اضافه خواهد شد'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _rateApp() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('این قابلیت در نسخه‌های آینده اضافه خواهد شد'),
        behavior: SnackBarBehavior.floating,
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

  void _openNotificationSettings() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('تنظیمات اعلان‌ها'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'برای عملکرد صحیح یادآوری‌ها، لطفا موارد زیر را بررسی کنید:',
                ),
                SizedBox(height: 12),
                _buildSettingCheckItem('اعلان‌ها در تنظیمات دستگاه فعال باشند'),
                _buildSettingCheckItem(
                  'برنامه از حالت بهینه‌سازی باتری خارج شده باشد',
                ),
                _buildSettingCheckItem(
                  'مجوز اجرای پس‌زمینه به برنامه داده شده باشد',
                ),
                SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await NotificationService.showImmediateNotification(
                      id: 9999,
                      title: 'تست اعلان',
                      body: 'این یک اعلان تست است برای بررسی عملکرد سیستم',
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'اعلان تست ارسال شد. اگر دریافت نکردید، تنظیمات دستگاه را بررسی کنید.',
                        ),
                        duration: Duration(seconds: 5),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('تست اعلان'),
                ),
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

  Widget _buildSettingCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, size: 18, color: Colors.green),
          SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(fontSize: 14))),
        ],
      ),
    );
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
      builder:
          (context) => AlertDialog(
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

  Widget _buildHealthMetricsSection() {
    return Card(
      elevation: 2,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.favorite_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'اطلاعات سلامتی',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'این قابلیت در نسخه‌های آینده اضافه خواهد شد',
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Text('افزودن'),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            Divider(height: 24),
            _buildHealthMetricItem(
              Icons.monitor_heart_outlined,
              'فشار خون',
              'تنظیم نشده',
            ),
            _buildHealthMetricItem(
              Icons.bloodtype_outlined,
              'قند خون',
              'تنظیم نشده',
            ),
            _buildHealthMetricItem(
              Icons.speed_outlined,
              'کلسترول',
              'تنظیم نشده',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthMetricItem(IconData icon, String title, String value) {
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
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _openMedicineDetails(Medicine medicine, int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicineDetailPage(medicine: medicine),
      ),
    );

    // اگر نتیجه برگشتی از صفحه جزئیات، یک دارو باشد (ویرایش شده)
    if (result != null && result is Medicine) {
      setState(() {
        medicines[index] = result;
      });
      await _saveMedicines();
    }
    // اگر نتیجه برگشتی "delete" باشد (حذف دارو)
    else if (result == 'delete') {
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
