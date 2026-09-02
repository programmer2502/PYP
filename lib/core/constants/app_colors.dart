import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Brand Colors (Vibrant Emerald Teal & Forest Accents)
  static const Color primary = Color(0xFF00A86B); // Vibrant Emerald Teal from reference UI
  static const Color primaryDark = Color(0xFF047857);
  static const Color primaryLight = Color(0xFF10B981);
  static const Color primaryContainer = Color(0xFFE6F7ED);
  static const Color primaryGradientStart = Color(0xFF00A86B);
  static const Color primaryGradientEnd = Color(0xFF059669);

  // Midnight Obsidian & Deep Slate (Hero Cards, Headers & High Contrast Surfaces)
  static const Color darkHeader = Color(0xFF0B132B); // Deep Midnight Navy/Obsidian
  static const Color darkHeaderCard = Color(0xFF162035);
  static const Color darkHeaderSubtitle = Color(0xFF94A3B8);
  static const Color glassWhite = Color(0x26FFFFFF); // Translucent 15% white
  static const Color glassWhiteBorder = Color(0x33FFFFFF); // Translucent 20% white

  // Secondary & Pastel Category Badges (as seen in reference UI)
  static const Color badgeGreenBg = Color(0xFFE6F7ED);
  static const Color badgeGreenIcon = Color(0xFF059669);

  static const Color badgeCoralBg = Color(0xFFFEECE7);
  static const Color badgeCoralIcon = Color(0xFFEA580C);

  static const Color badgePinkBg = Color(0xFFFCE7F3);
  static const Color badgePinkIcon = Color(0xFFDB2777);

  static const Color badgeSkyBg = Color(0xFFE0F2FE);
  static const Color badgeSkyIcon = Color(0xFF0284C7);

  static const Color badgeAmberBg = Color(0xFFFEF3C7);
  static const Color badgeAmberIcon = Color(0xFFD97706);

  static const Color badgePurpleBg = Color(0xFFF3E8FF);
  static const Color badgePurpleIcon = Color(0xFF9333EA);

  // General Accents
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color accentRose = Color(0xFFF43F5E);
  static const Color accentEmerald = Color(0xFF00A86B);
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color accentIndigo = Color(0xFF6366F1);

  // Light Mode Canvas & Surfaces (Crisp, Ultra-Clean Modern UI)
  static const Color backgroundLight = Color(0xFFF7F9FC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardBorderLight = Color(0xFFEEF2F6);
  static const Color chipBorderLight = Color(0xFFE2E8F0);
  static const Color chipSelectedBg = Color(0xFFE6F7ED);
  static const Color chipSelectedBorder = Color(0xFF00A86B);

  // Dark Mode Canvas & Surfaces
  static const Color backgroundDark = Color(0xFF090D16);
  static const Color surfaceDark = Color(0xFF111827);
  static const Color cardDark = Color(0xFF1F2937);
  static const Color cardBorderDark = Color(0xFF374151);

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textMutedLight = Color(0xFF94A3B8);

  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);

  // Status & Feedback
  static const Color success = Color(0xFF00A86B);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF0284C7);

  // Shimmer
  static const Color shimmerBase = Color(0xFFE2E8F0);
  static const Color shimmerHighlight = Color(0xFFF1F5F9);
}
