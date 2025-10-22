import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'prompts.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _fln =
      FlutterLocalNotificationsPlugin();

  /// ✅ Khởi tạo plugin thông báo
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

    // 👇 Khởi tạo với callback khi nhấn vào thông báo
    await _fln.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Khi user nhấn thông báo
        debugPrint('🔔 Notification tapped: ${response.payload}');
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // Tạo notification channel riêng cho Android
    const androidChannel = AndroidNotificationChannel(
      'daily_journal_channel',
      'Daily Journal',
      description: 'Nhắc bạn viết nhật ký hằng ngày ☕',
      importance: Importance.max,
    );

    final androidPlugin = _fln
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(androidChannel);

    // 👇 Xin quyền hiển thị nếu Android 13+
    await androidPlugin?.requestNotificationsPermission();

    if (Platform.isIOS) {
      await _fln
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  // ---------------------------------------------------------------------------
  // 🕒 Lên lịch nhắc hằng ngày
  // ---------------------------------------------------------------------------
  Future<void> scheduleDaily({required int hour, required int minute}) async {
    if (kIsWeb) return;

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_journal_channel',
        'Daily Journal',
        channelDescription: 'Nhắc bạn viết nhật ký hằng ngày ☕',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
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

    // 🕒 Log ra console để xem thời gian schedule
    print('🕒 Scheduling notification for $next | quote: $quote');

    try {
      await _fln.zonedSchedule(
        1001,
        'Nhật ký hôm nay ☕',
        quote,
        next,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } on PlatformException catch (e) {
      if (e.code == 'exact_alarms_not_permitted') {
        // ⏳ Nếu không có quyền exact alarm → fallback sang nhắc định kỳ
        await _fln.periodicallyShow(
          1001,
          'Nhật ký hôm nay ☕',
          quote,
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

  /// 🔔 Lên lịch nhắc hằng ngày (mặc định 21:00)
  Future<void> scheduleDailyReminder({int hour = 21, int minute = 0}) async {
    return scheduleDaily(hour: hour, minute: minute);
  }

  Future<void> cancelAll() async {
    return cancelDaily();
  }

  /// 🔔 Hiển thị thông báo ngay lập tức (khi app đang mở )
  Future<void> showInstant() async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_journal_channel',
        'Daily Journal',
        channelDescription: 'Hiển thị ngay cả khi app đang mở',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _fln.show(
      999,
      '📖 Nhắc nhở viết nhật ký',
      'Đã đến lúc ghi lại một chút cảm xúc 💌',
      details,
    );
  }
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  debugPrint('🔕 Background tap: ${response.payload}');
}
