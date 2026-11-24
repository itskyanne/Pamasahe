import 'package:flutter/material.dart';

class AppColors {
  // ==========================================
  // 1. DARK MODE PALETTE (Off-Black & Soft White)
  // ==========================================
  // Base Background (Lowest Layer): Deep obsidian/charcoal
  static const Color darkBgBase = Color(0xFF0B0D10);
  
  // Surface / Cards (Elevated Layer 1)
  static const Color darkSurfaceCard = Color(0xFF16191F);
  
  // Modals / Dropdowns (Elevated Layer 2)
  static const Color darkSurfaceModal = Color(0xFF21252D);
  
  // Subtle Borders & Dividers
  static const Color darkBorderSubtle = Color(0xFF2A2F3A);
  
  // Primary Text (Headings & Body): Soft off-white
  static const Color darkTextPrimary = Color(0xFFF3F4F6);
  
  // Secondary Text (Labels & Subtitles): Muted cool gray
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  
  // Disabled / Muted Text
  static const Color darkTextMuted = Color(0xFF6B7280);
  
  // Dark mode brand accents
  static const Color darkMainGreen = Color(0xFF22C55E);
  static const Color darkMintBg = Color(0xFF132B25);
  static const Color darkMintText = Color(0xFF6EE7B7);
  static const Color darkAmberBg = Color(0xFF33230A);
  static const Color darkAmberText = Color(0xFFFBBF24);
  static const Color darkCoralBg = Color(0xFF3A1412);
  static const Color darkCoralText = Color(0xFFF87171);

  // ==========================================
  // 2. LIGHT MODE PALETTE (Soft White & Charcoal)
  // ==========================================
  // Base Background: Cool off-white canvas
  static const Color lightBgBase = Color(0xFFF8F9FA);
  
  // Surface / Cards: Pure white
  static const Color lightSurfaceCard = Color(0xFFFFFFFF);
  
  // Modals / Dropdowns
  static const Color lightSurfaceModal = Color(0xFFFFFFFF);
  
  // Subtle Borders & Dividers
  static const Color lightBorderSubtle = Color(0xFFE5E7EB);
  
  // Primary Text: Deep charcoal
  static const Color lightTextPrimary = Color(0xFF111827);
  
  // Secondary Text
  static const Color lightTextSecondary = Color(0xFF4B5563);
  
  // Disabled / Muted Text
  static const Color lightTextMuted = Color(0xFF9CA3AF);
  
  // Light mode brand accents
  static const Color lightMainGreen = Color(0xFF1F8A4C);

  // ==========================================
  // 3. LEGACY COMPATIBILITY & BRAND CONSTANTS
  // ==========================================
  // Deep green: Headers, primary text, dark cards
  static const Color deepGreen = Color(0xFF0B3D3A);
  
  // Main green: Primary buttons, active states, savings
  static const Color mainGreen = Color(0xFF1F8A4C);
  static const Color mainGreenHover = Color(0xFF186F3D);

  // Amber: Fastest badges, distance labels, informational cautions
  static const Color amber = Color(0xFFB8690A);
  static const Color amberLight = Color(0xFFFEF3C7);

  // Coral: Warnings, destructive actions, validation errors
  static const Color coral = Color(0xFFC8412B);
  static const Color coralLight = Color(0xFFFDE8E4);

  // Light mint: Cards, selected navigation states, secondary surfaces
  static const Color lightMint = Color(0xFFEAF4F1);
  static const Color mintAccent = Color(0xFFD2E8E1);
  static const Color surfaceMint = Color(0xFFF2F8F6);

  // Neutral tones
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF8FAF9);
  static const Color cardSurface = Color(0xFFFFFFFF);
  
  static const Color textPrimary = Color(0xFF0B3D3A);
  static const Color textSecondary = Color(0xFF5A726E);
  static const Color textMuted = Color(0xFF8DA39F);
  
  static const Color border = Color(0xFFE2ECE8);
  static const Color borderLight = Color(0xFFEDF3F1);
  
  // Tag / Badge colors
  static const Color tagBg = Color(0xFFE9F2EF);
  static const Color tagText = Color(0xFF2C5E58);

  // ==========================================
  // 4. CONTEXTUAL RESOLVERS
  // ==========================================
  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Color bgBase(BuildContext context) =>
      isDark(context) ? darkBgBase : lightBgBase;

  static Color surfaceCard(BuildContext context) =>
      isDark(context) ? darkSurfaceCard : lightSurfaceCard;

  static Color surfaceModal(BuildContext context) =>
      isDark(context) ? darkSurfaceModal : lightSurfaceModal;

  static Color borderSubtle(BuildContext context) =>
      isDark(context) ? darkBorderSubtle : lightBorderSubtle;

  static Color primaryText(BuildContext context) =>
      isDark(context) ? darkTextPrimary : lightTextPrimary;

  static Color secondaryText(BuildContext context) =>
      isDark(context) ? darkTextSecondary : lightTextSecondary;

  static Color mutedText(BuildContext context) =>
      isDark(context) ? darkTextMuted : lightTextMuted;

  static Color brandGreen(BuildContext context) =>
      isDark(context) ? darkMainGreen : lightMainGreen;
}
