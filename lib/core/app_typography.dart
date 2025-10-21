import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  static final title = GoogleFonts.dancingScript(
    fontSize: 28,
    color: AppColors.brownText,
    fontWeight: FontWeight.w600,
  );

  static final body = GoogleFonts.cormorant(
    color: AppColors.brownText,
    fontSize: 18,
    height: 1.5,
  );

  static final smallNote = GoogleFonts.cormorant(
    color: Colors.brown.shade400,
    fontSize: 14,
    fontStyle: FontStyle.italic,
  );
}
