import 'package:flutter/material.dart';

ThemeData buildTheme() {
  // Prestige palette: deep navy base with muted gold accent.
  const deepNavy = Color(0xFF0C1B2A);
  const charcoal = Color(0xFF1F2A36);
  const mist = Color(0xFFF4F6FA);
  const accentGold = Color(0xFFBFA064);
  const border = Color(0xFFE2E6ED);

  final colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: deepNavy,
    onPrimary: Colors.white,
    secondary: accentGold,
    onSecondary: deepNavy,
    tertiary: charcoal,
    onTertiary: Colors.white,
    background: mist,
    onBackground: deepNavy,
    surface: Colors.white,
    onSurface: deepNavy,
    surfaceVariant: const Color(0xFFF9FAFD),
    onSurfaceVariant: charcoal,
    error: const Color(0xFFB3261E),
    onError: Colors.white,
    outline: border,
    outlineVariant: border,
    shadow: Colors.black.withOpacity(0.08),
    scrim: Colors.black54,
    inverseSurface: charcoal,
    inversePrimary: accentGold,
  );

  return ThemeData(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: mist,
    fontFamily: 'SF Pro Display',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      foregroundColor: deepNavy,
      centerTitle: false,
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: border),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: border),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    ),
    textTheme: const TextTheme(
      headlineLarge:
          TextStyle(fontWeight: FontWeight.w600, letterSpacing: -0.2),
      headlineMedium:
          TextStyle(fontWeight: FontWeight.w600, letterSpacing: -0.1),
      headlineSmall:
          TextStyle(fontWeight: FontWeight.w600, letterSpacing: -0.05),
      titleLarge: TextStyle(fontWeight: FontWeight.w600),
      titleMedium: TextStyle(fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(height: 1.5),
      bodyMedium: TextStyle(height: 1.5),
      labelLarge: TextStyle(fontWeight: FontWeight.w600),
    ),
    useMaterial3: true,
  );
}
