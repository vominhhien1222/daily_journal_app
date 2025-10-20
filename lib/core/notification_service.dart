import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _fln = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // ❗ Nếu đang chạy trên web → bỏ qua (web không hỗ trợ plugin này)
    if (kIsWeb) return;

    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const ios = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestAlertPermission: true,
      requestBadgePermission: true,
    );

    const initSettings = InitializationSettings(android: android, iOS: ios);

    await _fln.initialize(initSettings);

    // ✅ Chỉ xin quyền trên iOS thật (không phải web)
    if (!kIsWeb && Platform.isIOS) {
      await _fln
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  /// 🔔 Đặt lịch nhắc hằng ngày
  Future<void> scheduleDaily({required int hour, required int minute}) async {
    // Nếu đang chạy Web thì bỏ qua
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

    await _fln.zonedSchedule(
      1001,
      'Nhật ký hôm nay ☕',
      'Viết vài dòng về cảm xúc trong ngày nhé.',
      next,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // 🔁 Lặp mỗi ngày
    );
  }

  /// ❌ Hủy lịch nhắc
  Future<void> cancelDaily() async {
    if (kIsWeb) return;
    await _fln.cancel(1001);
  }
}
