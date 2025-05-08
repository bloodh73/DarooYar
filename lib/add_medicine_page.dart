import 'package:daroo/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as PersianDateTimePicker;
import 'package:uuid/uuid.dart';
import 'medicine_model.dart';
import 'utils/time_formatter.dart';

class AddMedicinePage extends StatefulWidget {
  final Medicine? medicine; // برای ویرایش دارو

  AddMedicinePage({this.medicine});

  @override
  _AddMedicinePageState createState() => _AddMedicinePageState();
}

class _AddMedicinePageState extends State<AddMedicinePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  String _selectedMedicineType = 'قرص';
  String _selectedAlarmTone = 'default';
  List<TimeOfDay> _selectedTimes = [];
  List<int> _selectedDays = [0, 1, 2, 3, 4, 5, 6];

  // متغیرهای جدید برای حالت هر چند ساعت
  bool _isIntervalMode = false;
  int _hourInterval = 4; // پیش‌فرض هر 4 ساعت
  TimeOfDay _startTime = TimeOfDay(hour: 8, minute: 0); // زمان شروع

  // انواع دارو

  // زنگ‌های هشدار

  // نام‌های روزهای هفته به فارسی
  final List<String> _weekDaysShort = ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج'];

  // Make sure each alarm tone has a unique ID
  final List<Map<String, String>> _alarmTones = [
    {'id': 'default', 'name': 'صدای پیش‌فرض'},
    {'id': 'alarm_sound', 'name': 'زنگ هشدار'},
    {'id': 'bell', 'name': 'زنگ'},
    {'id': 'chime', 'name': 'ناقوس'},
    // Make sure no other items use 'default' as their id
  ];

  @override
  void initState() {
    super.initState();
    if (widget.medicine != null) {
      _nameController.text = widget.medicine!.name;
      _dosageController.text = widget.medicine!.dosage;
      _selectedMedicineType = widget.medicine!.medicineType;
      _selectedTimes = List.from(widget.medicine!.reminderTimes);
      _selectedDays = List.from(widget.medicine!.weekDays);
      _selectedAlarmTone = widget.medicine!.alarmTone;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.medicine == null ? 'افزودن داروی جدید' : 'ویرایش دارو',
        ),
        elevation: 0,
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
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('اطلاعات دارو'),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'نام دارو',
                            prefixIcon: Icon(Icons.medication),
                            hintText: 'مثال: آموکسی‌سیلین',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'لطفا نام دارو را وارد کنید';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _dosageController,
                          decoration: InputDecoration(
                            labelText: 'توضیحات',
                            prefixIcon: Icon(Icons.medical_information),
                            hintText: 'مثال: قبل از غذا',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'لطفا توضیحات را وارد کنید';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        _buildMedicineTypeSelector(),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                _buildSectionTitle('زمان‌های یادآوری'),
                _buildReminderTimeSection(), // استفاده از متد جدید
                SizedBox(height: 24),
                _buildSectionTitle('روزهای هفته'),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: _buildWeekDaysSelector(),
                  ),
                ),
                SizedBox(height: 32),
                _buildAlarmToneSelector(),
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _saveMedicine,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.inverseSurface,
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      widget.medicine == null ? 'افزودن دارو' : 'ذخیره تغییرات',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8, right: 4),
      child: Row(
        children: [
          Icon(
            _getSectionIcon(title),
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSectionIcon(String title) {
    switch (title) {
      case 'اطلاعات دارو':
        return Icons.medication;
      case 'زمان‌های یادآوری':
        return Icons.access_time;
      case 'روزهای هفته':
        return Icons.calendar_today;
      default:
        return Icons.info;
    }
  }

  Widget _buildMedicineTypeSelector() {
    // لیست انواع دارو با آیکون مناسب
    final medicineTypes = [
      {'label': 'قرص', 'value': 'Tablet', 'icon': Icons.tablet},
      {'label': 'کپسول', 'value': 'Capsule', 'icon': Icons.medication},
      {'label': 'شربت', 'value': 'Liquid', 'icon': Icons.local_drink},
      {'label': 'آمپول', 'value': 'Pill', 'icon': Icons.vaccines},
      {'label': 'پماد', 'value': 'Cream', 'icon': Icons.healing},
      {'label': 'قطره', 'value': 'Drop', 'icon': Icons.opacity},
      {'label': 'اسپری', 'value': 'Spray', 'icon': Icons.spa},
      {'label': 'سایر', 'value': 'Other', 'icon': Icons.medical_services},
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade50,
      ),
      height: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'نوع دارو',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          SizedBox(height: 8),
          Expanded(
            child: GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1.0,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: medicineTypes.length,
              itemBuilder: (context, index) {
                final type = medicineTypes[index];
                return _buildMedicineTypeItem(
                  type['label'] as String,
                  type['value'] as String,
                  type['icon'] as IconData,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineTypeItem(String label, String value, IconData icon) {
    final isSelected = _selectedMedicineType == value;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedMedicineType = value;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.15)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : Colors.grey.shade300,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.primary
                  : Colors.grey.shade600,
              size: 24,
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? AppColors.primary
                    : Colors.grey.shade800,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderTimesList() {
    return _selectedTimes.isEmpty
        ? Center(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'هیچ زمان یادآوری تنظیم نشده است',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        )
        : Column(
          children: _selectedTimes.map((time) {
            return Container(
              margin: EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(
                  Icons.alarm,
                  color: AppColors.primary,
                ),
                title: Text(
                  TimeFormatter.formatTo12Hour(time),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _selectedTimes.remove(time);
                    });
                  },
                ),
              ),
            );
          }).toList(),
        );
  }

  Widget _buildWeekDaysSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'روزهای یادآوری را انتخاب کنید:',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: List.generate(7, (index) {
            final isSelected = _selectedDays.contains(index);

            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedDays.remove(index);
                  } else {
                    _selectedDays.add(index);
                  }
                });
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected 
                      ? AppColors.primary
                      : AppColors.background,
                  boxShadow: isSelected 
                      ? [BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        )] 
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  _weekDaysShort[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildReminderTimeSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // سوئیچ برای انتخاب حالت زمان‌بندی
            Row(
              children: [
                Expanded(
                  child: Text(
                    'حالت زمان‌بندی:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Row(
                  children: [
                    Text('زمان‌های مشخص'),
                    Switch(
                      value: _isIntervalMode,
                      onChanged: (value) {
                        setState(() {
                          _isIntervalMode = value;
                          if (value) {
                            // در حالت فاصله زمانی، زمان‌های قبلی را پاک می‌کنیم
                            _selectedTimes.clear();
                            _generateTimesFromInterval();
                          }
                        });
                      },
                      activeColor: Theme.of(context).colorScheme.primary,
                    ),
                    Text('هر چند ساعت'),
                  ],
                ),
              ],
            ),

            SizedBox(height: 16),

            // نمایش بخش مناسب بر اساس حالت انتخاب شده
            _isIntervalMode
                ? _buildIntervalSelector()
                : _buildManualTimeSelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildIntervalSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'زمان شروع:',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
        ),
        SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await PersianDateTimePicker.showTimePicker(
              context: context,
              initialTime: _startTime,
              builder: (BuildContext context, Widget? child) {
                return Theme(
                  data: ThemeData(
                    primaryColor: Theme.of(context).colorScheme.primary,
                    colorScheme: ColorScheme.light(
                      primary: Theme.of(context).colorScheme.primary,
                    ),
                    textButtonTheme: TextButtonThemeData(
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    timePickerTheme: TimePickerThemeData(
                      hourMinuteTextStyle: TextStyle(fontSize: 18),
                    ),
                  ),
                  child: MediaQuery(
                    data: MediaQuery.of(
                      context,
                    ).copyWith(alwaysUse24HourFormat: false),
                    child: child!,
                  ),
                );
              },
            );

            if (picked != null) {
              setState(() {
                _startTime = picked;
                _generateTimesFromInterval();
              });
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: 8),
                Text(
                  TimeFormatter.formatTo12Hour(_startTime),
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 16),

        Text(
          'فاصله زمانی (ساعت):',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: _hourInterval.toDouble(),
                min: 1,
                max: 12,
                divisions: 11,
                label: '$_hourInterval ساعت',
                onChanged: (value) {
                  setState(() {
                    _hourInterval = value.toInt();
                    _generateTimesFromInterval();
                  });
                },
              ),
            ),
            Container(
              width: 50,
              child: Text(
                '$_hourInterval',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),

        SizedBox(height: 16),

        Text(
          'زمان‌های تولید شده:',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
        ),
        SizedBox(height: 8),
        _buildReminderTimesList(),
      ],
    );
  }

  Widget _buildManualTimeSelector() {
    return Column(
      children: [
        _buildReminderTimesList(),
        SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _addNewTime,
          icon: Icon(Icons.add_alarm),
          label: Text('افزودن زمان یادآوری'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  void _generateTimesFromInterval() {
    _selectedTimes.clear();

    // ساعت شروع
    int startHour = _startTime.hour;
    int startMinute = _startTime.minute;

    // تولید زمان‌ها با فاصله مشخص شده
    for (int i = 0; i < 24; i += _hourInterval) {
      int hour = (startHour + i) % 24;
      TimeOfDay time = TimeOfDay(hour: hour, minute: startMinute);
      _selectedTimes.add(time);

      // اگر به انتهای روز رسیدیم، خارج شویم
      if ((startHour + i + _hourInterval) >= (startHour + 24)) {
        break;
      }
    }

    // مرتب‌سازی زمان‌ها
    _selectedTimes.sort((a, b) {
      if (a.hour != b.hour) {
        return a.hour - b.hour;
      }
      return a.minute - b.minute;
    });
  }

  void _addNewTime() async {
    final picked = await PersianDateTimePicker.showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData(
            primaryColor: Theme.of(context).colorScheme.primary,
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
            timePickerTheme: TimePickerThemeData(
              hourMinuteTextStyle: TextStyle(fontSize: 18),
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            child: child!,
          ),
        );
      },
    );

    if (picked != null) {
      // بررسی تکراری نبودن زمان
      bool isDuplicate = false;
      for (var existingTime in _selectedTimes) {
        if (existingTime.hour == picked.hour &&
            existingTime.minute == picked.minute) {
          isDuplicate = true;
          break;
        }
      }

      if (isDuplicate) {
        _showErrorSnackBar('این زمان قبلاً اضافه شده است');
      } else {
        setState(() {
          _selectedTimes.add(picked);
          // مرتب‌سازی زمان‌ها بر اساس ساعت و دقیقه
          _selectedTimes.sort((a, b) {
            if (a.hour != b.hour) {
              return a.hour - b.hour;
            }
            return a.minute - b.minute;
          });
        });
      }
    }
  }

  Widget _buildAlarmToneSelector() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'صدای آلارم',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedAlarmTone,
                  items:
                      _alarmTones.map((tone) {
                        return DropdownMenuItem<String>(
                          value: tone['id'],
                          child: Row(
                            children: [
                              Icon(
                                Icons.music_note,
                                color: Theme.of(context).colorScheme.primary,
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Text(tone['name']!),
                            ],
                          ),
                        );
                      }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedAlarmTone = value;
                      });
                      // پخش صدای نمونه
                      _playAlarmSample(value);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // پخش نمونه صدای آلارم
  void _playAlarmSample(String alarmId) {
    // اینجا می‌توانید کد پخش صدای نمونه را اضافه کنید
    // برای مثال با استفاده از پکیج audioplayers
  }

  void _saveMedicine() {
    if (_formKey.currentState!.validate()) {
      if (_selectedTimes.isEmpty) {
        _showErrorSnackBar('لطفا حداقل یک زمان یادآوری انتخاب کنید');
        return;
      }

      if (_selectedDays.isEmpty) {
        _showErrorSnackBar('لطفا حداقل یک روز هفته را انتخاب کنید');
        return;
      }

      final medicine = Medicine(
        id: widget.medicine?.id ?? Uuid().v4(),
        name: _nameController.text,
        dosage: _dosageController.text,
        medicineType: _selectedMedicineType,
        reminderTimes: _selectedTimes,
        weekDays: _selectedDays,
        startDate: DateTime.now(),
        isActive: widget.medicine?.isActive ?? true,
        alarmTone: _selectedAlarmTone,
      );

      Navigator.pop(context, medicine);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: EdgeInsets.all(16),
      ),
    );
  }
}
