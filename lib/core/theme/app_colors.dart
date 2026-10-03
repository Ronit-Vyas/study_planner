import 'package:flutter/material.dart';

/// Centralised colour palette for the Study Planner app.
/// All colours are dark-mode first.
class AppColors {
  AppColors._();

  // ── Brand ──────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF6C63FF); // Indigo-violet
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFFEDE9FE); // light tint (light mode)
  static const Color primaryMuted = Color(0xFF312E81); // dark tint (dark mode)

  static const Color accent = Color(0xFF06B6D4); // Cyan
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color accentGreen = Color(0xFF22C55E);
  static const Color accentRose = Color(0xFFF43F5E);
  static const Color accentViolet = Color(0xFF8B5CF6);
  static const Color accentOrange = Color(0xFFF97316);

  // ── Dark surfaces ──────────────────────────────────────────────────────────
  static const Color bgDark = Color(0xFF0A0A0F);
  static const Color surfaceDark = Color(0xFF13131A);
  static const Color surfaceDark2 = Color(0xFF1C1C26);
  static const Color borderDark = Color(0xFF2A2A3C);
  static const Color textDark = Color(0xFFF1F0FF);
  static const Color mutedDark = Color(0xFF8B8BA7);

  // ── Light surfaces ─────────────────────────────────────────────────────────
  static const Color bgLight = Color(0xFFF5F4FF);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceLight2 = Color(0xFFF0EFFF);
  static const Color borderLight = Color(0xFFE2E1F0);
  static const Color textLight = Color(0xFF1A1A2E);
  static const Color mutedLight = Color(0xFF6B6B8A);

  // ── Status ─────────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color successBg = Color(0xFF052E16);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningBg = Color(0xFF451A03);
  static const Color error = Color(0xFFEF4444);
  static const Color errorBg = Color(0xFF450A0A);
  static const Color info = Color(0xFF06B6D4);
  static const Color infoBg = Color(0xFF0C1F2E);

  // ── Priority colours ───────────────────────────────────────────────────────
  static const Color urgent = Color(0xFFDC2626);
  static const Color high = Color(0xFFF97316);
  static const Color medium = Color(0xFFF59E0B);
  static const Color low = Color(0xFF22C55E);

  // ── Subject palette (used for course colour chips) ─────────────────────────
  static const List<Color> subjectPalette = [
    Color(0xFF6C63FF),
    Color(0xFFF43F5E),
    Color(0xFF06B6D4),
    Color(0xFF22C55E),
    Color(0xFFF97316),
    Color(0xFF8B5CF6),
    Color(0xFFF59E0B),
    Color(0xFF10B981),
    Color(0xFFEC4899),
    Color(0xFF3B82F6),
  ];

  // ── Gradients ──────────────────────────────────────────────────────────────
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF312E81)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF13131A), Color(0xFF1C1C26)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF6C63FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient timerGradient = LinearGradient(
    colors: [Color(0xFFF43F5E), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
