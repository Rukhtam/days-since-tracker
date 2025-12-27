import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../providers/settings_provider.dart';
import '../providers/tracked_items_provider.dart';
import '../services/notification_service.dart';

/// Settings screen allowing users to configure app behavior.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _checkNotificationPermissions();
  }

  Future<void> _checkNotificationPermissions() async {
    final enabled = await NotificationService().areNotificationsEnabled();
    setState(() {
      _notificationsPermissionGranted = enabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              // Notifications Section
              _buildSectionHeader('Notifications'),
              _buildNotificationSettings(context, settings),
              const SizedBox(height: 16),

              // Display Section
              _buildSectionHeader('Display'),
              _buildDisplaySettings(context, settings),
              const SizedBox(height: 16),

              // Behavior Section
              _buildSectionHeader('Behavior'),
              _buildBehaviorSettings(context, settings),
              const SizedBox(height: 16),

              // Data Section
              _buildSectionHeader('Data'),
              _buildDataSettings(context, settings),
              const SizedBox(height: 16),

              // About Section
              _buildSectionHeader('About'),
              _buildAboutSettings(context),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  /// Build section header with title
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
          fontSize: 14,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// Build notification-related settings
  Widget _buildNotificationSettings(
    BuildContext context,
    SettingsProvider settings,
  ) {
    return Column(
      children: [
        // Master notification toggle
        SwitchListTile(
          title: const Text('Enable Notifications'),
          subtitle: Text(
            _notificationsPermissionGranted
                ? 'Get reminded when items are due'
                : 'Permission required',
            style: TextStyle(
              color: _notificationsPermissionGranted
                  ? AppColors.textSecondary
                  : AppColors.statusWarning,
            ),
          ),
          value: settings.notificationsEnabled && _notificationsPermissionGranted,
          onChanged: (value) async {
            if (!_notificationsPermissionGranted) {
              // Request permission
              final granted = await NotificationService().requestPermissions();
              if (granted) {
                setState(() {
                  _notificationsPermissionGranted = true;
                });
                settings.notificationsEnabled = true;
                _rescheduleAllNotifications();
              } else {
                _showPermissionDeniedDialog();
              }
            } else {
              settings.notificationsEnabled = value;
              if (value) {
                _rescheduleAllNotifications();
              } else {
                NotificationService().cancelAllNotifications();
              }
            }
            _hapticFeedback(settings);
          },
          secondary: Icon(
            settings.notificationsEnabled && _notificationsPermissionGranted
                ? Icons.notifications_active
                : Icons.notifications_off,
            color: settings.notificationsEnabled && _notificationsPermissionGranted
                ? AppColors.primary
                : AppColors.textTertiary,
          ),
        ),

        // Notification time picker
        ListTile(
          enabled: settings.notificationsEnabled && _notificationsPermissionGranted,
          leading: Icon(
            Icons.access_time,
            color: settings.notificationsEnabled && _notificationsPermissionGranted
                ? AppColors.primary
                : AppColors.textTertiary,
          ),
          title: const Text('Notification Time'),
          subtitle: Text(settings.notificationTimeFormatted),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showNotificationTimePicker(context, settings),
        ),
      ],
    );
  }

  /// Build display-related settings
  Widget _buildDisplaySettings(
    BuildContext context,
    SettingsProvider settings,
  ) {
    return Column(
      children: [
        // Sort order
        ListTile(
          leading: const Icon(Icons.sort, color: AppColors.primary),
          title: const Text('Sort Order'),
          subtitle: Text(settings.sortOrderDisplayName),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showSortOrderPicker(context, settings),
        ),
      ],
    );
  }

  /// Build behavior-related settings
  Widget _buildBehaviorSettings(
    BuildContext context,
    SettingsProvider settings,
  ) {
    return Column(
      children: [
        // Haptic feedback toggle
        SwitchListTile(
          title: const Text('Haptic Feedback'),
          subtitle: const Text('Vibrate on actions'),
          value: settings.hapticFeedbackEnabled,
          onChanged: (value) {
            settings.hapticFeedbackEnabled = value;
            if (value) {
              HapticFeedback.mediumImpact();
            }
          },
          secondary: Icon(
            Icons.vibration,
            color: settings.hapticFeedbackEnabled
                ? AppColors.primary
                : AppColors.textTertiary,
          ),
        ),

        // Confirm before reset toggle
        SwitchListTile(
          title: const Text('Confirm Before Reset'),
          subtitle: const Text('Ask before resetting items'),
          value: settings.confirmBeforeReset,
          onChanged: (value) {
            settings.confirmBeforeReset = value;
            _hapticFeedback(settings);
          },
          secondary: Icon(
            Icons.warning_outlined,
            color: settings.confirmBeforeReset
                ? AppColors.primary
                : AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  /// Build data-related settings
  Widget _buildDataSettings(
    BuildContext context,
    SettingsProvider settings,
  ) {
    final itemsProvider = context.read<TrackedItemsProvider>();

    return Column(
      children: [
        // Clear all data
        ListTile(
          leading: Icon(Icons.delete_forever, color: AppColors.error),
          title: Text(
            'Delete All Items',
            style: TextStyle(color: AppColors.error),
          ),
          subtitle: Text(
            '${itemsProvider.itemCount} items',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          onTap: () => _showDeleteAllConfirmation(context, itemsProvider),
        ),

        // Reset settings
        ListTile(
          leading: Icon(Icons.restore, color: AppColors.statusWarning),
          title: const Text('Reset Settings'),
          subtitle: const Text('Restore default settings'),
          onTap: () => _showResetSettingsConfirmation(context, settings),
        ),
      ],
    );
  }

  /// Build about section
  Widget _buildAboutSettings(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.info_outline, color: AppColors.primary),
          title: const Text('About Days Since'),
          subtitle: const Text('Version 1.0.0'),
          onTap: () => _showAboutDialog(context),
        ),
      ],
    );
  }

  /// Show notification time picker
  void _showNotificationTimePicker(
    BuildContext context,
    SettingsProvider settings,
  ) {
    final hours = List.generate(24, (i) => i);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            const SizedBox(height: 16),
            Text(
              'Notification Time',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'When should we remind you?',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: hours.length,
                itemBuilder: (context, index) {
                  final hour = hours[index];
                  final isSelected = hour == settings.notificationTimeHour;
                  String timeString;
                  if (hour == 0) {
                    timeString = '12:00 AM';
                  } else if (hour < 12) {
                    timeString = '$hour:00 AM';
                  } else if (hour == 12) {
                    timeString = '12:00 PM';
                  } else {
                    timeString = '${hour - 12}:00 PM';
                  }

                  return ListTile(
                    title: Text(
                      timeString,
                      style: TextStyle(
                        color: isSelected ? AppColors.primary : null,
                        fontWeight: isSelected ? FontWeight.bold : null,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: AppColors.primary)
                        : null,
                    onTap: () {
                      settings.notificationTimeHour = hour;
                      _hapticFeedback(settings);
                      Navigator.pop(context);
                      _rescheduleAllNotifications();
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Show sort order picker
  void _showSortOrderPicker(
    BuildContext context,
    SettingsProvider settings,
  ) {
    final options = [
      ('status', 'Status (Overdue first)', Icons.priority_high),
      ('days', 'Days since reset', Icons.calendar_today),
      ('name', 'Name (A-Z)', Icons.sort_by_alpha),
      ('recent', 'Recently reset', Icons.history),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            const SizedBox(height: 16),
            Text(
              'Sort Order',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...options.map((option) {
              final isSelected = option.$1 == settings.sortOrder;
              return ListTile(
                leading: Icon(
                  option.$3,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
                title: Text(
                  option.$2,
                  style: TextStyle(
                    color: isSelected ? AppColors.primary : null,
                    fontWeight: isSelected ? FontWeight.bold : null,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  settings.sortOrder = option.$1;
                  _hapticFeedback(settings);
                  Navigator.pop(context);
                },
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Show permission denied dialog
  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'Notification permission is required to send reminders. '
          'Please enable notifications in your device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show delete all confirmation dialog
  void _showDeleteAllConfirmation(
    BuildContext context,
    TrackedItemsProvider provider,
  ) {
    if (provider.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No items to delete')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Items?'),
        content: Text(
          'This will permanently delete all ${provider.itemCount} tracked items. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // Delete all items
              for (final item in provider.items.toList()) {
                await provider.deleteItem(item.id);
              }
              // Cancel all notifications
              await NotificationService().cancelAllNotifications();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All items deleted')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  /// Show reset settings confirmation dialog
  void _showResetSettingsConfirmation(
    BuildContext context,
    SettingsProvider settings,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings?'),
        content: const Text(
          'This will reset all settings to their default values. '
          'Your tracked items will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await settings.resetToDefaults();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings reset to defaults')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.statusWarning),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  /// Show about dialog
  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Days Since',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.timer,
          color: Colors.white,
          size: 28,
        ),
      ),
      children: [
        const Text(
          'A minimal tracker app to monitor days since recurring events.',
        ),
        const SizedBox(height: 16),
        const Text(
          'Track haircuts, oil changes, filter replacements, and more. '
          'Stay on top of your recurring tasks with visual reminders.',
          style: TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  /// Trigger haptic feedback if enabled
  void _hapticFeedback(SettingsProvider settings) {
    if (settings.hapticFeedbackEnabled) {
      HapticFeedback.lightImpact();
    }
  }

  /// Reschedule all notifications after settings change
  void _rescheduleAllNotifications() {
    final items = context.read<TrackedItemsProvider>().items;
    NotificationService().updateAllNotifications(items);
  }
}
