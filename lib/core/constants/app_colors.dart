import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Backgrounds
  static const bg         = Color(0xFF080A0F);
  static const surface    = Color(0xFF0D0F14);
  static const card       = Color(0xFF111318);
  static const border     = Color(0x0FFFFFFF); // white 6%

  // Accents — white-glow theme
  static const white      = Color(0xFFFFFFFF);
  static const whiteDim   = Color(0xEBFFFFFF); // white 92%
  static const green      = Color(0xFF7EE8A2); // soft green (status only)
  static const blue       = Color(0xFF7EB8F7); // soft blue (tab dots)
  static const purple     = Color(0xFFC792EA); // syntax purple

  // Text
  static const textPrimary   = Color(0xFFE8EAF0);
  static const textSecondary = Color(0x8AFFFFFF); // white 54%
  static const textMuted     = Color(0x40FFFFFF); // white 25%

  // Gradients
  static const gradientWhite = LinearGradient(
    colors: [Color(0xEBFFFFFF), Color(0xCCFFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientCard = LinearGradient(
    colors: [Color(0xFF111318), Color(0xFF0D0F14)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}