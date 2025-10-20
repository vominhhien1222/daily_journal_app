import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final vintageTheme = ThemeData(
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
  textTheme: TextTheme(
    bodyMedium: GoogleFonts.cormorant(
      color: const Color(0xFF3E2723),
      fontSize: 18,
      height: 1.5,
    ),
  ),
);
