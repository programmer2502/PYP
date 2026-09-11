import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Brand Colors (Cinematic Obsidian & Platinum White - from App Icon)
  static const Color primary = Color(0xFF090C15); // Signature Jet Obsidian from App Icon
  static const Color primaryDark = Color(0xFF000000); // Pure Pitch Black
  static const Color primaryLight = Color(0xFF1E293B); // Deep Studio Slate
  static const Color primaryContainer = Color(0xFFF1F5F9); // Platinum Mist Container
  static const Color primaryGradientStart = Color(0xFF090C15);
  static const Color primaryGradientEnd = Color(0xFF1E293B);

  // Midnight Obsidian & Deep Slate (Hero Cards, Headers & High Contrast Studio Surfaces)
  static const Color darkHeader = Color(0xFF07090E); // Deep Midnight Obsidian
  static const Color darkHeaderCard = Color(0xFF111726); // Studio Lens Charcoal
  static const Color darkHeaderSubtitle = Color(0xFF94A3B8); // Cool Silver Slate
  static const Color glassWhite = Color(0x26FFFFFF); // Translucent 15% white
  static const Color glassWhiteBorder = Color(0x33FFFFFF); // Translucent 20% white
  static const Color luminousWhite = Color(0xFFFFFFFF); // Pure Arc White from Icon
  static const Color silverAccent = Color(0xFFCBD5E1); // Cool Silver Halo

  // Secondary & Pastel Category Badges
  static const Color badgeGreenBg = Color(0xFFECFDF5);
  static const Color badgeGreenIcon = Color(0xFF059669);

  static const Color badgeCoralBg = Color(0xFFFFF1F2);
  static const Color badgeCoralIcon = Color(0xFFE11D48);

  static const Color badgePinkBg = Color(0xFFFDF2F8);
  static const Color badgePinkIcon = Color(0xFFDB2777);

  static const Color badgeSkyBg = Color(0xFFF0F9FF);
  static const Color badgeSkyIcon = Color(0xFF0284C7);

  static const Color badgeAmberBg = Color(0xFFFFFBEB);
  static const Color badgeAmberIcon = Color(0xFFD97706);

  static const Color badgePurpleBg = Color(0xFFFAF5FF);
  static const Color badgePurpleIcon = Color(0xFF9333EA);

  // General Accents
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color accentRose = Color(0xFFF43F5E);
  static const Color accentEmerald = Color(0xFF10B981);
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color accentIndigo = Color(0xFF6366F1);

  // Light Mode Canvas & Surfaces (Crisp High-Key Studio Canvas)
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardBorderLight = Color(0xFFE2E8F0);
  static const Color chipBorderLight = Color(0xFFE2E8F0);
  static const Color chipSelectedBg = Color(0xFF090C15);
  static const Color chipSelectedBorder = Color(0xFF090C15);

  // Dark Mode Canvas & Surfaces
  static const Color backgroundDark = Color(0xFF07090E);
  static const Color surfaceDark = Color(0xFF0F141F);
  static const Color cardDark = Color(0xFF182030);
  static const Color cardBorderDark = Color(0xFF334155);

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF090D16);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textMutedLight = Color(0xFF94A3B8);

  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);

  // Status & Feedback
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF0284C7);

  // Shimmer
  static const Color shimmerBase = Color(0xFFE2E8F0);
  static const Color shimmerHighlight = Color(0xFFF1F5F9);
}
