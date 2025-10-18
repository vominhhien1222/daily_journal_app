import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/models/journal_entry.dart';
import '../repositories/journal_repository.dart';

class JournalProvider extends ChangeNotifier {
  final JournalRepository _repo = JournalRepository();
  List<JournalEntry> _entries = [];

  List<JournalEntry> get entries => _entries;

  /// 🟢 Tải danh sách
  Future<void> loadEntries() async {
    _entries = await _repo.getAll();
    _entries.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  /// 🟢 Khởi tạo ban đầu
  Future<void> loadInitial() async {
    await loadEntries();
  }

  /// 🟢 Thêm nhật ký
  Future<void> addEntry(String title, String content, String mood) async {
    final entry = JournalEntry(
      id: const Uuid().v4(),
      title: title,
      content: content,
      date: DateTime.now(),
      mood: mood,
    );
    await _repo.addEntry(entry);
    _entries.insert(0, entry);
    notifyListeners();
  }

  /// 🟢 Cập nhật
  Future<void> updateEntry(JournalEntry entry) async {
    await _repo.updateEntry(entry);
    await loadEntries();
  }

  /// 🔴 Xóa
  Future<void> deleteEntry(String id) async {
    await _repo.deleteEntry(id);
    _entries.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}
