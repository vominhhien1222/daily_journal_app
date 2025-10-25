import 'package:hive/hive.dart';
import '../data/models/journal_entry.dart';

class JournalRepository {
  static const String boxName = 'journal_entries';

  /// 🧰 Mở box Hive an toàn, tự reset nếu gặp lỗi đọc dữ liệu cũ
  Future<Box<JournalEntry>> _getBox() async {
    try {
      return await Hive.openBox<JournalEntry>(boxName);
    } catch (e) {
      // Nếu box cũ bị lỗi (do thay đổi model), xóa và mở lại box mới
      print("⚠️ Hive box lỗi, xóa và tạo mới: $e");
      await Hive.deleteBoxFromDisk(boxName);
      return await Hive.openBox<JournalEntry>(boxName);
    }
  }

  /// 📜 Lấy toàn bộ danh sách nhật ký
  Future<List<JournalEntry>> getAll() async {
    final box = await _getBox();
    return box.values.toList();
  }

  /// ➕ Thêm nhật ký mới
  Future<void> addEntry(JournalEntry entry) async {
    final box = await _getBox();
    await box.put(entry.id, entry);
  }

  /// ✏️ Cập nhật nhật ký
  Future<void> updateEntry(JournalEntry entry) async {
    final box = await _getBox();
    await box.put(entry.id, entry);
  }

  /// 🗑️ Xóa nhật ký
  Future<void> deleteEntry(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }
}
