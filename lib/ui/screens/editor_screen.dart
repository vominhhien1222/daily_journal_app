import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/journal_provider.dart';
import '../../../data/models/journal_entry.dart';

class EditorScreen extends StatefulWidget {
  final JournalEntry? entry;

  const EditorScreen({super.key, this.entry});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedMood = 'Neutral';

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

    if (isEditing) {
      final updated = widget.entry!;
      updated.title = title;
      updated.content = content;
      updated.mood = _selectedMood;
      updated.date = DateTime.now();
      await provider.updateEntry(updated);
    } else {
      await provider.addEntry(title, content, _selectedMood);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
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
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Tiêu đề',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  labelText: 'Nội dung',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Tâm trạng:'),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _selectedMood,
                  onChanged: (val) => setState(() => _selectedMood = val!),
                  items: const [
                    DropdownMenuItem(value: 'Happy', child: Text('😊 Vui')),
                    DropdownMenuItem(value: 'Sad', child: Text('😢 Buồn')),
                    DropdownMenuItem(
                      value: 'Neutral',
                      child: Text('😐 Bình thường'),
                    ),
                    DropdownMenuItem(value: 'Angry', child: Text('😠 Bực')),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
