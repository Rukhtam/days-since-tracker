import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/templates.dart';
import '../providers/settings_provider.dart';
import '../providers/tracked_items_provider.dart';
import '../services/haptic_service.dart';
import '../utils/icon_utils.dart';
import 'icon_picker.dart';
import 'color_picker.dart';

/// Bottom sheet dialog for adding a new tracked item.
class AddItemDialog extends StatefulWidget {
  const AddItemDialog({super.key});

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _intervalController = TextEditingController();

  String _selectedIcon = 'check_circle';
  String _selectedColor = AppColors.accentColorHexCodes[0];
  bool _notificationsEnabled = true;
  bool _showTemplates = true;

  @override
  void dispose() {
    _nameController.dispose();
    _intervalController.dispose();
    super.dispose();
  }

  void _selectTemplate(ItemTemplate template) {
    if (context.read<SettingsProvider>().hapticFeedbackEnabled) {
      HapticService.selectionClick();
    }
    setState(() {
      _nameController.text = template.name;
      _intervalController.text = template.recommendedIntervalDays.toString();
      _selectedIcon = template.iconName;
      _selectedColor = template.color;
      _showTemplates = false;
    });
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    if (context.read<SettingsProvider>().hapticFeedbackEnabled) {
      HapticService.mediumImpact();
    }

    final provider = context.read<TrackedItemsProvider>();
    final success = await provider.addItem(
      name: _nameController.text.trim(),
      iconName: _selectedIcon,
      recommendedIntervalDays: int.parse(_intervalController.text),
      color: _selectedColor,
      notificationsEnabled: _notificationsEnabled,
    );

    if (mounted) {
      final messenger = ScaffoldMessenger.of(context);
      // Clear any existing snackbars to prevent stacking when performing rapid operations
      messenger.clearSnackBars();

      if (success) {
        Navigator.pop(context);
        messenger.showSnackBar(
          SnackBar(content: Text('${_nameController.text} added')),
        );
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to add item'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showIconPicker() {
    if (context.read<SettingsProvider>().hapticFeedbackEnabled) {
      HapticService.selectionClick();
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => IconPicker(
        selectedIcon: _selectedIcon,
        onIconSelected: (iconName) {
          setState(() => _selectedIcon = iconName);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showColorPicker() {
    if (context.read<SettingsProvider>().hapticFeedbackEnabled) {
      HapticService.selectionClick();
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ColorPickerSheet(
        selectedColor: _selectedColor,
        onColorSelected: (color) {
          setState(() => _selectedColor = color);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Theme-aware colors
    final backgroundColor = isDarkMode
        ? AppColors.surface
        : AppColors.surfaceLight;
    final dividerColor = isDarkMode
        ? AppColors.divider
        : AppColors.dividerLight;
    final textPrimaryColor = isDarkMode
        ? AppColors.textPrimary
        : AppColors.textPrimaryLight;
    final textSecondaryColor = isDarkMode
        ? AppColors.textSecondary
        : AppColors.textSecondaryLight;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
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
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Add Item',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: textPrimaryColor,
                            ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: textSecondaryColor),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Templates section
                        if (_showTemplates) ...[
                          Text(
                            'Quick Add from Templates',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          _buildTemplatesSection(),
                          const SizedBox(height: 8),
                          Center(
                            child: TextButton(
                              onPressed: () =>
                                  setState(() => _showTemplates = false),
                              child: const Text('Or create custom item'),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ] else ...[
                          // Custom item form
                          _buildCustomItemForm(),
                        ],
                      ],
                    ),
                  ),
                ),
                // Save button
                if (!_showTemplates)
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveItem,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Add Item'),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTemplatesSection() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final templatesByCategory = Templates.byCategory;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: templatesByCategory.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                entry.key,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: isDarkMode
                      ? AppColors.textSecondary
                      : AppColors.textSecondaryLight,
                ),
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: entry.value.map((template) {
                return InkWell(
                  onTap: () => _selectTemplate(template),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? AppColors.surfaceVariant
                          : AppColors.surfaceVariantLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.fromHex(
                          template.color,
                        ).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          IconUtils.getIconData(template.iconName),
                          size: 16,
                          color: AppColors.fromHex(template.color),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          template.name,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: isDarkMode
                                    ? AppColors.textPrimary
                                    : AppColors.textPrimaryLight,
                              ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildCustomItemForm() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back to templates
          TextButton.icon(
            onPressed: () => setState(() => _showTemplates = true),
            icon: const Icon(Icons.arrow_back, size: 18),
            label: const Text('Back to templates'),
          ),
          const SizedBox(height: 16),
          // Icon and color pickers row
          Row(
            children: [
              // Icon picker
              Expanded(
                child: InkWell(
                  onTap: _showIconPicker,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? AppColors.surfaceVariant
                          : AppColors.surfaceVariantLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          IconUtils.getIconData(_selectedIcon),
                          size: 32,
                          color: AppColors.fromHex(_selectedColor),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Icon',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: isDarkMode
                                    ? AppColors.textSecondary
                                    : AppColors.textSecondaryLight,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Color picker
              Expanded(
                child: InkWell(
                  onTap: _showColorPicker,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? AppColors.surfaceVariant
                          : AppColors.surfaceVariantLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.fromHex(_selectedColor),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Color',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: isDarkMode
                                    ? AppColors.textSecondary
                                    : AppColors.textSecondaryLight,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Name field with visible label
          Text(
            'Item Name',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'e.g., Haircut, Oil Change',
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a name';
              }
              if (value.trim().length > 50) {
                return 'Name must be less than 50 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Interval field with visible label
          Text(
            'Recommended Interval (days)',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _intervalController,
            decoration: const InputDecoration(
              hintText: 'e.g., 30',
              suffixText: 'days',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an interval';
              }
              final interval = int.tryParse(value);
              if (interval == null || interval <= 0) {
                return 'Interval must be greater than 0';
              }
              if (interval > 3650) {
                return 'Interval must be less than 10 years';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          // Notifications toggle
          SwitchListTile(
            title: Text(
              'Reminder Notifications',
              style: TextStyle(
                color: isDarkMode
                    ? AppColors.textPrimary
                    : AppColors.textPrimaryLight,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              'Get notified when item is almost due',
              style: TextStyle(
                color: isDarkMode
                    ? AppColors.textSecondary
                    : AppColors.textSecondaryLight,
              ),
            ),
            value: _notificationsEnabled,
            onChanged: (value) {
              if (context.read<SettingsProvider>().hapticFeedbackEnabled) {
                HapticService.selectionClick();
              }
              setState(() => _notificationsEnabled = value);
            },
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
