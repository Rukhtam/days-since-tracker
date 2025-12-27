import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/templates.dart';
import '../providers/tracked_items_provider.dart';
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
    HapticFeedback.selectionClick();
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

    HapticFeedback.mediumImpact();

    final provider = context.read<TrackedItemsProvider>();
    final success = await provider.addItem(
      name: _nameController.text.trim(),
      iconName: _selectedIcon,
      recommendedIntervalDays: int.parse(_intervalController.text),
      color: _selectedColor,
      notificationsEnabled: _notificationsEnabled,
    );

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_nameController.text} added')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to add item'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showIconPicker() {
    HapticFeedback.selectionClick();
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
    HapticFeedback.selectionClick();
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
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
                  color: AppColors.divider,
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
                      'Add Item',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
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
    );
  }

  Widget _buildTemplatesSection() {
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
                style: Theme.of(context).textTheme.labelLarge,
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.fromHex(template.color).withValues(alpha: 0.3),
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
                          style: Theme.of(context).textTheme.bodySmall,
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
                      color: AppColors.surfaceVariant,
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
                          style: Theme.of(context).textTheme.bodySmall,
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
                      color: AppColors.surfaceVariant,
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
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Name field
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Item Name',
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
          // Interval field
          TextFormField(
            controller: _intervalController,
            decoration: const InputDecoration(
              labelText: 'Recommended Interval (days)',
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
            title: const Text('Reminder Notifications'),
            subtitle: const Text('Get notified when item is almost due'),
            value: _notificationsEnabled,
            onChanged: (value) {
              HapticFeedback.selectionClick();
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
