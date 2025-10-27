import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/journal_entry.dart';
//import 'package:hive/hive.dart';
import '../data/hive_boxes.dart';
import 'auth_service.dart';

class CloudSyncService {
  final _firestore = FirebaseFirestore.instance;
  final _authService = AuthService();

  Future<void> uploadAll() async {
    final user = _authService.currentUser;
    final userId = user?.uid ?? "testuser123";

    final box = HiveBoxes.journal;
    print("☁️ Bắt đầu upload (${box.values.length} entries)");

    for (var entry in box.values) {
      final docId = "${userId}_${entry.id}";
      await _firestore.collection('journals').doc(docId).set({
        'userId': userId,
        'id': entry.id,
        'title': entry.title,
        'content': entry.content,
        'mood': entry.mood,
        'emotion': entry.emotion,
        'date': entry.date.toIso8601String(),
        'createdAt': entry.createdAt.toIso8601String(),
        'updatedAt': entry.updatedAt.toIso8601String(),
      }, SetOptions(merge: true));
    }
    print("☁️ Upload thành công tất cả nhật ký lên Firestore");
  }

  Future<void> downloadAll() async {
    final user = _authService.currentUser;
    final userId = user?.uid ?? "testuser123";

    final snapshot = await _firestore
        .collection('journals')
        .where('userId', isEqualTo: userId)
        .get();

    final box = HiveBoxes.journal;

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final cloudUpdated =
          DateTime.tryParse(data['updatedAt'] ?? '') ?? DateTime.now();

      final existingEntry = box.values.firstWhere(
        (e) => e.id == data['id'],
        orElse: () => JournalEntry.empty(),
      );

      final entryDate = data.containsKey('date')
          ? DateTime.tryParse(data['date'] ?? '') ?? DateTime.now()
          : DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now();

      if (existingEntry.id.isEmpty ||
          cloudUpdated.isAfter(existingEntry.updatedAt)) {
        final newEntry = JournalEntry(
          id: data['id'] ?? '',
          title: data['title'] ?? '(Không có tiêu đề)',
          content: data['content'] ?? '(Không có nội dung)',
          mood: (data['mood'] ?? 'neutral').toString(),
          emotion: (data['emotion'] ?? 'neutral').toString(),
          date: entryDate,
          createdAt:
              DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
          updatedAt: cloudUpdated,
        );
        await box.put(newEntry.id, newEntry);
      }
    }

    print("☁️ Đã tải dữ liệu Firestore về Hive");
  }

  Future<void> syncAll() async {
    print("🔁 Bắt đầu đồng bộ...");
    await uploadAll();
    await downloadAll();
    print("✅ Đồng bộ hoàn tất!");
  }
}
