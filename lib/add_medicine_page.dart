import 'package:daroo/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as PersianDateTimePicker;
import 'medicine_model.dart';
import 'utils/time_formatter.dart';
import 'notification_service.dart'; // استفاده از سرویس اعلان

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
  final _notesController = TextEditingController();
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
    {'id': 'notification_sound', 'name': 'صدای پیش‌فرض'},
    // فعلاً فقط از صدای پیش‌فرض استفاده می‌کنیم تا فایل‌های صوتی اضافه شوند
    // {'id': 'alarm_sound', 'name': 'زنگ هشدار'},
    // {'id': 'bell', 'name': 'زنگ'},
    // {'id': 'chime', 'name': 'ناقوس'},
  ];

  // مقدار پیش‌فرض برای صدای آلارم

  @override
  void initState() {
    super.initState();
    // تنظیم زمان شروع با ساعت فعلی سیستم
    final now = TimeOfDay.now();
    _startTime = now;

    // تنظیم مقدار پیش‌فرض آلارم به مقداری که در لیست وجود دارد
    _selectedAlarmTone = 'notification_sound';

    if (widget.medicine != null) {
      _nameController.text = widget.medicine!.name;
      _dosageController.text = widget.medicine!.dosage;
      _selectedMedicineType = widget.medicine!.medicineType;
      _selectedTimes = List.from(widget.medicine!.reminderTimes);
      _selectedDays = List.from(widget.medicine!.weekDays);

      // بررسی اینکه آیا مقدار alarmTone در لیست _alarmTones وجود دارد
      final alarmExists = _alarmTones.any(
        (tone) => tone['id'] == widget.medicine!.alarmTone,
      );
      _selectedAlarmTone =
          alarmExists ? widget.medicine!.alarmTone : 'notification_sound';
    }
  }

  @override
  void dispose() {
    // آزادسازی کنترلرها
    _nameController.dispose();
    _dosageController.dispose();
    _notesController.dispose();
    
    // لغو هرگونه عملیات غیرهمزمان در حال اجرا
    // اگر از Future یا Timer استفاده می‌کنید، آنها را لغو کنید
    
    super.dispose();
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
    // لیست انواع دارو با تصویر مناسب
    final medicineTypes = [
      {'label': 'قرص', 'value': 'قرص', 'image': 'assets/images/ghors.png'},
      {
        'label': 'کپسول',
        'value': 'کپسول',
        'image': 'assets/images/capsule.png',
      },
      {'label': 'شربت', 'value': 'شربت', 'image': 'assets/images/syrup.png'},
      {
        'label': 'آمپول',
        'value': 'آمپول',
        'image': 'assets/images/syringe.png',
      },
      {'label': 'پماد', 'value': 'پماد', 'image': 'assets/images/ointment.png'},
      {'label': 'قطره', 'value': 'قطره', 'image': 'assets/images/eyedrops.png'},
      {
        'label': 'اسپری',
        'value': 'اسپری',
        'image': 'assets/images/medicine.png',
      }, // تغییر به تصویر موجود
      {'label': 'سایر', 'value': 'سایر', 'image': 'assets/images/all.png'},
    ];

    return SizedBox(
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
                  type['image'] as String,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineTypeItem(String label, String value, String imagePath) {
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
          color:
              isSelected ? AppColors.primary.withOpacity(0.15) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, width: 24, height: 24),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.grey.shade800 : Colors.grey.shade800,
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
          children:
              _selectedTimes.map((time) {
                return Container(
                  margin: EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.alarm, color: AppColors.primary),
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
                  color: isSelected ? AppColors.primary : AppColors.background,
                  boxShadow:
                      isSelected
                          ? [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ]
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

  void _saveMedicine() async {
    if (_formKey.currentState!.validate()) {
      // بررسی مجوز اعلان‌های دقیق
      bool hasPermission =
          await NotificationService.checkExactAlarmPermission();

      if (!mounted) return; // بررسی وضعیت ویجت قبل از استفاده از context

      if (!hasPermission) {
        // نمایش دیالوگ درخواست مجوز
        bool permissionGranted = await _showPermissionRequestDialog();
        
        if (!mounted) return; // بررسی مجدد وضعیت ویجت
        
        if (!permissionGranted) {
          // اگر کاربر مجوز را نداد، پیام هشدار نمایش دهید
          _showErrorSnackBar(
            'بدون مجوز اعلان‌های دقیق، یادآوری‌ها ممکن است به درستی کار نکنند',
          );
        }
      }

      // ایجاد شناسه منحصر به فرد برای دارو
      final id = DateTime.now().millisecondsSinceEpoch % 0x7FFFFFFF;

      final medicine = Medicine(
        id: id.toString(),
        name: _nameController.text,
        dosage: _dosageController.text,
        reminderTimes: _selectedTimes,
        weekDays: _selectedDays,
        notes: _notesController.text,
        isActive: true,
        alarmTone: _selectedAlarmTone,
        medicineType: _selectedMedicineType,
        startDate: DateTime.now(),
      );

      // تنظیم آلارم‌ها برای دارو
      if (medicine.isActive && medicine.reminderTimes.isNotEmpty) {
        // همچنان از اعلان‌ها نیز استفاده می‌کنیم
        for (var time in medicine.reminderTimes) {
          int baseId = int.parse(medicine.id) % 0x7FFFFFFF;
          int notificationId = baseId + medicine.reminderTimes.indexOf(time);
          
          await NotificationService.scheduleNotification(
            id: notificationId,
            title: 'یادآوری دارو: ${medicine.name}',
            body: 'زمان مصرف دارو با دوز ${medicine.dosage} فرا رسیده است.',
            time: time,
            weekDays: medicine.weekDays,
            sound: medicine.alarmTone,
          );
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('یادآوری دارو با موفقیت تنظیم شد'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      
      // برگرداندن دارو به صفحه اصلی
      Navigator.pop(context, medicine);
    }
  }

  Future<bool> _showPermissionRequestDialog() async {
    bool? result = await showDialog<bool>(
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
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: Text('بعد'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context, true);
                  await NotificationService.requestExactAlarmPermission();
                },
                child: Text('باز کردن تنظیمات'),
              ),
            ],
          ),
    );

    return result ?? false;
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
