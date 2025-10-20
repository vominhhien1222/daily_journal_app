import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

import 'data/models/journal_entry.dart';
import 'data/hive_boxes.dart';
import 'providers/settings_provider.dart';
import 'providers/journal_provider.dart';
import 'core/notification_service.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(JournalEntryAdapter());
  }
  await HiveBoxes.openAll();

  tz.initializeTimeZones();

  // ✅ Chỉ khởi tạo Notification khi không chạy Web
  if (!kIsWeb) {
    await NotificationService.instance.init();
    await NotificationService.instance.scheduleDaily(hour: 21, minute: 0);
  }

  if (await Permission.scheduleExactAlarm.isDenied) {
    await openAppSettings(); // hoặc Permission.scheduleExactAlarm.request();
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
