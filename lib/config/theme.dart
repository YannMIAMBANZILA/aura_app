import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Chartre de couleurs "Digital Bioluminescence"
class AppColors {
  // Couleurs principales
  static const Color deepSpaceBlue = Color(0xFF0F172A); // Fond principal
  static const Color electricCyan = Color(0xFF00F0FF); // Primaire
  static const Color mintNeon = Color(0xFF4ADE80); // Succès

  // Nuances de Deep Space Blue
  static const Color spaceBlue900 = Color(0xFF0F172A);
  static const Color spaceBlue800 = Color(0xFF1E293B);
  static const Color spaceBlue700 = Color(0xFF334155);
  static const Color spaceBlue600 = Color(0xFF475569);

  // Nuances d'Electric Cyan
  static const Color cyan500 = Color(0xFF00F0FF);
  static const Color cyan400 = Color(0xFF33F3FF);
  static const Color cyan300 = Color(0xFF66F6FF);
  static const Color cyan600 = Color(0xFF00BDC4);

  // Nuances de Mint Neon
  static const Color mint500 = Color(0xFF4ADE80);
  static const Color mint400 = Color(0xFF71E89D);
  static const Color mint300 = Color(0xFF9FF2BA);

  // Couleurs supplémentaires pour le thème
  static const Color error = Color(0xFFFF6B6B);
  static const Color warning = Color(0xFFFFD93D);
  static const Color info = Color(0xFF4DABF7);

  // Nuances de gris pour le texte et les surfaces
  static const Color gray50 = Color(0xFFF8FAFC);
  static const Color gray100 = Color(0xFFF1F5F9);
  static const Color gray200 = Color(0xFFE2E8F0);
  static const Color gray300 = Color(0xFFCBD5E1);
  static const Color gray400 = Color(0xFF94A3B8);
  static const Color gray500 = Color(0xFF64748B);
  static const Color gray600 = Color(0xFF475569);
  static const Color gray700 = Color(0xFF334155);
  static const Color gray800 = Color(0xFF1E293B);
  static const Color gray900 = Color(0xFF0F172A);
}

/// Thème Dark Mode "Digital Bioluminescence"
class AppTheme {
  /// Retourne le ThemeData pour le mode sombre
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Couleur de fond principale
      scaffoldBackgroundColor: AppColors.deepSpaceBlue,
      primaryColor: AppColors.electricCyan,

      // Palette de couleurs
      colorScheme: const ColorScheme.dark(
        primary: AppColors.electricCyan,
        onPrimary: AppColors.deepSpaceBlue,
        primaryContainer: AppColors.spaceBlue800,
        onPrimaryContainer: AppColors.electricCyan,
        secondary: AppColors.cyan400,
        onSecondary: AppColors.deepSpaceBlue,
        tertiary: AppColors.mintNeon,
        onTertiary: AppColors.deepSpaceBlue,
        error: AppColors.error,
        onError: Colors.white,
        errorContainer: Color(0xFFFFE5E5),
        onErrorContainer: AppColors.error,
        surface: AppColors.spaceBlue800,
        onSurface: AppColors.gray100,
        surfaceContainerHighest: AppColors.spaceBlue700,
        onSurfaceVariant: AppColors.gray300,
        outline: AppColors.spaceBlue600,
        outlineVariant: AppColors.spaceBlue700,
        shadow: Colors.black,
        scrim: Colors.black,
        inverseSurface: AppColors.gray100,
        onInverseSurface: AppColors.deepSpaceBlue,
        inversePrimary: AppColors.cyan600,
        surfaceTint: AppColors.electricCyan,
      ),

      // Schéma de couleurs pour le succès
      extensions: <ThemeExtension<dynamic>>[
        CustomColors(
          success: AppColors.mintNeon,
          onSuccess: AppColors.deepSpaceBlue,
          warning: AppColors.warning,
          onWarning: AppColors.deepSpaceBlue,
          info: AppColors.info,
          onInfo: Colors.white,
        ),
      ],

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.deepSpaceBlue,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.electricCyan),
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.electricCyan,
          letterSpacing: -0.5,
        ),
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: GoogleFonts.spaceGrotesk(
          fontSize: 57,
          fontWeight: FontWeight.w700,
          color: AppColors.gray100,
          letterSpacing: -1,
        ),
        displayMedium: GoogleFonts.spaceGrotesk(
          fontSize: 45,
          fontWeight: FontWeight.w700,
          color: AppColors.gray100,
          letterSpacing: -0.5,
        ),
        displaySmall: GoogleFonts.spaceGrotesk(
          fontSize: 36,
          fontWeight: FontWeight.w600,
          color: AppColors.gray100,
          letterSpacing: 0,
        ),
        headlineLarge: GoogleFonts.spaceGrotesk(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: AppColors.gray100,
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.spaceGrotesk(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: AppColors.gray100,
          letterSpacing: 0,
        ),
        headlineSmall: GoogleFonts.spaceGrotesk(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.gray100,
          letterSpacing: 0,
        ),
        titleLarge: GoogleFonts.spaceGrotesk(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.gray100,
          letterSpacing: 0,
        ),
        titleMedium: GoogleFonts.spaceGrotesk(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.gray100,
          letterSpacing: 0.15,
        ),
        titleSmall: GoogleFonts.spaceGrotesk(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.gray100,
          letterSpacing: 0.1,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.gray100,
          letterSpacing: 0.5,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.gray200,
          letterSpacing: 0.25,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.gray300,
          letterSpacing: 0.4,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.gray100,
          letterSpacing: 0.1,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.gray200,
          letterSpacing: 0.5,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.gray300,
          letterSpacing: 0.5,
        ),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.electricCyan,
          foregroundColor: AppColors.deepSpaceBlue,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.electricCyan,
          side: const BorderSide(color: AppColors.electricCyan, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.electricCyan,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.spaceBlue800,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.spaceBlue600, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.spaceBlue600, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.electricCyan, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: GoogleFonts.inter(
          color: AppColors.gray300,
          fontSize: 14,
        ),
        hintStyle: GoogleFonts.inter(
          color: AppColors.gray500,
          fontSize: 14,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.spaceBlue800,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(8),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.spaceBlue800,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.gray100,
        ),
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14,
          color: AppColors.gray200,
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.spaceBlue800,
        selectedItemColor: AppColors.electricCyan,
        unselectedItemColor: AppColors.gray500,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.electricCyan,
        foregroundColor: AppColors.deepSpaceBlue,
        elevation: 4,
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppColors.electricCyan,
        size: 24,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.spaceBlue700,
        thickness: 1,
        space: 1,
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.electricCyan;
          }
          return AppColors.gray500;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.electricCyan.withOpacity(0.5);
          }
          return AppColors.spaceBlue700;
        }),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.electricCyan;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.deepSpaceBlue),
        side: const BorderSide(color: AppColors.spaceBlue600, width: 2),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.spaceBlue700,
        deleteIconColor: AppColors.gray400,
        disabledColor: AppColors.spaceBlue700.withOpacity(0.5),
        selectedColor: AppColors.electricCyan.withOpacity(0.2),
        secondarySelectedColor: AppColors.mintNeon.withOpacity(0.2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: GoogleFonts.inter(
          color: AppColors.gray200,
          fontSize: 14,
        ),
        secondaryLabelStyle: GoogleFonts.inter(
          color: AppColors.gray100,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        brightness: Brightness.dark,
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.spaceBlue700,
        contentTextStyle: GoogleFonts.inter(
          color: AppColors.gray100,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.electricCyan,
        linearTrackColor: AppColors.spaceBlue700,
        circularTrackColor: AppColors.spaceBlue700,
      ),
    );
  }
}

/// Extension de thème personnalisée pour les couleurs supplémentaires
class CustomColors extends ThemeExtension<CustomColors> {
  final Color success;
  final Color onSuccess;
  final Color warning;
  final Color onWarning;
  final Color info;
  final Color onInfo;

  const CustomColors({
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.info,
    required this.onInfo,
  });

  @override
  CustomColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
    Color? info,
    Color? onInfo,
  }) {
    return CustomColors(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
    );
  }

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) {
      return this;
    }
    return CustomColors(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      info: Color.lerp(info, other.info, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
    );
  }
}

/// Helper pour accéder facilement aux couleurs personnalisées
extension CustomColorsExtension on BuildContext {
  CustomColors get customColors =>
      Theme.of(this).extension<CustomColors>() ?? const CustomColors(
            success: AppColors.mintNeon,
            onSuccess: AppColors.deepSpaceBlue,
            warning: AppColors.warning,
            onWarning: AppColors.deepSpaceBlue,
            info: AppColors.info,
            onInfo: Colors.white,
          );
}
