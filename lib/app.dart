import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/settings_provider.dart';
import 'routes.dart';
import 'theme/vintage_theme.dart';
import 'ui/screens/splash_screen.dart';
import 'ui/screens/pin_screen.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool _authenticated = false;

  void _onAuthenticated() {
    setState(() => _authenticated = true);
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Daily Journal ☕',
      themeMode: settings.themeMode,
      theme: vintageLightTheme,
      darkTheme: vintageDarkTheme,
      onGenerateRoute: AppRoutes.onGenerateRoute,

      home: _authenticated
          ? const SplashScreen()
          : PinScreen(onAuthenticated: _onAuthenticated),
    );
  }
}
