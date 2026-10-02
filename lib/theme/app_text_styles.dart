import 'package:flutter/material.dart';
import '../utils/constants.dart';

class AppTextStyles {
  static const display = TextStyle(
    color: AppColors.text,
    fontSize: 26,
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
    letterSpacing: 0.8,
  );

  static const body = TextStyle(
    color: AppColors.text,
    fontSize: 14,
    height: 1.35,
  );

  static const muted = TextStyle(
    color: AppColors.mutedText,
    fontSize: 13,
    height: 1.35,
  );

  static const label = TextStyle(
    color: AppColors.mutedText,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
  );
}
