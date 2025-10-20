import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/journal_provider.dart';
import 'providers/settings_provider.dart';
import 'routes.dart';
import 'vintage_theme.dart'; // 🔹 thêm dòng này để dùng theme giấy cũ

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsProvider()..loadDefaults(),
        ),
        ChangeNotifierProvider(create: (_) => JournalProvider()..loadInitial()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Daily Journal ☕',
        themeMode: context.watch<SettingsProvider>().themeMode,

        // 🔹 Theme giấy cũ (vintage)
        theme: vintageTheme,

        // 🔹 Dark theme (tối giản, nâu đậm)
        darkTheme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF3B2F2F),
          textTheme: const TextTheme(
            bodyMedium: TextStyle(color: Colors.white, fontSize: 18),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF5D4037),
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
            iconTheme: IconThemeData(color: Colors.white),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFF795548),
            foregroundColor: Colors.white,
          ),
        ),

        // 🔹 Route setup
        initialRoute: AppRoutes.home,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}
