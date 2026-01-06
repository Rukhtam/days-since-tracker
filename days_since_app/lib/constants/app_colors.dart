import 'package:flutter/material.dart';

/// App-wide color constants following Modern Minimalist design.
/// Supports both "Soft Minimal" (Light) and "Midnight Neon" (Dark) themes.
class AppColors {
  // Prevent instantiation
  AppColors._();

  // ========== Dark Theme Colors ("Midnight Neon") ==========

  // Background colors (dark) - Deep Slate, richer than pure black
  static const Color background = Color(0xFF0F172A);
  static const Color surface = Color(0xFF1E293B);
  static const Color surfaceVariant = Color(0xFF334155);
  static const Color cardBackground = Color(0xFF1E293B);

  // Text colors (dark) - High contrast off-white
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textTertiary = Color(0xFF64748B);

  // Divider and border colors (dark)
  static const Color divider = Color(0xFF334155);
  static const Color border = Color(0xFF475569);

  // ========== Light Theme Colors ("Soft Minimal") ==========

  // Background colors (light) - Off-white/Blue-grey, never pure white
  static const Color backgroundLight = Color(0xFFF2F5F9);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFE2E8F0);
  static const Color cardBackgroundLight = Color(0xFFFFFFFF);

  // Text colors (light) - Slate dark, softer than pure black
  static const Color textPrimaryLight = Color(0xFF1E293B);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textTertiaryLight = Color(0xFF94A3B8);

  // Divider and border colors (light)
  static const Color dividerLight = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFCBD5E1);

  // ========== Shared Colors (both themes) ==========

  // Status colors - Modern neon pastels
  static const Color statusGood = Color(0xFF34D399);      // Neon green/teal
  static const Color statusWarning = Color(0xFFFBBF24);   // Warm amber
  static const Color statusOverdue = Color(0xFFEF4444);   // Alert red

  // Accent colors for items - Neon pastels
  static const Color accentBlue = Color(0xFF29B6F6);      // Light blue
  static const Color accentPurple = Color(0xFFA78BFA);    // Pastel purple
  static const Color accentTeal = Color(0xFF2DD4BF);      // Teal/Cyan
  static const Color accentOrange = Color(0xFFFB923C);    // Warm orange
  static const Color accentPink = Color(0xFFF472B6);      // Pink
  static const Color accentIndigo = Color(0xFF818CF8);    // Indigo
  static const Color accentCyan = Color(0xFF22D3EE);      // Cyan
  static const Color accentLime = Color(0xFFA3E635);      // Lime green

  // Interactive colors - Modern purple
  static const Color primary = Color(0xFF6C63FF);         // Modern purple
  static const Color primaryVariant = Color(0xFF5B52E0);
  static const Color primaryLight = Color(0xFF8B83FF);
  static const Color primaryContainerLight = Color(0xFFE8E6FF);
  static const Color secondary = Color(0xFF34D399);       // Neon green
  static const Color secondaryLight = Color(0xFF64748B);

  // Error colors
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFDC2626);

  // Overlay colors
  static const Color overlay = Color(0x80000000);
  static const Color scrim = Color(0xB3000000);

  /// List of available accent colors for item selection
  static const List<Color> accentColors = [
    accentBlue,
    accentPurple,
    accentTeal,
    accentOrange,
    accentPink,
    accentIndigo,
    accentCyan,
    accentLime,
    statusGood,
  ];

  /// List of accent color hex codes for storage
  static const List<String> accentColorHexCodes = [
    '#29B6F6', // Light Blue
    '#A78BFA', // Pastel Purple
    '#2DD4BF', // Teal
    '#FB923C', // Orange
    '#F472B6', // Pink
    '#818CF8', // Indigo
    '#22D3EE', // Cyan
    '#A3E635', // Lime
    '#34D399', // Neon Green
  ];

  /// Convert hex string to Color
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Convert Color to hex string
  static String toHex(Color color) {
    final int argb = color.toARGB32();
    return '#${argb.toRadixString(16).substring(2).toUpperCase()}';
  }

  /// Get status color from ItemStatus
  static Color getStatusColor(String statusColorHex) {
    return fromHex(statusColorHex);
  }
}
