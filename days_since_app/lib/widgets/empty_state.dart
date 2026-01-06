import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/tracked_items_provider.dart';

/// Empty state widget shown when there are no tracked items.
class EmptyState extends StatelessWidget {
  final VoidCallback onAddPressed;

  const EmptyState({
    super.key,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Theme-aware colors for a welcoming look
    final iconBgColor = isDarkMode 
        ? AppColors.primary.withValues(alpha: 0.15)
        : AppColors.primary.withValues(alpha: 0.1);
    final iconColor = AppColors.primary;
    final chipBgColor = isDarkMode 
        ? AppColors.surface
        : Colors.white;
    final chipBorderColor = isDarkMode
        ? AppColors.primary.withValues(alpha: 0.3)
        : AppColors.primary.withValues(alpha: 0.2);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Decorative icon with welcoming gradient feel
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    iconBgColor,
                    AppColors.secondary.withValues(alpha: isDarkMode ? 0.15 : 0.08),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.event_available,
                size: 56,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 32),
            // Title
            Text(
              'No items yet',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? AppColors.textPrimary : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 12),
            // Description
            Text(
              'Start tracking habits and events.\nTap the button below to add your first item.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: isDarkMode ? AppColors.textSecondary : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Add button with gradient
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryVariant],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: onAddPressed,
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text(
                  'Add First Item',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),
            // Suggestions
            _buildSuggestions(context, isDarkMode, chipBgColor, chipBorderColor),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestions(BuildContext context, bool isDarkMode, Color chipBgColor, Color chipBorderColor) {
    return Column(
      children: [
        Text(
          'Popular tracking ideas:',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? AppColors.textSecondary : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            _buildSuggestionChip(context, Icons.content_cut, 'Haircut', isDarkMode, chipBgColor, chipBorderColor),
            _buildSuggestionChip(context, Icons.directions_car, 'Oil Change', isDarkMode, chipBgColor, chipBorderColor),
            _buildSuggestionChip(context, Icons.bed, 'Bedsheets', isDarkMode, chipBgColor, chipBorderColor),
            _buildSuggestionChip(context, Icons.brush, 'Toothbrush', isDarkMode, chipBgColor, chipBorderColor),
            _buildSuggestionChip(context, Icons.water_drop, 'Water Filter', isDarkMode, chipBgColor, chipBorderColor),
          ],
        ),
      ],
    );
  }

  Widget _buildSuggestionChip(
      BuildContext context, IconData icon, String label, bool isDarkMode, Color chipBgColor, Color chipBorderColor) {
    return InkWell(
      onTap: () => _createItemFromTemplate(context, icon, label),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: chipBgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: chipBorderColor,
            width: 1,
          ),
          boxShadow: isDarkMode ? null : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: isDarkMode ? AppColors.textPrimary : AppColors.textPrimaryLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Create a tracked item from a template suggestion
  void _createItemFromTemplate(
      BuildContext context, IconData icon, String label) {
    final provider = context.read<TrackedItemsProvider>();

    // Get icon name from IconData
    final iconName = _getIconName(icon);

    // Create new item with smart defaults using named parameters
    provider.addItem(
      name: label,
      iconName: iconName,
      color: AppColors.toHex(AppColors.accentBlue),
      recommendedIntervalDays: _getDefaultInterval(label),
      lastResetDate: DateTime.now(),
      notificationsEnabled: false,
    );

    // Show success feedback
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$label added successfully!'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Get default interval days for common items
  int _getDefaultInterval(String itemName) {
    switch (itemName) {
      case 'Haircut':
        return 30;
      case 'Oil Change':
        return 90;
      case 'Bedsheets':
        return 14;
      case 'Toothbrush':
        return 90;
      case 'Water Filter':
        return 180;
      default:
        return 30;
    }
  }

  /// Get icon name string from IconData
  String _getIconName(IconData icon) {
    if (icon == Icons.content_cut) return 'content_cut';
    if (icon == Icons.directions_car) return 'directions_car';
    if (icon == Icons.bed) return 'bed';
    if (icon == Icons.brush) return 'brush';
    if (icon == Icons.water_drop) return 'water_drop';
    return 'event_available';
  }
}
