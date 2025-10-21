import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../core/notification_service.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _boxName = 'settingsBox';
  static const String _darkModeKey = 'darkMode';
  static const String _reminderEnabledKey = 'reminderEnabled';
  static const String _reminderHourKey = 'reminderHour';
  static const String _reminderMinuteKey = 'reminderMinute';

  bool _darkMode = false;
  bool get darkMode => _darkMode;

  bool _reminderEnabled = true;
  bool get reminderEnabled => _reminderEnabled;

  TimeOfDay _reminderTime = const TimeOfDay(hour: 21, minute: 0);
  TimeOfDay get reminderTime => _reminderTime;

  String get reminderTimeLabel =>
      '${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}';

  /// 🔹 Load cài đặt mặc định (gọi ở App khởi tạo)
  Future<void> loadDefaults() async {
    final box = await Hive.openBox(_boxName);

    _darkMode = box.get(_darkModeKey, defaultValue: false);
    _reminderEnabled = box.get(_reminderEnabledKey, defaultValue: true);
    final hour = box.get(_reminderHourKey, defaultValue: 21);
    final minute = box.get(_reminderMinuteKey, defaultValue: 0);
    _reminderTime = TimeOfDay(hour: hour, minute: minute);

    // ✅ Khi app khởi động, nếu bật nhắc nhở thì lên lịch lại
    if (_reminderEnabled) {
      NotificationService.instance.scheduleDailyReminder(
        hour: _reminderTime.hour,
        minute: _reminderTime.minute,
      );
    }

    notifyListeners();
  }

  /// 🌙 Toggle chế độ tối / sáng
  Future<void> toggleDarkMode() async {
    _darkMode = !_darkMode;
    final box = await Hive.openBox(_boxName);
    await box.put(_darkModeKey, _darkMode);
    notifyListeners();
  }

  /// 🔔 Toggle bật / tắt nhắc nhở
  Future<void> toggleReminder(bool enabled) async {
    _reminderEnabled = enabled;
    final box = await Hive.openBox(_boxName);
    await box.put(_reminderEnabledKey, _reminderEnabled);

    if (_reminderEnabled) {
      await NotificationService.instance.scheduleDailyReminder(
        hour: _reminderTime.hour,
        minute: _reminderTime.minute,
      );
    } else {
      await NotificationService.instance.cancelAll();
    }

    notifyListeners();
  }

  /// 🕒 Cập nhật giờ nhắc nhở
  Future<void> updateReminderTime(TimeOfDay newTime) async {
    _reminderTime = newTime;
    final box = await Hive.openBox(_boxName);
    await box.put(_reminderHourKey, newTime.hour);
    await box.put(_reminderMinuteKey, newTime.minute);

    if (_reminderEnabled) {
      await NotificationService.instance.cancelAll();
      await NotificationService.instance.scheduleDailyReminder(
        hour: _reminderTime.hour,
        minute: _reminderTime.minute,
      );
    }

    notifyListeners();
  }

  /// 🔹 Áp dụng theme cho toàn app
  ThemeMode get themeMode => _darkMode ? ThemeMode.dark : ThemeMode.light;

  /// 🌙 Kiểm tra đang ở Dark Mode không (dùng cho SplashScreen)
  bool get isDarkMode => _darkMode;
}
