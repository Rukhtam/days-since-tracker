import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../models/tracked_item.dart';
import '../providers/tracked_items_provider.dart';
import '../utils/icon_utils.dart';
import 'icon_picker.dart';
import 'color_picker.dart';

/// Bottom sheet dialog for editing an existing tracked item.
class EditItemDialog extends StatefulWidget {
  final TrackedItem item;

  const EditItemDialog({
    super.key,
    required this.item,
  });

  @override
  State<EditItemDialog> createState() => _EditItemDialogState();
}

class _EditItemDialogState extends State<EditItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _intervalController;

  late String _selectedIcon;
  late String _selectedColor;
  late bool _notificationsEnabled;
  late DateTime _lastResetDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _intervalController = TextEditingController(
      text: widget.item.recommendedIntervalDays.toString(),
    );
    _selectedIcon = widget.item.iconName;
    _selectedColor = widget.item.color;
    _notificationsEnabled = widget.item.notificationsEnabled;
    _lastResetDate = widget.item.lastResetDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _intervalController.dispose();
    super.dispose();
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    HapticFeedback.mediumImpact();

    final updatedItem = widget.item.copyWith(
      name: _nameController.text.trim(),
      iconName: _selectedIcon,
      recommendedIntervalDays: int.parse(_intervalController.text),
      color: _selectedColor,
      notificationsEnabled: _notificationsEnabled,
      lastResetDate: _lastResetDate,
    );

    final provider = context.read<TrackedItemsProvider>();
    final success = await provider.updateItem(updatedItem);

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_nameController.text} updated')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to update item'),
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

  Future<void> _pickDate() async {
    HapticFeedback.selectionClick();
    final picked = await showDatePicker(
      context: context,
      initialDate: _lastResetDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.textPrimary,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _lastResetDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
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
                      'Edit Item',
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                        style:
                                            Theme.of(context).textTheme.bodySmall,
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
                                          color:
                                              AppColors.fromHex(_selectedColor),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Color',
                                        style:
                                            Theme.of(context).textTheme.bodySmall,
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
                        // Last reset date
                        InkWell(
                          onTap: _pickDate,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Last Reset Date',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatDate(_lastResetDate),
                                      style:
                                          Theme.of(context).textTheme.titleMedium,
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                const Icon(
                                  Icons.edit,
                                  color: AppColors.textTertiary,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Notifications toggle
                        SwitchListTile(
                          title: const Text('Reminder Notifications'),
                          subtitle:
                              const Text('Get notified when item is almost due'),
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
                  ),
                ),
              ),
              // Save button
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
                      child: const Text('Save Changes'),
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

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
