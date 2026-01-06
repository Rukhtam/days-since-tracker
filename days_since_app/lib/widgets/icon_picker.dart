import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../providers/settings_provider.dart';
import '../services/haptic_service.dart';
import '../utils/icon_utils.dart';

/// Bottom sheet for selecting an icon.
class IconPicker extends StatelessWidget {
  final String selectedIcon;
  final Function(String) onIconSelected;

  const IconPicker({
    super.key,
    required this.selectedIcon,
    required this.onIconSelected,
  });

  @override
  Widget build(BuildContext context) {
    final iconsByCategory = IconUtils.iconsByCategory;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Theme-aware colors
    final backgroundColor = isDarkMode
        ? AppColors.surface
        : AppColors.surfaceLight;
    final dividerColor = isDarkMode
        ? AppColors.divider
        : AppColors.dividerLight;
    final surfaceVariantColor = isDarkMode
        ? AppColors.surfaceVariant
        : AppColors.surfaceVariantLight;
    final textSecondaryColor = isDarkMode
        ? AppColors.textSecondary
        : AppColors.textSecondaryLight;
    final textPrimaryColor = isDarkMode
        ? AppColors.textPrimary
        : AppColors.textPrimaryLight;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Choose Icon',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(color: textPrimaryColor),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: textSecondaryColor),
                    ),
                  ],
                ),
              ),
              // Icon grid
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: iconsByCategory.length,
                  itemBuilder: (context, index) {
                    final category = iconsByCategory.keys.elementAt(index);
                    final icons = iconsByCategory[category]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            category,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(color: textSecondaryColor),
                          ),
                        ),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 6,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                              ),
                          itemCount: icons.length,
                          itemBuilder: (context, iconIndex) {
                            final iconName = icons[iconIndex];
                            final isSelected = iconName == selectedIcon;

                            return InkWell(
                              onTap: () {
                                if (context.read<SettingsProvider>().hapticFeedbackEnabled) {
                                  HapticService.selectionClick();
                                }
                                onIconSelected(iconName);
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary.withValues(alpha: 0.2)
                                      : surfaceVariantColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: isSelected
                                      ? Border.all(
                                          color: AppColors.primary,
                                          width: 2,
                                        )
                                      : null,
                                ),
                                child: Icon(
                                  IconUtils.getIconData(iconName),
                                  color: isSelected
                                      ? AppColors.primary
                                      : textSecondaryColor,
                                  size: 24,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
