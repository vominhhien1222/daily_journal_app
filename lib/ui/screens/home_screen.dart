import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:page_transition/page_transition.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../providers/journal_provider.dart';
import '../../../data/models/journal_entry.dart';
import 'editor_screen.dart';
import 'detail_screen.dart';
import '../../../core/cloud_sync_service.dart';
import '../../../core/prefs_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSyncing = false;
  bool _isCalendarView = false;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _loadViewMode();
    _autoSyncCloud();
  }

  /// ☁️ Đồng bộ Firestore khi mở app
  Future<void> _autoSyncCloud() async {
    setState(() => _isSyncing = true);
    try {
      await CloudSyncService().syncAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('☁️ Đã đồng bộ thành công!'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint("❌ Lỗi đồng bộ: $e");
    } finally {
      setState(() => _isSyncing = false);
    }
  }

  /// 💾 Lưu & đọc chế độ xem
  Future<void> _loadViewMode() async {
    final saved = await PrefsService.loadViewMode();
    setState(() => _isCalendarView = saved);
  }

  Future<void> _saveViewMode(bool isCalendar) async {
    await PrefsService.saveViewMode(isCalendar);
  }

  @override
  Widget build(BuildContext context) {
    final journalProvider = Provider.of<JournalProvider>(context);
    final theme = Theme.of(context);
    final entries = journalProvider.entries;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'My Vintage Journal ☕',
          style: GoogleFonts.dancingScript(
            fontSize: 30,
            fontWeight: FontWeight.w600,
            color: Colors.brown.shade700,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (_isSyncing)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) =>
                  RotationTransition(turns: anim, child: child),
              child: Icon(
                _isCalendarView ? Icons.list_alt : Icons.calendar_month,
                key: ValueKey(_isCalendarView),
                color: Colors.brown,
              ),
            ),
            tooltip: _isCalendarView ? 'Xem danh sách' : 'Xem lịch',
            onPressed: () {
              setState(() => _isCalendarView = !_isCalendarView);
              _saveViewMode(_isCalendarView);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.brown),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),

      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: _isCalendarView
            ? _buildCalendarView(context, entries, theme)
            : _buildListView(context, entries, theme),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF8B5E3C),
        onPressed: () async {
          await Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              duration: const Duration(milliseconds: 500),
              child: const EditorScreen(),
            ),
          );
          journalProvider.loadEntries();
          await _autoSyncCloud();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  /// 📜 Dạng 1: Danh sách
  Widget _buildListView(
    BuildContext context,
    List<JournalEntry> entries,
    ThemeData theme,
  ) {
    if (entries.isEmpty) return _buildEmptyState(theme);
    return ListView.builder(
      key: const ValueKey('list_view'),
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      itemBuilder: (context, i) =>
          _buildJournalItem(context, entries[i], theme),
    );
  }

  /// 🗓️ Dạng 2: Lịch
  Widget _buildCalendarView(
    BuildContext context,
    List<JournalEntry> entries,
    ThemeData theme,
  ) {
    final daysWithEntries = entries.map((e) => e.dateOnly).toList();
    final writtenDays = daysWithEntries
        .where(
          (d) => d.year == _focusedDay.year && d.month == _focusedDay.month,
        )
        .length;
    final totalDays = DateUtils.getDaysInMonth(
      _focusedDay.year,
      _focusedDay.month,
    );

    return Column(
      children: [
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              _focusedDay = DateTime.now();
              _selectedDay = DateTime.now();
            });
          },
          icon: const Icon(Icons.today),
          label: const Text("Hôm nay"),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8B5E3C),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          headerStyle: HeaderStyle(
            titleCentered: true,
            formatButtonVisible: false,
            titleTextStyle: GoogleFonts.cormorant(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.brown,
            ),
          ),
          daysOfWeekStyle: const DaysOfWeekStyle(
            weekdayStyle: TextStyle(color: Colors.brown),
            weekendStyle: TextStyle(color: Colors.red),
          ),
          calendarStyle: CalendarStyle(
            selectedDecoration: const BoxDecoration(
              color: Colors.brown,
              shape: BoxShape.circle,
            ),
            todayDecoration: const BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
          ),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            _handleDayTap(context, selectedDay, entries);
          },
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, _) {
              final dayEntries = entries
                  .where((e) => isSameDay(e.dateOnly, date))
                  .toList();
              if (dayEntries.isEmpty) return null;
              if (dayEntries.length == 1) {
                return CircleAvatar(
                  radius: 3.5,
                  backgroundColor: dayEntries.first.moodColor,
                );
              }
              return Container(
                margin: const EdgeInsets.only(top: 18),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.brown,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${dayEntries.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '🗓️ $writtenDays / $totalDays ngày đã viết',
          style: GoogleFonts.cormorant(
            fontSize: 16,
            fontStyle: FontStyle.italic,
            color: Colors.brown.shade700,
          ),
        ),
      ],
    );
  }

  /// 📅 Khi bấm 1 ngày
  void _handleDayTap(
    BuildContext context,
    DateTime day,
    List<JournalEntry> all,
  ) {
    final sameDayEntries = all.where((e) => isSameDay(e.dateOnly, day)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    if (sameDayEntries.isEmpty || sameDayEntries.length > 1) {
      _showDayEntriesSheet(context, day, sameDayEntries);
    } else {
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          duration: const Duration(milliseconds: 400),
          child: DetailScreen(entry: sameDayEntries.first),
        ),
      );
    }
  }

  /// 🧾 Hiện danh sách bài trong ngày (bottom sheet)
  void _showDayEntriesSheet(
    BuildContext context,
    DateTime day,
    List<JournalEntry> entries,
  ) {
    final theme = Theme.of(context);
    final dateStr =
        '${day.day.toString().padLeft(2, '0')}/${day.month.toString().padLeft(2, '0')}/${day.year}';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF5E5C0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            top: 10,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.brown.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Nhật ký ngày $dateStr',
                style: GoogleFonts.cormorant(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown.shade700,
                ),
              ),
              const SizedBox(height: 8),
              if (entries.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Chưa có bài nào. Viết một chút nhé?',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cormorant(
                      fontSize: 17,
                      fontStyle: FontStyle.italic,
                      color: theme.colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                ),
              if (entries.isNotEmpty)
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: entries.length,
                    itemBuilder: (_, i) {
                      final e = entries[i];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getMoodColor(e.mood),
                          child: Text(
                            e.mood.characters.first.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          e.title,
                          style: GoogleFonts.dancingScript(
                            fontSize: 22,
                            color: Colors.brown,
                          ),
                        ),
                        subtitle: Text(
                          e.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cormorant(
                            color: Colors.brown.shade600,
                            fontSize: 16,
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.fade,
                              child: DetailScreen(entry: e),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('Tạo nhật ký mới'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5E3C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    await Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.rightToLeft,
                        child: const EditorScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Khi chưa có bài
  Widget _buildEmptyState(ThemeData theme) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.menu_book,
          color: theme.colorScheme.onBackground.withOpacity(0.6),
          size: 80,
        ),
        const SizedBox(height: 12),
        Text(
          'Chưa có nhật ký nào 😌\nNhấn dấu + để viết nhé!',
          textAlign: TextAlign.center,
          style: GoogleFonts.cormorant(
            fontSize: 20,
            fontStyle: FontStyle.italic,
            color: theme.colorScheme.onBackground.withOpacity(0.8),
          ),
        ),
      ],
    ),
  );

  /// Item danh sách
  Widget _buildJournalItem(
    BuildContext context,
    JournalEntry entry,
    ThemeData theme,
  ) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          child: DetailScreen(entry: entry),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF5E5C0),
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
              color: Colors.brown.shade800,
            ),
          ),
          subtitle: Text(
            '${entry.date.day}/${entry.date.month}/${entry.date.year}',
            style: GoogleFonts.cormorant(
              fontSize: 17,
              color: Colors.brown.shade600,
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
      default:
        return Colors.grey.shade400;
    }
  }
}
