import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/journal_provider.dart';
import '../../../data/models/journal_entry.dart';
import 'editor_screen.dart';

class DetailScreen extends StatelessWidget {
  final JournalEntry entry;
  const DetailScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<JournalProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết nhật ký'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EditorScreen(entry: entry)),
              );
              provider.loadEntries();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              await provider.deleteEntry(entry.id);
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(entry.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              '${entry.date.day}/${entry.date.month}/${entry.date.year}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Text(entry.content, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
