import 'package:flutter/material.dart';

class AppTheme {
  // Steam'in koyu mavi-gri renk şeması
  static const Color primaryColor = Color(0xFF171a21);
  static const Color accentColor = Color(0xFF1b2838);
  static const Color highlightColor = Color(0xFF66c0f4);
  static const Color textColor = Color(0xFFc7d5e0);
  static const Color secondaryTextColor = Color(0xFF8f98a0);

  static final ThemeData darkTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: primaryColor,
    colorScheme: const ColorScheme.dark(
      primary: highlightColor,
      secondary: accentColor,
      surface: accentColor,
      background: primaryColor,
      onPrimary: Colors.white,
      onSecondary: textColor,
      onSurface: textColor,
      onBackground: textColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: accentColor,
      elevation: 0,
      iconTheme: IconThemeData(color: textColor),
      titleTextStyle: TextStyle(
        color: textColor,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
    ),
    cardTheme: CardTheme(
      color: accentColor,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: highlightColor,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: textColor),
      bodyLarge: TextStyle(color: textColor),
      bodyMedium: TextStyle(color: secondaryTextColor),
    ),
    dividerTheme:
        const DividerThemeData(color: Color(0xFF324353), thickness: 1),
  );
}
