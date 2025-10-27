import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
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

    // 🕒 Khởi tạo timezone
    tz.initializeTimeZones();
    try {
      final name =
          await FlutterTimezone.getLocalTimezone(); // (bản 2.0.1 trả về String)
      tz.setLocalLocation(tz.getLocation(name));
      debugPrint("🌏 Timezone set: $name");
    } catch (e) {
      debugPrint('⚠️ Không lấy được timezone, dùng mặc định: $e');
    }

    // ⚙️ Cấu hình khởi tạo
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

    // 🔔 Khởi tạo plugin và callback khi nhấn vào thông báo
    await _fln.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        debugPrint('🔔 Notification tapped: ${response.payload}');
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // 📣 Tạo notification channel riêng cho Android
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

    // 📱 Xin quyền thông báo Android 13+
    await androidPlugin?.requestNotificationsPermission();

    // 🍏 iOS: xin quyền thông báo
    if (Platform.isIOS) {
      await _fln
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }

    // 🚀 Kiểm tra nếu app được mở từ notification
    final details = await _fln.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp ?? false) {
      final payload = details!.notificationResponse?.payload;
      debugPrint('🚀 App mở từ notification với payload: $payload');
    }
  }

  /// ⏰ Lên lịch thông báo hằng ngày vào giờ phút cụ thể
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
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
        presentBadge: true,
      ),
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

    debugPrint('🕒 Scheduling notification for $next | quote: $quote');

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
        debugPrint("❌ Lỗi khi schedule: $e");
        rethrow;
      }
    }
  }

  /// 🗓️ Lên lịch nhắc hằng ngày mặc định (21:00)
  Future<void> scheduleDailyReminder({int hour = 21, int minute = 0}) async {
    return scheduleDaily(hour: hour, minute: minute);
  }

  /// ❌ Hủy thông báo cụ thể
  Future<void> cancelDaily() async {
    if (kIsWeb) return;
    await _fln.cancel(1001);
  }

  /// ❌ Hủy toàn bộ thông báo
  Future<void> cancelAll() async {
    if (kIsWeb) return;
    await _fln.cancelAll();
  }

  /// 📣 Hiển thị thông báo ngay lập tức
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
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
        presentBadge: true,
      ),
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
  debugPrint('Background tap: ${response.payload}');
}
