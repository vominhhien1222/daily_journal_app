import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/journal_provider.dart';
import '../../../data/models/journal_entry.dart';
import '../../../core/emotion_analyzer.dart';
import '../../../core/prompt_suggestions.dart';
import '../../../core/ai_responder.dart';

class EditorScreen extends StatefulWidget {
  final JournalEntry? entry;

  const EditorScreen({super.key, this.entry});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String? _selectedMood; // 👈 người dùng chọn cảm xúc

  bool get isEditing => widget.entry != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _titleController.text = widget.entry!.title;
      _contentController.text = widget.entry!.content;
      _selectedMood = widget.entry!.mood;
    }
  }

  Future<void> _saveEntry() async {
    final provider = Provider.of<JournalProvider>(context, listen: false);
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Vui lòng nhập tiêu đề và nội dung')),
      );
      return;
    }

    // 🧠 Nếu người dùng không chọn, để AI phân tích
    final mood = _selectedMood ?? EmotionAnalyzer.analyze(content);
    final aiMessage = AiResponder.respond(mood);

    if (isEditing) {
      final updated = widget.entry!;
      updated.title = title;
      updated.content = content;
      updated.mood = mood;
      updated.date = DateTime.now();
      await provider.updateEntry(updated);
    } else {
      await provider.addEntry(title, content);
    }

    // 💬 Hiển thị hộp thoại phản hồi động viên
    if (mounted) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            mood,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          content: Text(
            aiMessage,
            style: const TextStyle(fontSize: 16, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // đóng dialog
                Navigator.pop(context); // quay lại màn trước
              },
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
    }
  }

  // 🧩 Nút chọn cảm xúc
  Widget _buildMoodButton(String emoji, String mood) {
    final isSelected = _selectedMood == mood;
    return GestureDetector(
      onTap: () => setState(() => _selectedMood = mood),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.amber.shade100 : Colors.grey.shade200,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.amber : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(emoji, style: const TextStyle(fontSize: 24)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = PromptSuggestions.randomSuggestions();

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Chỉnh sửa nhật ký' : 'Thêm nhật ký'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveEntry),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 💡 Gợi ý viết
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "💡 Gợi ý hôm nay:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  for (final s in suggestions)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text("• $s"),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 🧠 Chọn cảm xúc thủ công
            const Text(
              "Tâm trạng hôm nay:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMoodButton('😊', 'Tích cực 😊'),
                _buildMoodButton('😢', 'Tiêu cực 😞'),
                _buildMoodButton('😐', 'Bình thường 😌'),
                _buildMoodButton('😠', 'Bực 😠'),
              ],
            ),

            const SizedBox(height: 16),

            // 📝 Ô nhập tiêu đề
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Tiêu đề',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // 📔 Ô nhập nội dung
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  labelText: 'Nội dung nhật ký',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
