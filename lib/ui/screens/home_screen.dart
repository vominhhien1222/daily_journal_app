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
  bool _isCalendarView = false; // 🔁 Chuyển giữa 2 chế độ
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _loadViewMode(); // 🔄 đọc chế độ lưu trước đó
    _autoSyncCloud();
  }

  /// ☁️ Tự động đồng bộ dữ liệu khi mở app
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
      debugPrint("❌ Lỗi khi đồng bộ: $e");
    } finally {
      setState(() => _isSyncing = false);
    }
  }

  /// 💾 Đọc chế độ xem từ SharedPreferences
  Future<void> _loadViewMode() async {
    final saved = await PrefsService.loadViewMode();
    setState(() => _isCalendarView = saved);
  }

  /// 💾 Lưu chế độ xem
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
              transitionBuilder: (child, anim) => RotationTransition(
                turns: Tween(begin: 0.7, end: 1.0).animate(anim),
                child: child,
              ),
              child: Icon(
                _isCalendarView ? Icons.list_alt : Icons.calendar_month,
                key: ValueKey(_isCalendarView),
                color: theme.appBarTheme.iconTheme?.color ?? Colors.brown,
              ),
            ),
            tooltip: _isCalendarView ? 'Xem danh sách' : 'Xem lịch (Calendar)',
            onPressed: () {
              setState(() => _isCalendarView = !_isCalendarView);
              _saveViewMode(_isCalendarView);
            },
          ),
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

      // 🔄 AnimatedSwitcher để chuyển giữa 2 giao diện
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: _isCalendarView
            ? _buildCalendarView(context, entries, theme)
            : _buildListView(context, entries, theme),
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
          await _autoSyncCloud();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  /// 📜 Dạng 1: Danh sách nhật ký
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
      itemBuilder: (context, index) {
        final entry = entries[index];
        return _buildJournalItem(context, entry, theme);
      },
    );
  }

  /// 🗓️ Dạng 2: Calendar View
  Widget _buildCalendarView(
    BuildContext context,
    List<JournalEntry> entries,
    ThemeData theme,
  ) {
    final daysWithEntries = entries.map((e) => e.dateOnly).toList();

    // 📊 Đếm số ngày có bài trong tháng hiện tại
    final int writtenDays = daysWithEntries
        .where(
          (d) => d.year == _focusedDay.year && d.month == _focusedDay.month,
        )
        .length;
    final int totalDaysInMonth = DateUtils.getDaysInMonth(
      _focusedDay.year,
      _focusedDay.month,
    );

    return Column(
      key: const ValueKey('calendar_view'),
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _focusedDay = DateTime.now();
                    _selectedDay = DateTime.now();
                  });
                },
                icon: const Icon(Icons.today, size: 18),
                label: const Text("Hôm nay"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5E3C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
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
              color: Colors.brown.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekendStyle: TextStyle(color: Colors.red.shade400),
            weekdayStyle: const TextStyle(color: Colors.brown),
          ),
          calendarStyle: CalendarStyle(
            selectedDecoration: BoxDecoration(
              color: Colors.brown.shade400,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: Colors.orange.shade400,
              shape: BoxShape.circle,
            ),
            markersMaxCount: 1,
          ),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });

            final entry = entries.firstWhere(
              (e) => isSameDay(e.dateOnly, selectedDay),
              orElse: () => JournalEntry.empty(),
            );
            if (entry.id.isNotEmpty) {
              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.fade,
                  duration: const Duration(milliseconds: 400),
                  child: DetailScreen(entry: entry),
                ),
              );
            }
          },
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, _) {
              final hasEntry = daysWithEntries.contains(date);
              if (hasEntry) {
                final entry = entries.firstWhere(
                  (e) => isSameDay(e.dateOnly, date),
                );
                return AnimatedScale(
                  duration: const Duration(milliseconds: 300),
                  scale: isSameDay(date, _selectedDay) ? 1.4 : 1.0,
                  child: CircleAvatar(
                    radius: 3.5,
                    backgroundColor: entry.moodColor,
                  ),
                );
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '🗓️ $writtenDays / $totalDaysInMonth ngày đã viết trong tháng này',
          style: GoogleFonts.cormorant(
            fontSize: 17,
            fontStyle: FontStyle.italic,
            color: theme.colorScheme.onBackground.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '📅 Chọn ngày có chấm để xem nhật ký',
          style: GoogleFonts.cormorant(
            fontSize: 15,
            color: theme.colorScheme.onBackground.withOpacity(0.7),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  /// 🪶 Khi chưa có nhật ký
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
