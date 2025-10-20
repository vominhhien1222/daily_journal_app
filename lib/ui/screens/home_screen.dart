import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:page_transition/page_transition.dart';
import '../../../providers/journal_provider.dart';
import '../../../data/models/journal_entry.dart';
import 'editor_screen.dart';
import 'detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final journalProvider = Provider.of<JournalProvider>(context);
    final theme = Theme.of(context); // 🔹 Lấy màu từ theme vintage

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        title: Text(
          'My Vintage Journal ☕',
          style: GoogleFonts.dancingScript(
            fontSize: 30,
            fontWeight: FontWeight.w600,
            color: theme.appBarTheme.iconTheme?.color ?? Colors.brown,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings,
              color: theme.appBarTheme.iconTheme?.color ?? Colors.brown,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),

      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: journalProvider.entries.isEmpty
            ? _buildEmptyState(theme)
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: journalProvider.entries.length,
                itemBuilder: (context, index) {
                  final JournalEntry entry = journalProvider.entries[index];
                  return _buildJournalItem(context, entry, theme);
                },
              ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor:
            theme.floatingActionButtonTheme.backgroundColor ??
            const Color(0xFF8B5E3C),
        onPressed: () async {
          await Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              duration: const Duration(milliseconds: 600),
              child: const EditorScreen(),
            ),
          );
          journalProvider.loadEntries();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  /// 📜 Màn hình khi chưa có nhật ký
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book,
              color: theme.colorScheme.onBackground.withOpacity(0.6),
              size: 80,
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có nhật ký nào 😌\nNhấn dấu + để viết nhé!',
              textAlign: TextAlign.center,
              style: GoogleFonts.cormorant(
                fontSize: 20,
                color: theme.colorScheme.onBackground.withOpacity(0.8),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ✏️ Item từng dòng nhật ký
  Widget _buildJournalItem(
    BuildContext context,
    JournalEntry entry,
    ThemeData theme,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.fade,
            duration: const Duration(milliseconds: 400),
            child: DetailScreen(entry: entry),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: theme.cardTheme.color ?? const Color(0xFFF5E5C0),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.brown.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(2, 3),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 8,
          ),
          leading: CircleAvatar(
            backgroundColor: _getMoodColor(entry.mood),
            child: Text(
              entry.mood.characters.first.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            entry.title,
            style: GoogleFonts.dancingScript(
              fontSize: 24,
              color: theme.textTheme.titleLarge?.color ?? Colors.brown,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            '${entry.date.day}/${entry.date.month}/${entry.date.year}',
            style: GoogleFonts.cormorant(
              fontSize: 18,
              color:
                  theme.textTheme.bodyMedium?.color?.withOpacity(0.8) ??
                  Colors.brown.shade600,
            ),
          ),
        ),
      ),
    );
  }

  Color _getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return Colors.orange.shade400;
      case 'sad':
        return Colors.blue.shade300;
      case 'angry':
        return Colors.red.shade300;
      case 'neutral':
      default:
        return Colors.grey.shade400;
    }
  }
}
