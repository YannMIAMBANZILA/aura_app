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