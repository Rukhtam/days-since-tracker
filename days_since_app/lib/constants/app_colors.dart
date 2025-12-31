import 'package:flutter/material.dart';

/// App-wide color constants following Material Design 3.
/// Supports both dark and light theme designs.
class AppColors {
  // Prevent instantiation
  AppColors._();

  // ========== Dark Theme Colors ==========

  // Background colors (dark)
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color surfaceVariant = Color(0xFF2C2C2C);
  static const Color cardBackground = Color(0xFF1E1E1E);

  // Text colors (dark)
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color textTertiary = Color(0xFF757575);

  // Divider and border colors (dark)
  static const Color divider = Color(0xFF2C2C2C);
  static const Color border = Color(0xFF3C3C3C);

  // ========== Light Theme Colors ==========

  // Background colors (light)
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF0F0F0);
  static const Color cardBackgroundLight = Color(0xFFFFFFFF);

  // Text colors (light)
  static const Color textPrimaryLight = Color(0xFF1C1B1F);
  static const Color textSecondaryLight = Color(0xFF49454F);
  static const Color textTertiaryLight = Color(0xFF79747E);

  // Divider and border colors (light)
  static const Color dividerLight = Color(0xFFE0E0E0);
  static const Color borderLight = Color(0xFFCAC4D0);

  // ========== Shared Colors (both themes) ==========

  // Status colors - These stay consistent across themes for recognition
  static const Color statusGood = Color(0xFF4CAF50);
  static const Color statusWarning = Color(0xFFFFC107);
  static const Color statusOverdue = Color(0xFFF44336);

  // Accent colors for items - These work well on both backgrounds
  static const Color accentBlue = Color(0xFF2196F3);
  static const Color accentPurple = Color(0xFF9C27B0);
  static const Color accentTeal = Color(0xFF009688);
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color accentPink = Color(0xFFE91E63);
  static const Color accentIndigo = Color(0xFF3F51B5);
  static const Color accentCyan = Color(0xFF00BCD4);
  static const Color accentLime = Color(0xFFCDDC39);

  // Interactive colors - Primary and secondary
  static const Color primary = Color(0xFF6200EE);
  static const Color primaryVariant = Color(0xFF3700B3);
  static const Color primaryLight = Color(0xFF6750A4);
  static const Color primaryContainerLight = Color(0xFFEADDFF);
  static const Color secondary = Color(0xFF03DAC6);
  static const Color secondaryLight = Color(0xFF625B71);

  // Error colors
  static const Color error = Color(0xFFCF6679);
  static const Color errorLight = Color(0xFFB3261E);

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
    '#2196F3', // Blue
    '#9C27B0', // Purple
    '#009688', // Teal
    '#FF9800', // Orange
    '#E91E63', // Pink
    '#3F51B5', // Indigo
    '#00BCD4', // Cyan
    '#CDDC39', // Lime
    '#4CAF50', // Green
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
