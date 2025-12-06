import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData buildCatTinderTheme() {
  final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);
  final colorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFFFF5678),
    brightness: Brightness.dark,
    tertiary: const Color(0xFFFEBA4C),
  );
  return base.copyWith(
    colorScheme: colorScheme,
    textTheme: GoogleFonts.soraTextTheme(
      base.textTheme,
    ).apply(bodyColor: Colors.white, displayColor: Colors.white),
    scaffoldBackgroundColor: const Color(0xFF0D0C12),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.black.withValues(alpha: 0.4),
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: Colors.white70,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),
    cardTheme: CardThemeData(
      color: Colors.white.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Colors.white.withValues(alpha: 0.1),
      contentTextStyle: const TextStyle(color: Colors.white),
    ),
  );
}
