import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/settings_provider.dart';
import 'routes.dart';
import 'theme/vintage_theme.dart';
import 'ui/screens/splash_screen.dart'; // 🌸 Thêm dòng này

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Daily Journal ☕',

      // 🌙 Cho phép đổi theme sáng/tối theo SettingsProvider
      themeMode: settings.themeMode,

      // 🌿 Giao diện giấy cũ (ban ngày)
      theme: vintageLightTheme,

      // 🌑 Giao diện vintage đêm (nâu trầm)
      darkTheme: vintageDarkTheme,

      // 🔹 Gọi SplashScreen trước
      home: const SplashScreen(),
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
