import 'package:hive/hive.dart';

part 'journal_entry.g.dart'; // 🧠 Giữ nguyên, dùng cho build_runner

@HiveType(typeId: 0)
class JournalEntry extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String content;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  String mood;

  @HiveField(5)
  String emotion;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  DateTime updatedAt;

  JournalEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.mood,
    required this.emotion,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 🔹 Constructor trống dùng khi cần tạo empty object
  static JournalEntry empty() {
    return JournalEntry(
      id: '',
      title: '',
      content: '',
      date: DateTime.now(),
      mood: '',
      emotion: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
