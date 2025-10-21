// lib/core/notification_service.dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
// 👇 Thêm import này để lấy câu nhắc ngẫu nhiên
import 'prompts.dart';

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _fln =
      FlutterLocalNotificationsPlugin();

  /// Khởi tạo plugin thông báo
  Future<void> init() async {
    if (kIsWeb) return;

    tz.initializeTimeZones(); // nạp dữ liệu muối giờ

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestAlertPermission: true,
      requestBadgePermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidInit, // androi
      iOS: iosInit, // ios
    );

    await _fln.initialize(initSettings);

    if (Platform.isIOS) {
      await _fln
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }

    // Android 13+: POST_NOTIFICATIONS (plugin tự xử lý nếu cần).
  }

  //  Lên lịch nhắc hằng ngày
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

    // 🌿 Lấy 1 câu quote ngẫu nhiên làm nội dung thông báo
    final quote = Prompts.randomQuote();

    try {
      await _fln.zonedSchedule(
        1001,
        'Nhật ký hôm nay ☕',
        quote, // dùng quote thay vì text cố định
        next,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } on PlatformException catch (e) {
      if (e.code == 'exact_alarms_not_permitted') {
        // Nếu không có quyền exact alarm → fallback sang nhắc định kỳ (inexact)
        await _fln.periodicallyShow(
          1001,
          'Nhật ký hôm nay ☕',
          quote, // vẫn dùng quote
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
