import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static const _keyIsCalendarView = 'isCalendarView';
  static Future<void> saveViewMode(bool isCalendar) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsCalendarView, isCalendar);
  }

  static Future<bool> loadViewMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsCalendarView) ?? false;
  }
}
