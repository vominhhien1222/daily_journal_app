import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;

import 'data/models/journal_entry.dart';
import 'data/hive_boxes.dart';
import 'providers/settings_provider.dart';
import 'providers/journal_provider.dart';
import 'core/notification_service.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(JournalEntryAdapter().typeId)) {
    Hive.registerAdapter(JournalEntryAdapter());
  }
  await HiveBoxes.openAll();

  tz.initializeTimeZones();

  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    final notiPermission = await Permission.notification.request();
    if (notiPermission.isDenied || notiPermission.isPermanentlyDenied) {
      debugPrint("⚠️ Người dùng chưa cấp quyền thông báo.");
    }

    await NotificationService.instance.init();

    //  Test thông báo sau 1 phút
    try {
      final now = DateTime.now();
      await NotificationService.instance.scheduleDaily(
        hour: now.hour,
        minute: (now.minute + 1) % 60, // test sau 1 phút
      );
      debugPrint(" Đã lên lịch test notification sau 1 phút.");
    } catch (e) {
      debugPrint("Lỗi khi test notification: $e");
    }
  }

  // Chạy ứng dụng
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
