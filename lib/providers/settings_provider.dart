import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _boxName = 'settingsBox';
  static const String _darkModeKey = 'darkMode';

  bool _darkMode = false;
  bool get darkMode => _darkMode;

  /// 🔹 Load cài đặt mặc định (gọi ở App khởi tạo)
  Future<void> loadDefaults() async {
    final box = await Hive.openBox(_boxName);
    _darkMode = box.get(_darkModeKey, defaultValue: false);
    notifyListeners();
  }

  /// 🔹 Toggle chế độ tối / sáng
  Future<void> toggleDarkMode() async {
    _darkMode = !_darkMode;
    final box = await Hive.openBox(_boxName);
    await box.put(_darkModeKey, _darkMode);
    notifyListeners();
  }

  /// 🔹 Áp dụng theme cho toàn app
  ThemeMode get themeMode => _darkMode ? ThemeMode.dark : ThemeMode.light;
}
