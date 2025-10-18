import 'package:hive/hive.dart';
import '../data/models/journal_entry.dart';

class JournalRepository {
  static const String boxName = 'journal_entries';

  Future<Box<JournalEntry>> _getBox() async {
    return await Hive.openBox<JournalEntry>(boxName);
  }

  Future<List<JournalEntry>> getAll() async {
    final box = await _getBox();
    return box.values.toList();
  }

  Future<void> addEntry(JournalEntry entry) async {
    final box = await _getBox();
    await box.put(entry.id, entry);
  }

  Future<void> updateEntry(JournalEntry entry) async {
    final box = await _getBox();
    await box.put(entry.id, entry);
  }

  Future<void> deleteEntry(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }
}
