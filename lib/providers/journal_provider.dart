import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:table_calendar/table_calendar.dart';
import '../data/models/journal_entry.dart';
import '../repositories/journal_repository.dart';
import '../core/emotion_analyzer.dart';

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

  /// 🟢 Thêm nhật ký (tự động phân tích cảm xúc)
  Future<void> addEntry(String title, String content) async {
    // 🧠 Phân tích cảm xúc tự động từ nội dung
    final mood = EmotionAnalyzer.analyze(content);
    final now = DateTime.now();

    final entry = JournalEntry(
      id: const Uuid().v4(),
      title: title,
      content: content,
      date: now,
      mood: mood,
      emotion: mood,
      createdAt: now,
      updatedAt: now,
    );

    await _repo.addEntry(entry);
    _entries.insert(0, entry);
    notifyListeners();
  }

  /// 🟢 Cập nhật
  Future<void> updateEntry(JournalEntry entry) async {
    entry.updatedAt = DateTime.now();
    await _repo.updateEntry(entry);
    await loadEntries();
  }

  /// 🔴 Xóa
  Future<void> deleteEntry(String id) async {
    await _repo.deleteEntry(id);
    _entries.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  JournalEntry? entryOf(DateTime day) {
    try {
      return _entries.firstWhere((e) => isSameDay(e.dateOnly, day));
    } catch (_) {
      return null;
    }
  }

  ///Gom các bài viết theo ngày (dùng cho TableCalendar marker)
  Map<DateTime, List<JournalEntry>> get entriesByDay {
    final Map<DateTime, List<JournalEntry>> map = {};
    for (final e in _entries) {
      final date = e.dateOnly;
      map[date] = [...(map[date] ?? []), e];
    }
    return map;
  }
}
