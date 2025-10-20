import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'data/models/journal_entry.dart';
import 'data/hive_boxes.dart';
import 'providers/settings_provider.dart';
import 'providers/journal_provider.dart';
import 'core/notification_service.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 1. Khởi tạo Hive
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(JournalEntryAdapter());
  }
  await HiveBoxes.openAll();

  // 🔹 2. Khởi tạo múi giờ (dùng cho notifications)
  tz.initializeTimeZones();

  // 🔹 3. Khởi tạo NotificationService & đặt lịch nhắc
  await NotificationService.instance.init();
  await NotificationService.instance.scheduleDaily(hour: 21, minute: 0);
  // 👉 Bạn có thể đổi 21,0 thành giờ khác (ví dụ 8h sáng → hour: 8, minute: 0)

  // 🔹 4. Chạy app với Provider
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
