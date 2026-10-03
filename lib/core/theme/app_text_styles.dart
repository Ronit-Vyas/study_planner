import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get _base => GoogleFonts.outfit();

  // ── Dark-mode styles ───────────────────────────────────────────────────────
  static TextStyle get display => _base.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: AppColors.textDark,
        letterSpacing: -1.0,
        height: 1.15,
      );

  static TextStyle get hero => _base.copyWith(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: AppColors.textDark,
        letterSpacing: -0.5,
      );

  static TextStyle get title => _base.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
        letterSpacing: -0.3,
      );

  static TextStyle get subtitle => _base.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      );

  static TextStyle get body => _base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textDark,
        height: 1.5,
      );

  static TextStyle get bodyMedium => _base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textDark,
      );

  static TextStyle get bodyBold => _base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
      );

  static TextStyle get caption => _base.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.mutedDark,
      );

  static TextStyle get label => _base.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.mutedDark,
        letterSpacing: 0.5,
      );

  static TextStyle get muted => _base.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.mutedDark,
      );

  static TextStyle get buttonText => _base.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      );

  static TextStyle get chipText => _base.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      );

  // ── Numeric / stat styles ──────────────────────────────────────────────────
  static TextStyle get statLarge => _base.copyWith(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        color: AppColors.textDark,
        letterSpacing: -1.0,
      );

  static TextStyle get statMedium => _base.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
        letterSpacing: -0.5,
      );

  static TextStyle get timerDisplay => _base.copyWith(
        fontSize: 72,
        fontWeight: FontWeight.w800,
        color: Colors.white,
        letterSpacing: -2.0,
      );
}
