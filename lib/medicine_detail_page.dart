import 'package:daroo/theme/medicine_card_style.dart';
import 'package:flutter/material.dart';
import 'medicine_model.dart';
import 'add_medicine_page.dart';
import 'utils/time_formatter.dart';
import 'notification_service.dart';

class MedicineDetailPage extends StatefulWidget {
  final Medicine medicine;

  const MedicineDetailPage({Key? key, required this.medicine})
    : super(key: key);

  @override
  _MedicineDetailPageState createState() => _MedicineDetailPageState();
}

class _MedicineDetailPageState extends State<MedicineDetailPage> {
  late Medicine _medicine;

  @override
  void initState() {
    super.initState();
    _medicine = widget.medicine;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('جزئیات دارو'),
        centerTitle: true,
        elevation: 4,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(), // حذف گوشه‌های گرد
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withOpacity(0.8),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: _editMedicine,
            tooltip: 'ویرایش دارو',
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMedicineHeader(),
              SizedBox(height: 24),
              _buildReminderTimesSection(),
              SizedBox(height: 24),
              _buildWeekDaysSection(),
              SizedBox(height: 24),
              _buildStatusToggle(),
              SizedBox(height: 32),
              _buildDeleteButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedicineHeader() {
    Color backgroundColor = MedicineCardStyle.getColorByType(
      _medicine.medicineType,
    );

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [backgroundColor, backgroundColor.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // آیکون دارو با افکت نئومورفیک
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      _getMedicineIcon(_medicine.medicineType),
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _medicine.name,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _medicine.dosage,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // اضافه کردن اطلاعات بیشتر در صورت نیاز
              if (_medicine.notes != null && _medicine.notes!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.notes, color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'یادداشت:',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          _medicine.notes!,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReminderTimesSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 26,
                ),
                SizedBox(width: 12),
                Text(
                  'زمان‌های یادآوری',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children:
                  _medicine.reminderTimes.map((time) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.alarm,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          SizedBox(width: 8),
                          Text(
                            TimeFormatter.formatTo12Hour(time),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekDaysSection() {
    final weekDays = [
      'شنبه',
      'یکشنبه',
      'دوشنبه',
      'سه‌شنبه',
      'چهارشنبه',
      'پنج‌شنبه',
      'جمعه',
    ];

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 26,
                ),
                SizedBox(width: 12),
                Text(
                  'روزهای هفته',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(7, (index) {
                  final isSelected = _medicine.weekDays.contains(index);
                  return Column(
                    children: [
                      AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey[200],
                          boxShadow:
                              isSelected
                                  ? [
                                    BoxShadow(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary.withOpacity(0.4),
                                      blurRadius: 8,
                                      offset: Offset(0, 3),
                                    ),
                                  ]
                                  : null,
                        ),
                        child: Center(
                          child: Text(
                            weekDays[index][0],
                            style: TextStyle(
                              color:
                                  isSelected ? Colors.white : Colors.grey[600],
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        weekDays[index],
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey[600],
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusToggle() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _medicine.isActive
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.05)
                  : Colors.grey.withOpacity(0.05),
              _medicine.isActive
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      _medicine.isActive
                          ? Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.15)
                          : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color:
                          _medicine.isActive
                              ? Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.2)
                              : Colors.transparent,
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  _medicine.isActive
                      ? Icons.notifications_active_rounded
                      : Icons.notifications_off_rounded,
                  color:
                      _medicine.isActive
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey,
                  size: 28,
                ),
              ),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'وضعیت یادآوری',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color:
                          _medicine.isActive
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    _medicine.isActive
                        ? 'یادآوری فعال است'
                        : 'یادآوری غیرفعال است',
                    style: TextStyle(
                      color:
                          _medicine.isActive
                              ? Colors.green[700]
                              : Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Spacer(),
              Transform.scale(
                scale: 1.2,
                child: Switch(
                  value: _medicine.isActive,
                  onChanged: (value) {
                    setState(() {
                      _medicine = Medicine(
                        id: _medicine.id,
                        name: _medicine.name,
                        dosage: _medicine.dosage,
                        medicineType: _medicine.medicineType,
                        reminderTimes: _medicine.reminderTimes,
                        weekDays: _medicine.weekDays,
                        startDate: _medicine.startDate,
                        endDate: _medicine.endDate,
                        isActive: value,
                        alarmTone: _medicine.alarmTone,
                      );
                    });

                    // اینجا باید کد مربوط به فعال/غیرفعال کردن اعلان‌ها اضافه شود
                    if (value) {
                      // فعال کردن اعلان‌ها
                      for (TimeOfDay time in _medicine.reminderTimes) {
                        NotificationService.scheduleNotification(
                          id: _medicine.id.hashCode % 10000,
                          title: 'یادآوری دارو: ${_medicine.name}',
                          body:
                              'زمان مصرف دارو با دوز ${_medicine.dosage} فرا رسیده است.',
                          time: time,
                          weekDays: _medicine.weekDays,
                        );
                      }
                    } else {
                      // غیرفعال کردن اعلان‌ها
                      NotificationService.cancelNotification(
                        _medicine.id.hashCode % 10000,
                      );
                    }
                  },
                  activeColor: Theme.of(context).colorScheme.primary,
                  activeTrackColor: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.4),
                  inactiveThumbColor: Colors.grey[400],
                  inactiveTrackColor: Colors.grey[300],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(Icons.delete_outline_rounded),
        label: Text(
          'حذف دارو',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        onPressed: _showDeleteConfirmation,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[600],
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 3,
        ),
      ),
    );
  }

  void _editMedicine() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMedicinePage(medicine: _medicine),
      ),
    );

    if (result != null && result is Medicine) {
      setState(() {
        _medicine = result;
      });

      // اطلاع به صفحه قبل که دارو ویرایش شده است
      Navigator.pop(context, _medicine);
    }
  }

  void _showDeleteConfirmation() {
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
                    _medicine.id.hashCode % 10000,
                  );
                  // برگشت به صفحه قبل با ارسال دستور حذف
                  Navigator.pop(context, {
                    'action': 'delete',
                    'medicine': _medicine,
                  });
                },
                child: Text('حذف', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  IconData _getMedicineIcon(String medicineType) {
    switch (medicineType) {
      case 'قرص':
        return Icons.tablet;
      case 'کپسول':
        return Icons.medication;
      case 'شربت':
        return Icons.local_drink;
      case 'آمپول':
        return Icons.vaccines;
      case 'پماد':
        return Icons.healing;
      case 'قطره':
        return Icons.opacity;
      case 'اسپری':
        return Icons.spa;
      default:
        return Icons.medical_services;
    }
  }
}
