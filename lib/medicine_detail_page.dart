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
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMedicineHeader(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildReminderTimesSection(),
                  SizedBox(height: 16),
                  _buildWeekDaysSection(),
                  SizedBox(height: 16),
                  _buildStatusToggle(),
                  SizedBox(height: 24),
                  _buildDeleteButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineHeader() {
    final backgroundColor = MedicineCardStyle.getColorByType(
      _medicine.medicineType,
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [backgroundColor, backgroundColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Hero(
                    tag: 'medicine-icon-${_medicine.id}',
                    child: Container(
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
                      ),
                      child: Icon(
                        MedicineCardStyle.getIconByType(_medicine.medicineType),
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
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
                            _medicine.medicineType,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoItem(Icons.straighten, 'دوز', _medicine.dosage),
                  _buildInfoItem(
                    Icons.calendar_today,
                    'شروع',
                    _formatDate(_medicine.startDate),
                  ),
                  _buildInfoItem(Icons.repeat, 'تکرار', _getRepeatText()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildReminderTimesSection() {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    Icons.access_time_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 22,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'زمان‌های یادآوری',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children:
                  _medicine.reminderTimes.map((time) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.alarm,
                            size: 18,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          SizedBox(width: 6),
                          Text(
                            TimeFormatter.formatTo12Hour(time),
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
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
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    Icons.calendar_today_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 22,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'روزهای هفته',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(7, (index) {
                  final isSelected = _medicine.weekDays.contains(index);
                  return Column(
                    children: [
                      AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        width: 36,
                        height: 36,
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
                                      ).colorScheme.primary.withOpacity(0.3),
                                      blurRadius: 6,
                                      offset: Offset(0, 2),
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
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        weekDays[index],
                        style: TextStyle(
                          fontSize: 10,
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
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    _medicine.isActive
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _medicine.isActive
                    ? Icons.notifications_active_rounded
                    : Icons.notifications_off_rounded,
                color:
                    _medicine.isActive
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                size: 22,
              ),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'وضعیت یادآوری',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  _medicine.isActive
                      ? 'یادآوری فعال است'
                      : 'یادآوری غیرفعال است',
                  style: TextStyle(
                    color:
                        _medicine.isActive
                            ? Colors.green[700]
                            : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            Spacer(),
            Switch(
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

                if (value) {
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
                  NotificationService.cancelNotification(
                    _medicine.id.hashCode % 10000,
                  );
                }
              },
              activeColor: Theme.of(context).colorScheme.primary,
              activeTrackColor: Theme.of(
                context,
              ).colorScheme.primary.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
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
                        Navigator.pop(
                          context,
                          'delete',
                        ); // برگشت به صفحه قبل با نتیجه حذف
                      },
                      child: Text('حذف', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
          );
        },
        icon: Icon(Icons.delete_outline, color: Colors.white),
        label: Text(
          'حذف دارو',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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

  String _getRepeatText() {
    if (_medicine.weekDays.length == 7) {
      return "هر روز";
    } else if (_medicine.weekDays.isEmpty) {
      return "هیچ روز";
    } else {
      return "${_medicine.weekDays.length} روز در هفته";
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}/${date.month}/${date.day}";
  }
}
