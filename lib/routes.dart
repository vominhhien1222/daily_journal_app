import 'package:flutter/material.dart';
import 'data/models/journal_entry.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/editor_screen.dart';
import 'ui/screens/detail_screen.dart';
import 'ui/screens/settings_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String editor = '/editor';
  static const String detail = '/detail';
  static const String settings = '/settings';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home: // ✅ dùng tên class đầy đủ
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case AppRoutes.editor:
        return MaterialPageRoute(builder: (_) => const EditorScreen());

      case AppRoutes.detail:
        final args = settings.arguments;
        if (args is JournalEntry) {
          return MaterialPageRoute(builder: (_) => DetailScreen(entry: args));
        }
        return _errorRoute('Invalid entry data');

      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      default:
        return _errorRoute('404 – Page not found 🚫');
    }
  }

  static MaterialPageRoute _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(
          child: Text(
            message,
            style: const TextStyle(fontSize: 16, color: Colors.redAccent),
          ),
        ),
      ),
    );
  }
}
