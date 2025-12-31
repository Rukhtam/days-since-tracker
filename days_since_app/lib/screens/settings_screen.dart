import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

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
              // Appearance Section
              _buildSectionHeader(context, 'Appearance'),
              _buildAppearanceSettings(context, settings),
              const SizedBox(height: 16),

              // Notifications Section
              _buildSectionHeader(context, 'Notifications'),
              _buildNotificationSettings(context, settings),
              const SizedBox(height: 16),

              // Display Section
              _buildSectionHeader(context, 'Display'),
              _buildDisplaySettings(context, settings),
              const SizedBox(height: 16),

              // Behavior Section
              _buildSectionHeader(context, 'Behavior'),
              _buildBehaviorSettings(context, settings),
              const SizedBox(height: 16),

              // Data Section
              _buildSectionHeader(context, 'Data'),
              _buildDataSettings(context, settings),
              const SizedBox(height: 16),

              // About Section
              _buildSectionHeader(context, 'About'),
              _buildAboutSettings(context),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  /// Build section header with title
  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
          fontSize: 14,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// Build appearance-related settings (theme mode)
  Widget _buildAppearanceSettings(
    BuildContext context,
    SettingsProvider settings,
  ) {
    final theme = Theme.of(context);
    return Column(
      children: [
        // Theme mode selector
        ListTile(
          leading: Icon(
            _getThemeModeIcon(settings.themeMode),
            color: theme.colorScheme.primary,
          ),
          title: const Text('Theme'),
          subtitle: Text(settings.themeModeDisplayName),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showThemeModePicker(context, settings),
        ),
      ],
    );
  }

  /// Get icon for current theme mode
  IconData _getThemeModeIcon(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return Icons.light_mode;
      case AppThemeMode.dark:
        return Icons.dark_mode;
      case AppThemeMode.system:
        return Icons.brightness_auto;
    }
  }

  /// Build notification-related settings
  Widget _buildNotificationSettings(
    BuildContext context,
    SettingsProvider settings,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // Use orange/amber for warning color that works in both themes
    const warningColor = Color(0xFFFF9800);

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
                  ? theme.textTheme.bodyMedium?.color
                  : warningColor,
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
                ? colorScheme.primary
                : theme.iconTheme.color?.withValues(alpha: 0.5),
          ),
        ),

        // Notification time picker
        ListTile(
          enabled: settings.notificationsEnabled && _notificationsPermissionGranted,
          leading: Icon(
            Icons.access_time,
            color: settings.notificationsEnabled && _notificationsPermissionGranted
                ? colorScheme.primary
                : theme.iconTheme.color?.withValues(alpha: 0.5),
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
    final theme = Theme.of(context);
    return Column(
      children: [
        // Sort order
        ListTile(
          leading: Icon(Icons.sort, color: theme.colorScheme.primary),
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
    final theme = Theme.of(context);
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
                ? theme.colorScheme.primary
                : theme.iconTheme.color?.withValues(alpha: 0.5),
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
                ? theme.colorScheme.primary
                : theme.iconTheme.color?.withValues(alpha: 0.5),
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
    final theme = Theme.of(context);
    final itemsProvider = context.read<TrackedItemsProvider>();
    // Use consistent colors for error and warning across themes
    const errorColor = Color(0xFFF44336);
    const warningColor = Color(0xFFFF9800);

    return Column(
      children: [
        // Clear all data
        ListTile(
          leading: const Icon(Icons.delete_forever, color: errorColor),
          title: const Text(
            'Delete All Items',
            style: TextStyle(color: errorColor),
          ),
          subtitle: Text(
            '${itemsProvider.itemCount} items',
            style: TextStyle(color: theme.textTheme.bodyMedium?.color),
          ),
          onTap: () => _showDeleteAllConfirmation(context, itemsProvider),
        ),

        // Reset settings
        ListTile(
          leading: const Icon(Icons.restore, color: warningColor),
          title: const Text('Reset Settings'),
          subtitle: const Text('Restore default settings'),
          onTap: () => _showResetSettingsConfirmation(context, settings),
        ),
      ],
    );
  }

  /// Build about section
  Widget _buildAboutSettings(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.info_outline, color: theme.colorScheme.primary),
          title: const Text('About Days Since'),
          subtitle: const Text('Version 1.0.0'),
          onTap: () => _showAboutDialog(context),
        ),
      ],
    );
  }

  /// Show theme mode picker
  void _showThemeModePicker(
    BuildContext context,
    SettingsProvider settings,
  ) {
    final theme = Theme.of(context);
    final options = [
      (AppThemeMode.light, 'Light', Icons.light_mode),
      (AppThemeMode.dark, 'Dark', Icons.dark_mode),
      (AppThemeMode.system, 'System', Icons.brightness_auto),
    ];

    showModalBottomSheet(
      context: context,
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
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Theme',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Choose your preferred appearance',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ...options.map((option) {
              final isSelected = option.$1 == settings.themeMode;
              return ListTile(
                leading: Icon(
                  option.$3,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.iconTheme.color,
                ),
                title: Text(
                  option.$2,
                  style: TextStyle(
                    color: isSelected ? theme.colorScheme.primary : null,
                    fontWeight: isSelected ? FontWeight.bold : null,
                  ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check, color: theme.colorScheme.primary)
                    : null,
                onTap: () {
                  settings.themeMode = option.$1;
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

  /// Show notification time picker
  void _showNotificationTimePicker(
    BuildContext context,
    SettingsProvider settings,
  ) {
    final theme = Theme.of(context);
    final hours = List.generate(24, (i) => i);

    showModalBottomSheet(
      context: context,
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
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Notification Time',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'When should we remind you?',
              style: theme.textTheme.bodyMedium,
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
                        color: isSelected ? theme.colorScheme.primary : null,
                        fontWeight: isSelected ? FontWeight.bold : null,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check, color: theme.colorScheme.primary)
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
    final theme = Theme.of(context);
    final options = [
      ('status', 'Status (Overdue first)', Icons.priority_high),
      ('days', 'Days since reset', Icons.calendar_today),
      ('name', 'Name (A-Z)', Icons.sort_by_alpha),
      ('recent', 'Recently reset', Icons.history),
    ];

    showModalBottomSheet(
      context: context,
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
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Sort Order',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...options.map((option) {
              final isSelected = option.$1 == settings.sortOrder;
              return ListTile(
                leading: Icon(
                  option.$3,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.iconTheme.color,
                ),
                title: Text(
                  option.$2,
                  style: TextStyle(
                    color: isSelected ? theme.colorScheme.primary : null,
                    fontWeight: isSelected ? FontWeight.bold : null,
                  ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check, color: theme.colorScheme.primary)
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
            style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFF44336)),
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
            style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFFF9800)),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  /// Show about dialog
  void _showAboutDialog(BuildContext context) {
    final theme = Theme.of(context);
    showAboutDialog(
      context: context,
      applicationName: 'Days Since',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
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
