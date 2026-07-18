import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NeoTheme {
  // Brand Colors
  static const Color bgBase = Color(0xFFFAF7F0);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color borderStrong = Color(0xFF0A0A0A);
  static const Color accentBlue = Color(0xFF4D7CFE);
  static const Color accentGreen = Color(0xFF3FCB6E);
  static const Color accentYellow = Color(0xFFFFC93C);
  static const Color accentPink = Color(0xFFFF3D9A);
  static const Color textPrimary = Color(0xFF0A0A0A);
  static const Color textMuted = Color(0xFF6B6B6B);
  static const Color badgePro = Color(0xFF0A0A0A);

  // Border & Shadow configurations
  static const double borderWidth = 2.5;

  static BoxBorder get neoBorder => Border.all(
        color: borderStrong,
        width: borderWidth,
      );

  static List<BoxShadow> neoShadow({
    Color shadowColor = borderStrong,
    Offset offset = const Offset(4, 4),
  }) {
    return [
      BoxShadow(
        color: shadowColor,
        offset: offset,
        blurRadius: 0,
        spreadRadius: 0,
      ),
    ];
  }

  // Get custom BoxDecoration helper
  static BoxDecoration neoBoxDecoration({
    Color color = surfaceCard,
    double borderRadius = 20.0,
    bool hasShadow = true,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(borderRadius),
      border: neoBorder,
      boxShadow: hasShadow ? neoShadow() : null,
    );
  }

  // Core Theme definition
  static ThemeData get themeData {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: bgBase,
      primaryColor: accentPink,
      colorScheme: const ColorScheme.light(
        primary: accentPink,
        secondary: accentYellow,
        surface: surfaceCard,
      ),
      textTheme: baseTextTheme.copyWith(
        titleLarge: GoogleFonts.plusJakartaSans(
          color: textPrimary,
          fontWeight: FontWeight.w900,
          fontSize: 22,
        ),
        titleMedium: GoogleFonts.plusJakartaSans(
          color: textPrimary,
          fontWeight: FontWeight.w800,
          fontSize: 18,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          color: textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          color: textPrimary,
          fontSize: 14,
        ),
        bodySmall: GoogleFonts.plusJakartaSans(
          color: textMuted,
          fontSize: 12,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
