import 'package:flutter/material.dart';

class AppColors {
  // Dark Slate Palette (Default/Developer Mode)
  static const Color darkBg = Color(0xFF0B0F19);      // Deep Midnight Slate
  static const Color darkCard = Color(0xFF161F30);    // Card Surface Slate
  static const Color darkBorder = Color(0xFF222F47);  // Sleek Borders
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);

  // Light Slate Palette
  static const Color lightBg = Color(0xFFF8FAFC);     // Light Slate White
  static const Color lightCard = Color(0xFFFFFFFF);   // Pure White Card
  static const Color lightBorder = Color(0xFFE2E8F0); // Subtle Light Border
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);

  // Accents & Functionals (Harmonious Emerald & Indigo)
  static const Color primary = Color(0xFF10B981);     // Emerald (Success / Work / Main)
  static const Color secondary = Color(0xFF6366F1);   // Indigo (Freelance / Goals)
  static const Color accent = Color(0xFF8B5CF6);      // Purple (Dev / Finance / Highlights)
  static const Color error = Color(0xFFEF4444);       // Coral Red
  static const Color warning = Color(0xFFF59E0B);     // Amber Warning
  static const Color info = Color(0xFF0EA5E9);        // Sky Blue

  // Gradients for Highlights & Premium Glass Cards
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradientDark = LinearGradient(
    colors: [Color(0xFF161F30), Color(0xFF0F1622)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
