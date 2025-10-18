import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/journal_provider.dart';
import 'providers/settings_provider.dart';
import 'routes.dart';

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
        title: 'Daily Journal & Mood',
        themeMode: context.watch<SettingsProvider>().themeMode,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF6C63FF),
        ),
        darkTheme: ThemeData.dark(),
        initialRoute: AppRoutes.home,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}
