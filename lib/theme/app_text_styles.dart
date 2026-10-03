import 'package:flutter/material.dart';
import '../utils/constants.dart';

class AppTextStyles {
  static const hero = TextStyle(
    color: AppColors.text,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.8,
  );

  static const display = TextStyle(
    color: AppColors.text,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  static const title = TextStyle(
    color: AppColors.text,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
  );

  static const section = TextStyle(
      color: AppColors.mutedText,
      fontSize: 12,
      fontWeight: FontWeight.w700,
    letterSpacing: 0.1,
  );

  static const body = TextStyle(
    color: AppColors.text,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );

  static const bodyBold = TextStyle(
    color: AppColors.text,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const muted = TextStyle(
    color: AppColors.mutedText,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const label = TextStyle(
    color: AppColors.mutedText,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.9,
  );

  static const badge = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
  );

  static const chip = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );
}

