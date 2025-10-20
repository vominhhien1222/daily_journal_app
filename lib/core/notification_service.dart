import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _fln =
      FlutterLocalNotificationsPlugin();

  /// 🔹 Khởi tạo plugin
  Future<void> init() async {
    if (kIsWeb) return;

    tz.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestAlertPermission: true,
      requestBadgePermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _fln.initialize(initSettings);

    if (Platform.isIOS) {
      await _fln
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }

    // Android 13+: quyền POST_NOTIFICATIONS → plugin sẽ tự xử lý
  }

  /// 🔔 Lên lịch nhắc hằng ngày (21:00 mặc định)
  Future<void> scheduleDaily({required int hour, required int minute}) async {
    if (kIsWeb) return;

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_journal_channel',
        'Daily Journal',
        channelDescription: 'Nhắc bạn viết nhật ký hằng ngày ☕',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    final now = tz.TZDateTime.now(tz.local);
    var next = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (next.isBefore(now)) next = next.add(const Duration(days: 1));

    try {
      await _fln.zonedSchedule(
        1001,
        'Nhật ký hôm nay ☕',
        'Viết vài dòng về cảm xúc trong ngày nhé 💌',
        next,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } on PlatformException catch (e) {
      if (e.code == 'exact_alarms_not_permitted') {
        // Nếu không có quyền exact alarm → fallback sang định kỳ
        await _fln.periodicallyShow(
          1001,
          'Nhật ký hôm nay ☕',
          'Đừng quên ghi lại cảm xúc của bạn nhé 💭',
          RepeatInterval.daily,
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      } else {
        rethrow;
      }
    }
  }

  /// ❌ Hủy thông báo đã lên lịch
  Future<void> cancelDaily() async {
    if (kIsWeb) return;
    await _fln.cancel(1001);
  }

  // ---------------------------------------------------------------------------
  // ✅ Wrapper cho tương thích với SettingsProvider cũ
  // ---------------------------------------------------------------------------

  Future<void> scheduleDailyReminder({int hour = 21, int minute = 0}) async {
    return scheduleDaily(hour: hour, minute: minute);
  }

  Future<void> cancelAll() async {
    return cancelDaily();
  }
}
