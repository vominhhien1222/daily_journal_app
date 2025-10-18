import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'data/models/journal_entry.dart';
import 'data/hive_boxes.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(JournalEntryAdapter());
  }
  await HiveBoxes.openAll();

  runApp(const App());
}
