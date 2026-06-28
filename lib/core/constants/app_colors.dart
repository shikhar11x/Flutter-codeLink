import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Backgrounds
  static const bg         = Color(0xFF08090A);
  static const surface    = Color(0xFF111318);
  static const card       = Color(0xFF1A1D27);
  static const border     = Color(0xFF2A2D35);

  // Accents
  static const green      = Color(0xFF00FF94);
  static const greenDim   = Color(0xFF00C974);
  static const purple     = Color(0xFFBF5AF2);
  static const blue       = Color(0xFF0A84FF);

  // Text
  static const textPrimary   = Color(0xFFEAEAEA);
  static const textSecondary = Color(0xFF8B8FA8);
  static const textMuted     = Color(0xFF4A4D5A);

  // Gradients
  static const gradientGreen = LinearGradient(
    colors: [Color(0xFF00FF94), Color(0xFF00C974)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientPurple = LinearGradient(
    colors: [Color(0xFFBF5AF2), Color(0xFF9333EA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientCard = LinearGradient(
    colors: [Color(0xFF1A1D27), Color(0xFF111318)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}