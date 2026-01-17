import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Pastel Colors from Dashboard
  static const Color pastelGreen = Color(0xFFE0F2F1); // Total Sales BG
  static const Color textGreen = Color(0xFF2E7D32); // Total Sales Text

  static const Color pastelOrange = Color(0xFFFFF3E0); // Total Transactions BG
  static const Color textOrange = Color(0xFFEF6C00);

  static const Color pastelPurple = Color(0xFFF3E5F5); // Avg Transaction BG
  static const Color textPurple = Color(0xFF7B1FA2);

  static const Color pastelYellow = Color(0xFFFFF9C4); // Caisse BG
  static const Color textYellow = Color(0xFFFBC02D);

  static const Color pastelBlue = Color(0xFFE3F2FD); // Gross Margin BG
  static const Color textBlue = Color(0xFF1565C0);

  static const Color pastelPink = Color(0xFFFCE4EC); // Net Profit BG
  static const Color textPink = Color(0xFFC2185B);

  static const Color textRed = Color(0xFFC62828); // Total Expenses Text

  static const Color background = Color(0xFFF5F5F5); // App Background
  static const Color sidebar = Colors.white;
  static const Color cardSurface = Colors.white;
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.textBlue,
        background: AppColors.background,
        surface: AppColors.cardSurface,
      ),
      textTheme: GoogleFonts.interTextTheme(),
      // cardTheme: const CardTheme(
      //   elevation: 0,
      //   margin: EdgeInsets.all(0),
      //   color: AppColors.cardSurface,
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.all(Radius.circular(12)),
      //   ),
      // ),
      iconTheme: const IconThemeData(color: Colors.black87),
    );
  }
}
