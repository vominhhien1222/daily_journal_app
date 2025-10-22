import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/models/journal_entry.dart';
import '../repositories/journal_repository.dart';
import '../core/emotion_analyzer.dart'; // 👈 Thêm dòng này để dùng phân tích cảm xúc

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

    final entry = JournalEntry(
      id: const Uuid().v4(),
      title: title,
      content: content,
      date: DateTime.now(),
      mood: mood, // ✅ Lưu cảm xúc vào entry
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
