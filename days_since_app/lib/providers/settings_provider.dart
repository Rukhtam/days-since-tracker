import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Enum representing the available theme modes.
enum AppThemeMode {
  light,
  dark,
  system,
}

/// Provider that manages app-wide settings.
/// Settings are persisted using Hive for data persistence across app restarts.
class SettingsProvider extends ChangeNotifier {
  static const String _boxName = 'settings';

  // Setting keys
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyNotificationTime = 'notification_time';
  static const String _keyNotificationMinute = 'notification_minute';
  static const String _keySortOrder = 'sort_order';
  static const String _keyShowCompletedFirst = 'show_completed_first';
  static const String _keyHapticFeedback = 'haptic_feedback';
  static const String _keyConfirmReset = 'confirm_reset';
  static const String _keyFirstLaunch = 'first_launch';
  static const String _keyOnboardingComplete = 'onboarding_complete';
  static const String _keyThemeMode = 'theme_mode';

  Box? _box;
  bool _isInitialized = false;

  /// Check if the provider is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize the settings provider.
  /// Must be called before accessing any settings.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _box = await Hive.openBox(_boxName);
      _isInitialized = true;
      notifyListeners();
      debugPrint('SettingsProvider: Initialized successfully');
    } catch (e) {
      debugPrint('SettingsProvider: Failed to initialize - $e');
    }
  }

  // ========== Notification Settings ==========

  /// Whether global notifications are enabled
  bool get notificationsEnabled {
    return _box?.get(_keyNotificationsEnabled, defaultValue: true) ?? true;
  }

  set notificationsEnabled(bool value) {
    _box?.put(_keyNotificationsEnabled, value);
    notifyListeners();
  }

  /// Default notification time (hour of day, 0-23)
  /// Defaults to 9 AM
  int get notificationTimeHour {
    return _box?.get(_keyNotificationTime, defaultValue: 9) ?? 9;
  }

  set notificationTimeHour(int value) {
    if (value >= 0 && value <= 23) {
      _box?.put(_keyNotificationTime, value);
      notifyListeners();
    }
  }

  /// Default notification minute (0-59)
  /// Defaults to 0
  int get notificationTimeMinute {
    return _box?.get(_keyNotificationMinute, defaultValue: 0) ?? 0;
  }

  set notificationTimeMinute(int value) {
    if (value >= 0 && value <= 59) {
      _box?.put(_keyNotificationMinute, value);
      notifyListeners();
    }
  }

  /// Get notification time as TimeOfDay
  TimeOfDay get notificationTime {
    return TimeOfDay(hour: notificationTimeHour, minute: notificationTimeMinute);
  }

  /// Set notification time from TimeOfDay
  set notificationTime(TimeOfDay time) {
    _box?.put(_keyNotificationTime, time.hour);
    _box?.put(_keyNotificationMinute, time.minute);
    notifyListeners();
  }

  /// Get formatted notification time string
  String get notificationTimeFormatted {
    final hour = notificationTimeHour;
    final minute = notificationTimeMinute;
    final minuteStr = minute.toString().padLeft(2, '0');
    if (hour == 0) {
      return '12:$minuteStr AM';
    } else if (hour < 12) {
      return '$hour:$minuteStr AM';
    } else if (hour == 12) {
      return '12:$minuteStr PM';
    } else {
      return '${hour - 12}:$minuteStr PM';
    }
  }

  // ========== Sort Order Settings ==========

  /// Sort order for items: 'status', 'days', 'name', 'recent'
  String get sortOrder {
    return _box?.get(_keySortOrder, defaultValue: 'status') ?? 'status';
  }

  set sortOrder(String value) {
    if (['status', 'days', 'name', 'recent'].contains(value)) {
      _box?.put(_keySortOrder, value);
      notifyListeners();
    }
  }

  /// Get human-readable sort order name
  String get sortOrderDisplayName {
    switch (sortOrder) {
      case 'status':
        return 'Status (Overdue first)';
      case 'days':
        return 'Days since reset';
      case 'name':
        return 'Name (A-Z)';
      case 'recent':
        return 'Recently reset';
      default:
        return 'Status';
    }
  }

  // ========== Theme Settings ==========

  /// Get the current theme mode setting
  AppThemeMode get themeMode {
    // Before box is initialized, return system to avoid flash
    if (_box == null) return AppThemeMode.system;
    final value = _box?.get(_keyThemeMode, defaultValue: 'system') ?? 'system';
    switch (value) {
      case 'light':
        return AppThemeMode.light;
      case 'dark':
        return AppThemeMode.dark;
      case 'system':
      default:
        return AppThemeMode.system;
    }
  }

  set themeMode(AppThemeMode value) {
    String stringValue;
    switch (value) {
      case AppThemeMode.light:
        stringValue = 'light';
        break;
      case AppThemeMode.system:
        stringValue = 'system';
        break;
      case AppThemeMode.dark:
        stringValue = 'dark';
        break;
    }
    _box?.put(_keyThemeMode, stringValue);
    notifyListeners();
  }

  /// Convert AppThemeMode to Flutter ThemeMode
  ThemeMode get flutterThemeMode {
    switch (themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  /// Get display name for theme mode
  String get themeModeDisplayName {
    switch (themeMode) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.system:
        return 'System';
    }
  }

  // ========== UI Preference Settings ==========

  /// Whether to show completed/good items first (inverts status sort)
  bool get showCompletedFirst {
    return _box?.get(_keyShowCompletedFirst, defaultValue: false) ?? false;
  }

  set showCompletedFirst(bool value) {
    _box?.put(_keyShowCompletedFirst, value);
    notifyListeners();
  }

  /// Whether haptic feedback is enabled
  bool get hapticFeedbackEnabled {
    return _box?.get(_keyHapticFeedback, defaultValue: true) ?? true;
  }

  set hapticFeedbackEnabled(bool value) {
    _box?.put(_keyHapticFeedback, value);
    notifyListeners();
  }

  /// Whether to show confirmation dialog before resetting items
  bool get confirmBeforeReset {
    return _box?.get(_keyConfirmReset, defaultValue: false) ?? false;
  }

  set confirmBeforeReset(bool value) {
    _box?.put(_keyConfirmReset, value);
    notifyListeners();
  }

  // ========== App State Settings ==========

  /// Whether this is the first launch of the app
  bool get isFirstLaunch {
    return _box?.get(_keyFirstLaunch, defaultValue: true) ?? true;
  }

  void markFirstLaunchComplete() {
    _box?.put(_keyFirstLaunch, false);
    notifyListeners();
  }

  /// Whether onboarding has been completed
  bool get onboardingComplete {
    return _box?.get(_keyOnboardingComplete, defaultValue: false) ?? false;
  }

  void markOnboardingComplete() {
    _box?.put(_keyOnboardingComplete, true);
    notifyListeners();
  }

  // ========== Utility Methods ==========

  /// Reset all settings to defaults
  Future<void> resetToDefaults() async {
    await _box?.clear();
    notifyListeners();
    debugPrint('SettingsProvider: Reset all settings to defaults');
  }

  /// Export settings as a map (for backup/debugging)
  Map<String, dynamic> exportSettings() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'notificationTimeHour': notificationTimeHour,
      'notificationTimeMinute': notificationTimeMinute,
      'sortOrder': sortOrder,
      'showCompletedFirst': showCompletedFirst,
      'hapticFeedbackEnabled': hapticFeedbackEnabled,
      'confirmBeforeReset': confirmBeforeReset,
      'isFirstLaunch': isFirstLaunch,
      'onboardingComplete': onboardingComplete,
      'themeMode': themeModeDisplayName,
    };
  }

  /// Close the settings box (call when app is disposed)
  Future<void> close() async {
    await _box?.close();
  }
}
