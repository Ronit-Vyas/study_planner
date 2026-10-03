import 'package:flutter/material.dart';

class AppColors {
<<<<<<< HEAD
  static const Color primary = Color(0xFF22C55E);
  static const Color primaryDark = Color(0xFF15803D);
  static const Color primaryLight = Color(0xFF142E1F);
  static const Color background = Color(0xFF0F1012);
  static const Color surface = Color(0xFF1A1B1E);
  static const Color surfaceLight = Color(0xFF24262C);
  static const Color text = Color(0xFFF3F4F6);
  static const Color mutedText = Color(0xFF8E929E);
  static const Color divider = Color(0xFF26282E);
  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFF142E1F);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFF332311);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFF3B1818);
  static const Color accent = Color(0xFF38BDF8);

  static const Color highPriority = Color(0xFFEF4444);
  static const Color mediumPriority = Color(0xFFF59E0B);
  static const Color lowPriority = Color(0xFF22C55E);
=======
// ============================================================
// Brand & Primary
// ============================================================

// Main green used for buttons, active states, icons, etc.
static const Color primary = Color(0xFF22C55E); // Green 500

static const Color primaryDark = Color(0xFF16A34A); // Green 600

// Very subtle green tint
static const Color primaryLight = Color(0xFF052E16); // Green 950

static const Color primaryAccent = Color(0xFF4ADE80); // Green 400


// ============================================================
// Secondary & Accents
// ============================================================

static const Color secondary = Color(0xFF10B981); // Emerald 500

static const Color secondaryLight = Color(0xFF34D399); // Emerald 400

static const Color accentViolet = Color(0xFF8B5CF6); // Violet 500

static const Color accentAmber = Color(0xFFF59E0B); // Amber 500


// ============================================================
// Background & Surfaces
// ============================================================

// Main application background
static const Color background = Color(0xFF050505);

// Cards / containers
static const Color surface = Color(0xFF111111);

// Slightly lighter surface
static const Color surfaceSubtle = Color(0xFF181818);

// Borders
static const Color cardBorder = Color(0xFF262626);

// Main text
static const Color text = Color(0xFFF5F5F5);

// Secondary text
static const Color mutedText = Color(0xFF9CA3AF);

// Dividers
static const Color divider = Color(0xFF262626);


// ============================================================
// Status
// ============================================================

static const Color success = Color(0xFF22C55E);
static const Color successLight = Color(0xFF052E16);

static const Color warning = Color(0xFFF59E0B);
static const Color warningLight = Color(0xFF451A03);

static const Color error = Color(0xFFEF4444);
static const Color errorLight = Color(0xFF450A0A);


// ============================================================
// Priorities
// ============================================================

static const Color highPriority = Color(0xFFEF4444);

static const Color mediumPriority = Color(0xFFF59E0B);

static const Color lowPriority = Color(0xFF22C55E);


// ============================================================
// Gradients
// ============================================================

// Main app gradient
static const LinearGradient primaryGradient = LinearGradient(
colors: [
Color(0xFF050505),
Color(0xFF052E16),
Color(0xFF16A34A),
],
begin: Alignment.topLeft,
end: Alignment.bottomRight,
);


// Card gradient
static const LinearGradient cardGradient = LinearGradient(
colors: [
Color(0xFF111111),
Color(0xFF052E16),
],
begin: Alignment.topLeft,
end: Alignment.bottomRight,
);


// Success gradient
static const LinearGradient successGradient = LinearGradient(
colors: [
Color(0xFF22C55E),
Color(0xFF15803D),
],
begin: Alignment.topLeft,
end: Alignment.bottomRight,
);
>>>>>>> 788069d ([fix] UI theme & [imp] Exam Management & Streak Tracking)
}


class AppStrings {
static const String appName = 'Study Planner';
}

