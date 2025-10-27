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
  final _contentController = TextEditingController();
  String? _selectedMood;

  bool get isEditing => widget.entry != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _contentController.text = widget.entry!.content;
      _selectedMood = widget.entry!.mood;
    }
  }

  Future<void> _saveEntry() async {
    FocusScope.of(context).unfocus();

    final provider = Provider.of<JournalProvider>(context, listen: false);
    final content = _contentController.text.trim();

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Vui lòng nhập nội dung nhật ký')),
      );
      return;
    }

    // 🧠 Tự lấy dòng đầu tiên làm tiêu đề ngầm (nếu muốn hiển thị ngoài danh sách)
    final title = content.split('\n').first.trim().isEmpty
        ? '(Không tiêu đề)'
        : content.split('\n').first.trim();

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
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
    }
  }

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
    final suggestions = PromptSuggestions.getSuggestions(_selectedMood);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(isEditing ? 'Chỉnh sửa nhật ký' : 'Thêm nhật ký'),
        actions: [
          TextButton(
            onPressed: _saveEntry,
            child: Text(
              'Lưu',
              style: TextStyle(
                color:
                    Theme.of(context).appBarTheme.iconTheme?.color ??
                    Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 💡 Gợi ý viết
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF3B2A24)
                              : const Color(0xFFFFF9F2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFFC19A6B)
                                : const Color(0xFFBCA48B),
                            width: 0.8,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "💡 Gợi ý hôm nay:",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? const Color(0xFFF2E4C7)
                                    : const Color(0xFF5C4033),
                              ),
                            ),
                            const SizedBox(height: 8),
                            for (final s in suggestions)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  "• $s",
                                  style: TextStyle(
                                    color: isDark
                                        ? const Color(0xFFE8D8C3)
                                        : const Color(0xFF3E2723),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Chọn cảm xúc thủ công
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

                      // Ô nhập nội dung
                      Expanded(
                        child: TextField(
                          controller: _contentController,
                          onTapOutside: (_) => FocusScope.of(context).unfocus(),
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
              ),
            );
          },
        ),
      ),
    );
  }
}
