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

  // ✅ Hive
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(JournalEntryAdapter().typeId)) {
    Hive.registerAdapter(JournalEntryAdapter());
  }
  await HiveBoxes.openAll();

  // 🕒 Timezone
  tz.initializeTimeZones();

  // 🔔 Notification
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    await NotificationService.instance.init();
    await NotificationService.instance.scheduleDaily(hour: 21, minute: 0);
  }

  // 🔐 Permission
  final status = await Permission.scheduleExactAlarm.status;

  if (status.isDenied) {
    // await Permission.scheduleExactAlarm.request();
  } else if (status.isPermanentlyDenied) {
    debugPrint("⚠️ Quyền scheduleExactAlarm bị tắt. Bỏ qua để app vẫn chạy.");
    // Hoặc hiển thị thông báo cho user bằng dialog nếu bạn muốn
  }

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
