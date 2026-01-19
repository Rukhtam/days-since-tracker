import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../providers/settings_provider.dart';
import '../providers/tracked_items_provider.dart';
import '../services/haptic_service.dart';
import '../services/notification_service.dart';

/// Settings screen allowing users to configure app behavior.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with WidgetsBindingObserver {
  // Use nullable bool to track permission state:
  // - null = not yet checked (loading)
  // - true = permission granted
  // - false = permission denied
  // This prevents UI flicker during async permission check
  bool? _notificationsPermissionGranted;
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkNotificationPermissions();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _appVersion = packageInfo.version;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-check permissions when app resumes (user may have changed settings)
    if (state == AppLifecycleState.resumed) {
      _checkNotificationPermissionsAndUpdate();
    }
  }

  Future<void> _checkNotificationPermissions() async {
    final enabled = await NotificationService().areNotificationsEnabled();
    if (mounted) {
      setState(() {
        _notificationsPermissionGranted = enabled;
      });
    }
  }

  /// Check permissions and auto-enable notifications if permission was just granted
  Future<void> _checkNotificationPermissionsAndUpdate() async {
    final enabled = await NotificationService().areNotificationsEnabled();
    final wasGranted = _notificationsPermissionGranted == true;

    if (mounted) {
      setState(() {
        _notificationsPermissionGranted = enabled;
      });

      // If permission was just granted (wasn't before, is now)
      // and user has notifications enabled in app settings,
      // reschedule all notifications
      if (enabled && !wasGranted) {
        final settings = context.read<SettingsProvider>();
        if (settings.notificationsEnabled) {
          _rescheduleAllNotifications();
        }
      }
    }
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

  /// Get the subtitle text for the notification toggle based on current state.
  ///
  /// Logic:
  /// - Toggle OFF: "Enable to receive reminders" (neutral)
  /// - Toggle ON + permission loading: "Get reminded when items are due" (neutral)
  /// - Toggle ON + permission granted: "Get reminded when items are due" (neutral)
  /// - Toggle ON + permission denied: "Permission required to send notifications" (warning)
  String _getNotificationSubtitle({
    required bool toggleEnabled,
    required bool hasPermission,
    required bool permissionChecked,
  }) {
    if (!toggleEnabled) {
      // Toggle is OFF - show neutral message encouraging to enable
      return 'Enable to receive reminders';
    }

    // Toggle is ON
    if (!permissionChecked) {
      // Still loading permission status - show neutral message
      return 'Get reminded when items are due';
    }

    if (hasPermission) {
      // Permission granted - show confirmation message
      return 'Get reminded when items are due';
    }

    // Permission denied - show warning
    return 'Permission required to send notifications';
  }

  /// Get the subtitle color for the notification toggle based on current state.
  ///
  /// Only shows warning color when toggle is ON AND permission is explicitly denied.
  Color? _getNotificationSubtitleColor({
    required bool toggleEnabled,
    required bool hasPermission,
    required bool permissionChecked,
    required Color warningColor,
    required Color? normalColor,
  }) {
    // Only show warning color if:
    // 1. Toggle is ON (user wants notifications)
    // 2. Permission check has completed (not loading)
    // 3. Permission was denied
    if (toggleEnabled && permissionChecked && !hasPermission) {
      return warningColor;
    }
    return normalColor;
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

    // Determine effective permission state:
    // - null (loading): treat as true to avoid flicker
    // - true: granted
    // - false: denied
    final hasPermission = _notificationsPermissionGranted ?? true;
    final permissionChecked = _notificationsPermissionGranted != null;

    return Column(
      children: [
        // Master notification toggle
        // IMPORTANT: The toggle value should ONLY reflect the saved setting,
        // not the permission status. Permission status affects the subtitle
        // and action handling, but not the displayed toggle state.
        // This prevents the race condition where async permission check
        // causes the toggle to briefly show the wrong state.
        SwitchListTile(
          title: const Text('Enable Notifications'),
          subtitle: Text(
            // Determine subtitle text based on toggle state and permission
            _getNotificationSubtitle(
              toggleEnabled: settings.notificationsEnabled,
              hasPermission: hasPermission,
              permissionChecked: permissionChecked,
            ),
            style: TextStyle(
              color: _getNotificationSubtitleColor(
                toggleEnabled: settings.notificationsEnabled,
                hasPermission: hasPermission,
                permissionChecked: permissionChecked,
                warningColor: warningColor,
                normalColor: theme.textTheme.bodyMedium?.color,
              ),
            ),
          ),
          value: settings.notificationsEnabled,
          onChanged: (value) async {
            if (value) {
              // User is trying to enable notifications
              // First, re-check current permission status
              final currentlyEnabled = await NotificationService().areNotificationsEnabled();
              debugPrint('Settings: Current permission status = $currentlyEnabled');
              
              if (currentlyEnabled) {
                // Permission is already granted in system settings
                setState(() {
                  _notificationsPermissionGranted = true;
                });
                settings.notificationsEnabled = true;
                _rescheduleAllNotifications();
              } else {
                // Permission not granted - use detailed request
                final result = await NotificationService().requestPermissionsWithStatus();
                debugPrint('Settings: Permission request result = $result');
                
                switch (result) {
                  case PermissionRequestResult.granted:
                    setState(() {
                      _notificationsPermissionGranted = true;
                    });
                    settings.notificationsEnabled = true;
                    _rescheduleAllNotifications();
                    break;
                  case PermissionRequestResult.permanentlyDenied:
                    // Must go to settings
                    _showPermissionDeniedDialog();
                    break;
                  case PermissionRequestResult.denied:
                    // Try requesting again via flutter_local_notifications
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
                    break;
                  default:
                    _showPermissionDeniedDialog();
                }
              }
            } else {
              // User is disabling notifications
              settings.notificationsEnabled = false;
              NotificationService().cancelAllNotifications();
            }
            _hapticFeedback(settings);
          },
          secondary: Icon(
            settings.notificationsEnabled
                ? Icons.notifications_active
                : Icons.notifications_off,
            color: settings.notificationsEnabled
                ? (hasPermission
                    ? colorScheme.primary
                    : warningColor) // Show warning color if enabled but no permission
                : theme.iconTheme.color?.withValues(alpha: 0.5),
          ),
        ),

        // Notification time picker
        // Only enable when notifications are ON and permission is granted
        ListTile(
          enabled: settings.notificationsEnabled && hasPermission,
          leading: Icon(
            Icons.access_time,
            color: settings.notificationsEnabled && hasPermission
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
              HapticService.mediumImpact();
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
  Widget _buildDataSettings(BuildContext context, SettingsProvider settings) {
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
          subtitle: Text(
            _appVersion.isNotEmpty ? 'Version $_appVersion' : 'Version ...',
          ),
          onTap: () => _showAboutDialog(context),
        ),
        ListTile(
          leading: Icon(Icons.bug_report_outlined, color: theme.colorScheme.primary),
          title: const Text('Share Diagnostics'),
          subtitle: const Text('Send debug info for troubleshooting'),
          onTap: () => _shareDiagnostics(context),
        ),
      ],
    );
  }

  /// Show theme mode picker
  void _showThemeModePicker(BuildContext context, SettingsProvider settings) {
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
            Text('Theme', style: theme.textTheme.titleLarge),
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
  ) async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: settings.notificationTime,
      initialEntryMode: TimePickerEntryMode.dial,
      helpText: 'Select notification time',
      confirmText: 'Set',
      cancelText: 'Cancel',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              dayPeriodShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime != null) {
      settings.notificationTime = selectedTime;
      _hapticFeedback(settings);
      _rescheduleAllNotifications();
    }
  }

  /// Show sort order picker
  void _showSortOrderPicker(BuildContext context, SettingsProvider settings) {
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
            Text('Sort Order', style: theme.textTheme.titleLarge),
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
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // Open system settings
              await NotificationService().openNotificationSettings();
            },
            child: const Text('Open Settings'),
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
      final messenger = ScaffoldMessenger.of(context);
      messenger.clearSnackBars();
      messenger.showSnackBar(const SnackBar(content: Text('No items to delete')));
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
                final messenger = ScaffoldMessenger.of(context);
                messenger.clearSnackBars();
                messenger.showSnackBar(
                  const SnackBar(content: Text('All items deleted')),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFF44336),
            ),
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
                final messenger = ScaffoldMessenger.of(context);
                messenger.clearSnackBars();
                messenger.showSnackBar(
                  const SnackBar(content: Text('Settings reset to defaults')),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFF9800),
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  /// Share diagnostics information for troubleshooting
  Future<void> _shareDiagnostics(BuildContext context) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Gather all diagnostic information
      final notificationDiagnostics =
          await NotificationService().getNotificationDiagnostics();
      final packageInfo = await PackageInfo.fromPlatform();
      final settings = context.read<SettingsProvider>();
      final itemsProvider = context.read<TrackedItemsProvider>();

      // Get device info
      String deviceInfo = '';
      final deviceInfoPlugin = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        deviceInfo = '''
📱 Device: ${androidInfo.manufacturer} ${androidInfo.model}
🤖 Android: ${androidInfo.version.release} (SDK ${androidInfo.version.sdkInt})
🔧 Brand: ${androidInfo.brand}
🏭 Product: ${androidInfo.product}''';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        deviceInfo = '''
📱 Device: ${iosInfo.name}
 iOS: ${iosInfo.systemVersion}
🔧 Model: ${iosInfo.model}
🏭 Identifier: ${iosInfo.utsname.machine}''';
      }

      // Get pending notifications
      final pendingNotifications =
          await NotificationService().getPendingNotifications();
      final pendingList = pendingNotifications
          .take(5)
          .map((n) => '  • ID: ${n.id}, Title: ${n.title}')
          .join('\n');

      // Build item details with calculated notification dates
      final itemDetailsList = itemsProvider.items.take(10).map((item) {
        final daysUntil90Pct = (item.recommendedIntervalDays * 0.9).floor() - item.daysSinceReset;
        String notifyStatus;
        if (!item.notificationsEnabled) {
          notifyStatus = 'Disabled';
        } else if (daysUntil90Pct <= 0) {
          notifyStatus = 'NOW (${item.percentageElapsed.toStringAsFixed(0)}% elapsed)';
        } else {
          final notifyDate = DateTime.now().add(Duration(days: daysUntil90Pct));
          notifyStatus = '${notifyDate.year}-${notifyDate.month.toString().padLeft(2, '0')}-${notifyDate.day.toString().padLeft(2, '0')} at ${settings.notificationTimeHour.toString().padLeft(2, '0')}:${settings.notificationTimeMinute.toString().padLeft(2, '0')}';
        }
        return '  • ${item.name}: ${item.daysSinceReset}d/${item.recommendedIntervalDays}d (${item.status.name}) → $notifyStatus';
      }).join('\n');

      // Detect aggressive OEM battery optimization issues
      // Based on dontkillmyapp.com rankings
      String oemWarning = '';
      final deviceInfoLower = deviceInfo.toLowerCase();
      final aggressiveOems = {
        'samsung': 'dontkillmyapp.com/samsung',
        'xiaomi': 'dontkillmyapp.com/xiaomi',
        'huawei': 'dontkillmyapp.com/huawei',
        'oneplus': 'dontkillmyapp.com/oneplus',
        'oppo': 'dontkillmyapp.com/oppo',
        'vivo': 'dontkillmyapp.com/vivo',
        'realme': 'dontkillmyapp.com/realme',
        'meizu': 'dontkillmyapp.com/meizu',
        'asus': 'dontkillmyapp.com/asus',
        'lenovo': 'dontkillmyapp.com/lenovo',
        'nokia': 'dontkillmyapp.com/nokia',
        'tecno': 'dontkillmyapp.com/tecno',
        'infinix': 'dontkillmyapp.com/infinix',
      };
      
      for (final entry in aggressiveOems.entries) {
        if (deviceInfoLower.contains(entry.key) && 
            notificationDiagnostics['batteryOptimizationDisabled'] == false) {
          final oemName = entry.key[0].toUpperCase() + entry.key.substring(1);
          oemWarning = '''

⚠️ ${oemName.toUpperCase()} BATTERY ISSUE DETECTED
───────────────────────────────────────
Your $oemName device has battery optimization 
ENABLED for this app. This WILL prevent 
notifications from firing!

FIX: Settings → Apps → Days Since → Battery
     → Set to "Unrestricted"

Also add this app to "Never sleeping apps"
or equivalent for your device.

See: ${entry.value}
''';
          break;
        }
      }

      // Build the report
      final report = '''
═══════════════════════════════════════
  DAYS SINCE - DIAGNOSTIC REPORT
  Generated: ${DateTime.now().toIso8601String()}
═══════════════════════════════════════

📦 APP INFO
───────────────────────────────────────
Version: ${packageInfo.version} (Build ${packageInfo.buildNumber})
Package: ${packageInfo.packageName}

$deviceInfo

⚙️ SETTINGS
───────────────────────────────────────
Theme: ${settings.themeModeDisplayName}
Notifications Enabled: ${settings.notificationsEnabled}
Notification Time: ${settings.notificationTimeHour.toString().padLeft(2, '0')}:${settings.notificationTimeMinute.toString().padLeft(2, '0')}
Sort Order: ${settings.sortOrder}
Haptic Feedback: ${settings.hapticFeedbackEnabled}

📊 DATA
───────────────────────────────────────
Total Items: ${itemsProvider.items.length}
First Launch Complete: ${!settings.isFirstLaunch}

🔔 NOTIFICATION DIAGNOSTICS
───────────────────────────────────────
Initialized: ${notificationDiagnostics['isInitialized']}
Permission Granted: ${notificationDiagnostics['notificationPermission']}
Exact Alarm Permission: ${notificationDiagnostics['exactAlarmPermission'] ?? 'N/A'}
Battery Optimization Disabled: ${notificationDiagnostics['batteryOptimizationDisabled'] ?? 'N/A'}
Pending Notifications: ${notificationDiagnostics['pendingNotificationsCount'] ?? 0}
Permission Handler Status: ${notificationDiagnostics['permissionHandlerStatus'] ?? 'N/A'}
FLN Notifications Enabled: ${notificationDiagnostics['flnNotificationsEnabled'] ?? 'N/A'}
$oemWarning
📋 TRACKED ITEMS (First 10)
───────────────────────────────────────
${itemDetailsList.isNotEmpty ? itemDetailsList : '  (none)'}

📋 PENDING NOTIFICATIONS (First 5)
───────────────────────────────────────
${pendingList.isNotEmpty ? pendingList : '  (none)'}

═══════════════════════════════════════
  END OF REPORT
═══════════════════════════════════════
''';

      // Dismiss loading indicator
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Share the report
      await Share.share(
        report,
        subject: 'Days Since - Diagnostic Report',
      );
    } catch (e) {
      // Dismiss loading indicator
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating diagnostics: $e')),
        );
      }
    }
  }

  /// Show about dialog
  void _showAboutDialog(BuildContext context) {
    final theme = Theme.of(context);
    showAboutDialog(
      context: context,
      applicationName: 'Days Since',
      applicationVersion: _appVersion.isNotEmpty ? _appVersion : '...',
      applicationIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.timer, color: Colors.white, size: 28),
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
      HapticService.lightImpact();
    }
  }

  /// Reschedule all notifications after settings change
  void _rescheduleAllNotifications() {
    final items = context.read<TrackedItemsProvider>().items;
    final settings = context.read<SettingsProvider>();
    NotificationService().updateAllNotifications(
      items,
      notificationHour: settings.notificationTimeHour,
      notificationMinute: settings.notificationTimeMinute,
    );
  }
}
