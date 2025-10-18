import 'package:hive/hive.dart';

part 'journal_entry.g.dart'; // 🧠 quan trọng: không đổi tên, không thêm thư mục!

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

  JournalEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.mood,
  });
}
