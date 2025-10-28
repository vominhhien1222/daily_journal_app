import 'package:hive/hive.dart';
import 'package:flutter/material.dart'; // 👈 để dùng Color

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

  ///Trả về ngày không kèm giờ (dùng để so sánh chính xác trên lịch)
  DateTime get dateOnly => DateTime(date.year, date.month, date.day);

  ///Màu cảm xúc (dùng để hiển thị chấm màu trên Calendar)
  Color get moodColor {
    switch (emotion.toLowerCase()) {
      case 'happy':
      case 'vui':
        return Colors.yellow.shade600;
      case 'sad':
      case 'buồn':
        return Colors.blue.shade400;
      case 'angry':
      case 'giận':
        return Colors.red.shade400;
      case 'calm':
      case 'bình yên':
        return Colors.green.shade400;
      case 'anxious':
      case 'lo lắng':
        return Colors.orange.shade400;
      default:
        return Colors.grey.shade400;
    }
  }
}
