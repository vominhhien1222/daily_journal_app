import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 🌿 Light Theme – giấy be, chữ nâu
final vintageLightTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: const Color(0xFFF8EBD7),
  appBarTheme: AppBarTheme(
    backgroundColor: const Color(0xFFF5E5C0),
    centerTitle: true,
    titleTextStyle: GoogleFonts.dancingScript(
      fontSize: 28,
      color: const Color(0xFF5C4033),
      fontWeight: FontWeight.w600,
    ),
    iconTheme: const IconThemeData(color: Color(0xFF5C4033)),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF8B5E3C),
    foregroundColor: Colors.white,
  ),
  cardTheme: CardThemeData(
    color: const Color(0xFFFFF9F2),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: Color(0xFFBCA48B), width: 0.4),
    ),
    shadowColor: const Color(0x4D8B5E3C),
    elevation: 2,
  ),
  textTheme: TextTheme(
    bodyMedium: GoogleFonts.cormorant(
      color: const Color(0xFF3E2723),
      fontSize: 18,
      height: 1.5,
    ),
    titleLarge: GoogleFonts.playfairDisplay(
      color: const Color(0xFF5C4033),
      fontSize: 22,
      fontWeight: FontWeight.w700,
    ),
  ),
);

/// 🌙 Dark Theme – nâu trầm, chữ vàng nhạt
final vintageDarkTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: const Color(0xFF2E1F1A),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF8B5E3C),
    secondary: Color(0xFFC19A6B),
    surface: Color(0xFF3B2A24),
    onPrimary: Colors.white,
    onSecondary: Colors.black87,
    onSurface: Color(0xFFE8D8C3),
    background: Color(0xFF2E1F1A),
    onBackground: Color(0xFFE8D8C3),
    error: Color(0xFFD68B8B),
    onError: Colors.white,
    brightness: Brightness.dark,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: const Color(0xFF3B2A24),
    elevation: 0,
    centerTitle: true,
    titleTextStyle: GoogleFonts.dancingScript(
      fontSize: 26,
      color: const Color(0xFFE8D8C3),
      fontWeight: FontWeight.w600,
    ),
    iconTheme: const IconThemeData(color: Color(0xFFE8D8C3)),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFFC19A6B),
    foregroundColor: Color(0xFF2E1F1A),
  ),
  cardTheme: CardThemeData(
    color: const Color(0xFF3B2A24),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: Color(0xFFC19A6B), width: 0.3),
    ),
    shadowColor: const Color(0x338B5E3C),
    elevation: 2,
  ),
  textTheme: TextTheme(
    bodyMedium: GoogleFonts.cormorant(
      color: const Color(0xFFE8D8C3),
      fontSize: 18,
      height: 1.5,
    ),
    titleLarge: GoogleFonts.playfairDisplay(
      color: const Color(0xFFF2E4C7),
      fontSize: 22,
      fontWeight: FontWeight.w700,
    ),
  ),
  // 💬 FIX phần ô nhập bị chìm chữ
  inputDecorationTheme: const InputDecorationTheme(
    labelStyle: TextStyle(color: Color(0xFFE8D8C3)),
    hintStyle: TextStyle(color: Color(0xFFD6C4A3)),
    filled: true,
    fillColor: Color(0xFF3B2A24),
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFFC19A6B)),
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFFC19A6B)),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFFFFD68A), width: 2),
    ),
  ),
);
