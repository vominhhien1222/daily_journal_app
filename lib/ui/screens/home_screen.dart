import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/journal_provider.dart';
import '../../../data/models/journal_entry.dart';
import 'editor_screen.dart';
import 'detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final journalProvider = Provider.of<JournalProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Journal 🪶'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),

      body: journalProvider.entries.isEmpty
          ? const Center(
              child: Text(
                'Chưa có nhật ký nào 😌\nNhấn dấu + để viết nhé!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: journalProvider.entries.length,
              itemBuilder: (context, index) {
                final JournalEntry entry = journalProvider.entries[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getMoodColor(entry.mood),
                      child: Text(
                        entry.mood.characters.first.toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(entry.title),
                    subtitle: Text(
                      '${entry.date.day}/${entry.date.month}/${entry.date.year}',
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailScreen(entry: entry),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EditorScreen()),
          );
          journalProvider.loadEntries();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return Colors.yellow.shade700;
      case 'sad':
        return Colors.blue.shade400;
      case 'angry':
        return Colors.red.shade400;
      case 'neutral':
      default:
        return Colors.grey;
    }
  }
}
