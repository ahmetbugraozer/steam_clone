import 'package:flutter/material.dart';

class AppTheme {
  // Steam'in modern koyu renk şeması
  static const Color primaryColor = Color(0xFF1b2838);
  static const Color backgroundColor = Color(0xFF0e141b);
  static const Color surfaceColor = Color(0xFF1e2328);
  static const Color accentColor = Color(0xFF2a475e);
  static const Color highlightColor = Color(0xFF66c0f4);
  static const Color successColor = Color(0xFF90ba3c);
  static const Color warningColor = Color(0xFFffc82c);
  static const Color errorColor = Color(0xFFcd5c2c);
  static const Color textPrimary = Color(0xFFc7d5e0);
  static const Color textSecondary = Color(0xFF8f98a0);
  static const Color textMuted = Color(0xFF67707b);

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: const ColorScheme.dark(
      primary: highlightColor,
      secondary: accentColor,
      surface: surfaceColor,
      background: backgroundColor,
      onPrimary: Colors.white,
      onSecondary: textPrimary,
      onSurface: textPrimary,
      onBackground: textPrimary,
      error: errorColor,
      onError: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      elevation: 2,
      shadowColor: Colors.black26,
      iconTheme: IconThemeData(color: textPrimary, size: 24),
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      centerTitle: false,
    ),
    cardTheme: CardTheme(
      color: surfaceColor,
      elevation: 4,
      shadowColor: Colors.black38,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(color: accentColor.withValues(alpha: 0.3), width: 1),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: highlightColor,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black26,
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          letterSpacing: 0.5,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: primaryColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: accentColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: highlightColor, width: 2),
      ),
      hintStyle: const TextStyle(color: textMuted),
      labelStyle: const TextStyle(color: textSecondary),
    ),
    tabBarTheme: const TabBarTheme(
      labelColor: highlightColor,
      unselectedLabelColor: textSecondary,
      indicatorColor: highlightColor,
      indicatorSize: TabBarIndicatorSize.tab,
      labelStyle: TextStyle(fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: accentColor,
      selectedColor: highlightColor.withValues(alpha: 0.2),
      labelStyle: const TextStyle(color: textPrimary),
      side: const BorderSide(color: accentColor),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: textPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 32,
      ),
      headlineMedium: TextStyle(
        color: textPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 24,
      ),
      titleLarge: TextStyle(
        color: textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 20,
      ),
      titleMedium: TextStyle(
        color: textPrimary,
        fontWeight: FontWeight.w500,
        fontSize: 16,
      ),
      bodyLarge: TextStyle(color: textPrimary, fontSize: 16),
      bodyMedium: TextStyle(color: textSecondary, fontSize: 14),
      bodySmall: TextStyle(color: textMuted, fontSize: 12),
    ),
    dividerTheme: DividerThemeData(
      color: accentColor.withValues(alpha: 0.5),
      thickness: 1,
      space: 1,
    ),
    iconTheme: const IconThemeData(color: textSecondary),
  );
}
