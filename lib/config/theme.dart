import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuraColors {
  // Palette Bioluminescence
  static const Color deepSpaceBlue = Color(0xFF0F172A); // Fond
  static const Color abyssalGrey = Color(0xFF1E293B);   // Cartes
  static const Color electricCyan = Color(0xFF00F0FF);  // Primaire / Glow
  static const Color mintNeon = Color(0xFF4ADE80);      // Succès
  static const Color softCoral = Color(0xFFF87171);     // Erreur / Alert
  static const Color starlightWhite = Color(0xFFF1F5F9); // Texte

  static const Color background = Color(0xFF0A0E14); // Noir profond
  static const Color cyan = Color(0xFF00FBFF);       // Cyan Électrique
  static const Color purple = Color(0xFFBC00FF);     // Violet Néon
  static const Color green = Color(0xFF39FF14);      // Vert Acide
  static const Color orange = Color(0xFFFFAC00);     // Orange Sunset
}

class AuraTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AuraColors.deepSpaceBlue,
      
      // Configuration des Textes (Google Fonts)
      textTheme: TextTheme(
        displayLarge: GoogleFonts.spaceGrotesk(
          fontSize: 32, fontWeight: FontWeight.bold, color: AuraColors.starlightWhite
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16, color: AuraColors.starlightWhite
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14, color: AuraColors.starlightWhite.withOpacity(0.8)
        ),
      ),

      // Configuration des Couleurs
      colorScheme: const ColorScheme.dark(
        primary: AuraColors.electricCyan,
        secondary: AuraColors.mintNeon,
        surface: AuraColors.abyssalGrey,
        background: AuraColors.deepSpaceBlue,
      ),
    );
  }
}

class AuraTextStyles {
  static TextStyle subtitle = GoogleFonts.spaceGrotesk(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AuraColors.starlightWhite.withOpacity(0.6),
    letterSpacing: 2,
  );
}