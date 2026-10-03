import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// App-wide theme definitions — dark and light.
class AppTheme {
  AppTheme._();

  // ── Shared helpers ─────────────────────────────────────────────────────────
  static TextTheme _textTheme(Color baseColor) =>
      GoogleFonts.outfitTextTheme(ThemeData(brightness: Brightness.dark).textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w800, color: baseColor, letterSpacing: -1),
        headlineLarge: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w800, color: baseColor, letterSpacing: -0.5),
        headlineMedium: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: baseColor),
        titleLarge: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: baseColor),
        titleMedium: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: baseColor),
        bodyLarge: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w400, color: baseColor, height: 1.5),
        bodyMedium: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w400, color: baseColor, height: 1.5),
        labelLarge: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700),
        labelMedium: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600),
        labelSmall: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5),
      );

  // ── Dark Theme ─────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    const bg = AppColors.bgDark;
    const surface = AppColors.surfaceDark;
    const border = AppColors.borderDark;
    const text = AppColors.textDark;
    const muted = AppColors.mutedDark;

    final scheme = ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.accent,
      onSecondary: Colors.white,
      surface: surface,
      onSurface: text,
      error: AppColors.error,
      onError: Colors.white,
      outline: border,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      textTheme: _textTheme(text),

      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: bg,
        foregroundColor: text,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: text,
          letterSpacing: -0.3,
        ),
      ),

      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: border, width: 1),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark2,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1.8),
        ),
        labelStyle: GoogleFonts.outfit(color: muted, fontSize: 14),
        hintStyle: GoogleFonts.outfit(color: muted, fontSize: 14),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, 50),
          elevation: 0,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 15, letterSpacing: 0.1),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: border, width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 13),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: GoogleFonts.outfit(
          color: text,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceDark2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        height: 70,
        backgroundColor: surface,
        elevation: 0,
        indicatorColor: AppColors.primaryMuted,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
            color: states.contains(WidgetState.selected) ? AppColors.primary : muted,
          );
        }),
      ),

      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),

      checkboxTheme: CheckboxThemeData(
        side: const BorderSide(color: border, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? AppColors.primary : null,
        ),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.surfaceDark2,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceDark2,
        selectedColor: AppColors.primaryMuted,
        side: const BorderSide(color: border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        labelStyle: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: text),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceDark2,
        contentTextStyle: GoogleFonts.outfit(color: text, fontSize: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  // ── Light Theme ────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    const bg = AppColors.bgLight;
    const surface = AppColors.surfaceLight;
    const surface2 = AppColors.surfaceLight2;
    const border = AppColors.borderLight;
    const text = AppColors.textLight;
    const muted = AppColors.mutedLight;

    final scheme = ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.accent,
      onSecondary: Colors.white,
      surface: surface,
      onSurface: text,
      error: AppColors.error,
      onError: Colors.white,
      outline: border,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      textTheme: _textTheme(text),

      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: bg,
        foregroundColor: text,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: text,
          letterSpacing: -0.3,
        ),
      ),

      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: border, width: 1),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface2,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1.8),
        ),
        labelStyle: GoogleFonts.outfit(color: muted, fontSize: 14),
        hintStyle: GoogleFonts.outfit(color: muted, fontSize: 14),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, 50),
          elevation: 0,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: border, width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 13),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: GoogleFonts.outfit(color: text, fontSize: 18, fontWeight: FontWeight.w700),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        height: 70,
        backgroundColor: surface,
        elevation: 0,
        indicatorColor: AppColors.primaryLight,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
            color: states.contains(WidgetState.selected) ? AppColors.primary : muted,
          );
        }),
      ),

      dividerTheme: const DividerThemeData(color: border, thickness: 1, space: 1),

      checkboxTheme: CheckboxThemeData(
        side: const BorderSide(color: border, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? AppColors.primary : null,
        ),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.surfaceLight2,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: surface2,
        selectedColor: AppColors.primaryLight,
        side: const BorderSide(color: border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        labelStyle: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: text),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: text,
        contentTextStyle: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
