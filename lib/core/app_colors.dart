import 'package:flutter/material.dart';

class AppColors {
  // Core Palette
  static const primary   = Color(0xFFF6D1A9);
  static const secondary = Color(0xFF443521);
  static const background = Color(0xFFFDF6EE);

  // Text
  static const Color textPrimary = Colors.black;
  static const Color textSecondary = Colors.black54;

  // Buttons
  static const Color button = Color(0xFF443521);
  static const Color buttonText = Colors.white;

  // AR Overlay specific
  static const Color arSuccess = Color(0xFF443521); // bright green — confirmed point
  static const Color arPending = Color(0xFF443521); // amber — awaiting tap
  static const Color arReticle = Color(0xFF443521); // soft blue — scanning reticle
  static const Color arLine = Color(0xFF443521); // cyan — connecting lines
  static const Color arWarning = Color(0xFF443521); // orange — warnings
  static const Color arError = Color(0xFFFF1744); // red — errors

  // Glass / Overlay surfaces
  static const Color glassBackground = Color(0xFF443521); // dark glass panels
  static const Color glassBorder = Color(0xFF443521); // subtle blue border
}