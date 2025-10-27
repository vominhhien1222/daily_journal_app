import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'dart:io' show Platform;
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'data/models/journal_entry.dart';
import 'data/hive_boxes.dart';
import 'providers/settings_provider.dart';
import 'providers/journal_provider.dart';
import 'core/notification_service.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Khởi tạo Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("✅ Firebase initialized successfully!");
  } catch (e) {
    debugPrint("❌ Lỗi khi khởi tạo Firebase: $e");
  }

  // 🐝 Khởi tạo Hive
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(JournalEntryAdapter().typeId)) {
    Hive.registerAdapter(JournalEntryAdapter());
  }
  await HiveBoxes.openAll();

  // 🌏 Khởi tạo timezone (bắt buộc cho flutter_local_notifications)
  tz.initializeTimeZones();

  // 🔔 Xin quyền notification (Android/iOS)
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    final notiPermission = await Permission.notification.request();
    if (notiPermission.isDenied || notiPermission.isPermanentlyDenied) {
      debugPrint("⚠️ Người dùng chưa cấp quyền thông báo.");
    }

    // 🚀 Khởi tạo NotificationService (tạo channel, xin quyền, set timezone)
    await NotificationService.instance.init();

    // 🧭 Test thông báo sau 1 phút (chạy thử khi mở app)
    try {
      final now = DateTime.now();
      final testTime = now.add(const Duration(minutes: 1));
      await NotificationService.instance.scheduleDaily(
        hour: testTime.hour,
        minute: testTime.minute,
      );
      debugPrint("🕒 Đã lên lịch test notification sau 1 phút.");
    } catch (e) {
      debugPrint("❌ Lỗi khi test notification: $e");
    }
  }

  // 🪶 Chạy ứng dụng
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsProvider()..loadDefaults(),
        ),
        ChangeNotifierProvider(create: (_) => JournalProvider()..loadInitial()),
      ],
      child: const App(),
    ),
  );
}
