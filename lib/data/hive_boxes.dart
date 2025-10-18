import 'package:hive/hive.dart';
import 'models/journal_entry.dart';

class HiveBoxes {
  static Future<void> openAll() async {
    await Hive.openBox<JournalEntry>('journal_box');
  }

  static Box<JournalEntry> get journal => Hive.box<JournalEntry>('journal_box');
}
