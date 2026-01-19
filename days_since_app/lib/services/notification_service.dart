import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import '../models/tracked_item.dart';

/// Result of a permission request operation
enum PermissionRequestResult {
  granted,
  denied,
  permanentlyDenied,
  notInitialized,
  error,
}

/// Service class that handles all local notification operations.
/// Manages scheduling, canceling, and updating notifications for tracked items.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Notification channel details for Android
  static const String _channelId = 'days_since_reminders';
  static const String _channelName = 'Reminder Notifications';
  static const String _channelDescription =
      'Notifications for tracked item reminders';

  /// Android notification icon - uses the app icon by default
  static const String _androidIcon = '@mipmap/ic_launcher';

  /// Get the notifications plugin instance
  FlutterLocalNotificationsPlugin get plugin => _notifications;

  /// Check if notifications are initialized
  bool get isInitialized => _isInitialized;

  /// Reset initialization state to allow retry after failure
  /// CAUTION: Only use this if initialization failed and you want to retry
  void resetInitialization() {
    _isInitialized = false;
    debugPrint(
      'NotificationService: Initialization state reset, ready for retry',
    );
  }

  /// Initialize the notification service.
  /// Must be called before any other notification operations.
  /// Set [forceReinit] to true to retry after a previous failure.
  Future<bool> initialize({
    void Function(NotificationResponse)? onNotificationTap,
    bool forceReinit = false,
  }) async {
    if (_isInitialized && !forceReinit) return true;

    // Allow retry if forceReinit is true
    if (forceReinit) {
      debugPrint('NotificationService: Force re-initialization requested');
      _isInitialized = false;
    }

    try {
      // Initialize timezone database
      tz_data.initializeTimeZones();

      // Set local timezone with fallback to UTC
      // IMPORTANT: tz.getLocation() can throw if the timezone string doesn't match
      // the database exactly. This would cause _isInitialized to stay false,
      // preventing permission dialogs from ever being shown.
      // See: suggestions.md - "Fatal Timezone Bug (Fix A)"
      try {
        final String timeZoneName = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(timeZoneName));
        debugPrint('NotificationService: Timezone set to $timeZoneName');
      } catch (tzError) {
        debugPrint(
          'NotificationService: Timezone detection failed, falling back to UTC: $tzError',
        );
        tz.setLocalLocation(tz.UTC);
      }

      // Android initialization settings
      const androidSettings = AndroidInitializationSettings(_androidIcon);

      // iOS initialization settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false, // We'll request separately
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      // Combined initialization settings
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Initialize the plugin
      final success = await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse:
            onNotificationTap ?? _onNotificationTap,
        onDidReceiveBackgroundNotificationResponse:
            _onBackgroundNotificationTap,
      );

      _isInitialized = success ?? false;

      if (_isInitialized) {
        debugPrint('NotificationService: Initialized successfully');

        // Create notification channel for Android 8+ with high importance
        if (Platform.isAndroid) {
          await _createNotificationChannel();
        }
      } else {
        debugPrint('NotificationService: Initialization returned false');
      }

      return _isInitialized;
    } catch (e) {
      debugPrint('NotificationService: Failed to initialize - $e');
      return false;
    }
  }

  /// Create notification channel for Android 8+ (API 26+)
  /// This ensures notifications work properly on all Android versions
  Future<void> _createNotificationChannel() async {
    try {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidPlugin != null) {
        const channel = AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDescription,
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
          showBadge: true,
        );

        await androidPlugin.createNotificationChannel(channel);
        debugPrint('NotificationService: Notification channel created');
      }
    } catch (e) {
      debugPrint(
        'NotificationService: Failed to create notification channel - $e',
      );
    }
  }

  /// Request notification permissions from the user.
  /// Returns true if permissions were granted.
  ///
  /// NOTE: This method should work even if initialization failed, as requesting
  /// permission is independent of the notification scheduling system.
  Future<bool> requestPermissions() async {
    // Log a warning if not initialized, but don't block the permission request
    if (!_isInitialized) {
      debugPrint(
        'NotificationService: Warning - requesting permissions before full init (continuing anyway)',
      );
    }

    try {
      if (Platform.isAndroid) {
        // For Android 13+ (API 33+), request POST_NOTIFICATIONS permission
        final androidPlugin = _notifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

        if (androidPlugin != null) {
          final granted = await androidPlugin.requestNotificationsPermission();
          debugPrint(
            'NotificationService: Android permission granted: $granted',
          );
          return granted ?? false;
        }
        return true; // For older Android versions, permissions granted by default
      } else if (Platform.isIOS) {
        final iosPlugin = _notifications
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();

        if (iosPlugin != null) {
          final granted = await iosPlugin.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
          debugPrint('NotificationService: iOS permission granted: $granted');
          return granted ?? false;
        }
        return false;
      }
      return false;
    } catch (e) {
      debugPrint('NotificationService: Failed to request permissions - $e');
      return false;
    }
  }

  /// Check if notifications are permitted using multiple methods for reliability.
  /// Uses both permission_handler and flutter_local_notifications as fallback.
  /// This handles edge cases on Android 14+/16 with One UI 8.
  ///
  /// NOTE: This method does NOT depend on _isInitialized because checking
  /// permissions is independent of the notification scheduling system.
  /// Users should see accurate permission status even if initialization failed.
  Future<bool> areNotificationsEnabled() async {
    // IMPORTANT: Do NOT check _isInitialized here!
    // Permission checking is independent of notification scheduling initialization.
    // The old code returned false when !_isInitialized, causing the UI to show
    // "Permission required" even when the user had granted permission.
    // See: Bug report - "Permission required shown even when toggle is enabled"

    try {
      // Method 1: Use permission_handler (preferred)
      final permissionStatus = await Permission.notification.status;
      debugPrint(
        'NotificationService: permission_handler status = $permissionStatus',
      );

      // Method 2: Use flutter_local_notifications as fallback/verification
      bool? flnEnabled;
      if (Platform.isAndroid) {
        // Try to get the android plugin - this may work even if full init failed
        try {
          final androidPlugin = _notifications
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();
          if (androidPlugin != null) {
            flnEnabled = await androidPlugin.areNotificationsEnabled();
          }
        } catch (pluginError) {
          debugPrint(
            'NotificationService: Android plugin check failed - $pluginError',
          );
          // Continue with permission_handler result only
        }
      }
      debugPrint(
        'NotificationService: flutter_local_notifications enabled = $flnEnabled',
      );

      // If either method says granted, consider it granted
      // This handles edge cases where one method fails on specific devices
      final isGranted = permissionStatus.isGranted || (flnEnabled == true);
      debugPrint('NotificationService: Final permission result = $isGranted');

      return isGranted;
    } catch (e) {
      debugPrint('NotificationService: Failed to check permissions - $e');
      // Last resort fallback: try flutter_local_notifications only
      try {
        if (Platform.isAndroid) {
          final androidPlugin = _notifications
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();
          final enabled = await androidPlugin?.areNotificationsEnabled();
          debugPrint('NotificationService: Fallback check = $enabled');
          return enabled ?? false;
        }
      } catch (_) {}
      return false;
    }
  }

  /// Check if notification permission is permanently denied.
  /// If true, user must go to system settings to enable.
  Future<bool> isPermissionPermanentlyDenied() async {
    try {
      final status = await Permission.notification.status;
      debugPrint(
        'NotificationService: Checking permanently denied = ${status.isPermanentlyDenied}',
      );
      return status.isPermanentlyDenied;
    } catch (e) {
      debugPrint('NotificationService: Error checking permanently denied - $e');
      return false;
    }
  }

  /// Request permission and return detailed status for better handling.
  /// On Android 13+ (API 33+), this will show the system permission dialog.
  /// On older Android versions, permissions are granted by default at install time.
  ///
  /// [forceShowDialog] - If true, always attempt to show the dialog on Android 13+,
  /// even if permission_handler reports "granted" (which can be unreliable on first launch).
  Future<PermissionRequestResult> requestPermissionsWithStatus({
    bool forceShowDialog = false,
  }) async {
    // NOTE: We intentionally do NOT block on _isInitialized here.
    // The permission dialog can (and should) be shown even if notification
    // scheduling failed to initialize (e.g., due to timezone issues).
    // Only scheduling operations need _isInitialized to be true.
    // See: suggestions.md - "Decouple Permissions from _isInitialized (Fix B)"
    if (!_isInitialized) {
      debugPrint(
        'NotificationService: Warning - Requesting permissions before full init (this is OK)',
      );
      // Continue anyway - permission dialog can still be shown
    }

    try {
      // Check Android version - permission dialog only needed on Android 13+ (API 33+)
      if (Platform.isAndroid) {
        // Try to get the SDK version to determine if we need the permission dialog
        final androidPlugin = _notifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

        // First, check current permission status
        final currentStatus = await Permission.notification.status;
        debugPrint(
          'NotificationService: Current permission status = $currentStatus',
        );

        // On Android 12 and below, POST_NOTIFICATIONS permission doesn't exist
        // The permission_handler may return "granted" by default
        // We still try to request to ensure the system dialog appears on Android 13+

        if (currentStatus.isPermanentlyDenied) {
          debugPrint(
            'NotificationService: Permission permanently denied, user must enable in settings',
          );
          return PermissionRequestResult.permanentlyDenied;
        }

        // IMPORTANT: On fresh install, we should ALWAYS try to request permission
        // The "granted" status may be incorrect on Android 13+ before the dialog is shown
        // The forceShowDialog flag allows us to bypass the early return
        if (currentStatus.isGranted && !forceShowDialog) {
          debugPrint('NotificationService: Permission already granted');
          return PermissionRequestResult.granted;
        }

        // Request permission - this should show the system dialog on Android 13+
        debugPrint(
          'NotificationService: Requesting notification permission...',
        );

        // Use flutter_local_notifications plugin method for Android
        // This is more reliable than permission_handler on some devices
        if (androidPlugin != null) {
          final granted = await androidPlugin.requestNotificationsPermission();
          debugPrint('NotificationService: FLN permission result = $granted');

          if (granted == true) {
            return PermissionRequestResult.granted;
          }

          // Double-check with permission_handler
          final postRequestStatus = await Permission.notification.status;
          debugPrint(
            'NotificationService: Post-request status = $postRequestStatus',
          );

          if (postRequestStatus.isGranted) {
            return PermissionRequestResult.granted;
          } else if (postRequestStatus.isPermanentlyDenied) {
            return PermissionRequestResult.permanentlyDenied;
          } else {
            return PermissionRequestResult.denied;
          }
        }

        // NOTE: Removed fallback to Permission.notification.request()
        // Using both permission_handler and flutter_local_notifications simultaneously
        // can cause the Android system to ignore/cancel permission dialogs
        // See: suggestions.md - "Dual Permission Conflict"
        debugPrint(
          'NotificationService: Android plugin not available, assuming older device',
        );
        return PermissionRequestResult
            .granted; // Older Android versions don't need permission
      } else if (Platform.isIOS) {
        // iOS permission request
        final currentStatus = await Permission.notification.status;
        debugPrint('NotificationService: iOS current status = $currentStatus');

        if (currentStatus.isGranted) {
          return PermissionRequestResult.granted;
        }

        if (currentStatus.isPermanentlyDenied) {
          return PermissionRequestResult.permanentlyDenied;
        }

        final result = await Permission.notification.request();
        debugPrint('NotificationService: iOS permission result = $result');

        if (result.isGranted) {
          return PermissionRequestResult.granted;
        } else if (result.isPermanentlyDenied) {
          return PermissionRequestResult.permanentlyDenied;
        } else {
          return PermissionRequestResult.denied;
        }
      }

      return PermissionRequestResult.granted; // Default for other platforms
    } catch (e) {
      debugPrint('NotificationService: Error requesting permission - $e');
      return PermissionRequestResult.error;
    }
  }

  /// Open app settings so user can enable notification permission.
  Future<bool> openNotificationSettings() async {
    return await openAppSettings();
  }

  /// Check if exact alarms are permitted (Android 12+ / API 31+)
  /// Required for scheduled notifications to work reliably
  Future<bool> canScheduleExactAlarms() async {
    if (!Platform.isAndroid) return true;

    try {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidPlugin != null) {
        final canSchedule = await androidPlugin.canScheduleExactNotifications();
        debugPrint(
          'NotificationService: Can schedule exact alarms = $canSchedule',
        );
        return canSchedule ?? true;
      }
      return true;
    } catch (e) {
      debugPrint(
        'NotificationService: Error checking exact alarm permission - $e',
      );
      return true; // Assume allowed on older devices
    }
  }

  /// Request exact alarm permission (Android 12+ / API 31+)
  /// Opens system settings if needed
  Future<bool> requestExactAlarmPermission() async {
    if (!Platform.isAndroid) return true;

    try {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidPlugin != null) {
        await androidPlugin.requestExactAlarmsPermission();
        // Check if granted after request
        return await canScheduleExactAlarms();
      }
      return true;
    } catch (e) {
      debugPrint(
        'NotificationService: Error requesting exact alarm permission - $e',
      );
      return false;
    }
  }

  /// Check if battery optimization is disabled for this app
  /// Important for scheduled notifications on OPPO, Xiaomi, Samsung, etc.
  Future<bool> isBatteryOptimizationDisabled() async {
    if (!Platform.isAndroid) return true;

    try {
      final status = await Permission.ignoreBatteryOptimizations.status;
      debugPrint('NotificationService: Battery optimization status = $status');
      return status.isGranted;
    } catch (e) {
      debugPrint(
        'NotificationService: Error checking battery optimization - $e',
      );
      return false;
    }
  }

  /// Request to disable battery optimization
  /// This helps ensure notifications work on aggressive OEM skins
  Future<bool> requestDisableBatteryOptimization() async {
    if (!Platform.isAndroid) return true;

    try {
      final status = await Permission.ignoreBatteryOptimizations.request();
      debugPrint(
        'NotificationService: Battery optimization request result = $status',
      );
      return status.isGranted;
    } catch (e) {
      debugPrint(
        'NotificationService: Error requesting battery optimization disable - $e',
      );
      return false;
    }
  }

  /// Get comprehensive notification status for diagnostics
  /// Useful for troubleshooting notification issues on different devices
  Future<Map<String, dynamic>> getNotificationDiagnostics() async {
    final diagnostics = <String, dynamic>{};

    try {
      diagnostics['isInitialized'] = _isInitialized;
      diagnostics['notificationPermission'] = await areNotificationsEnabled();

      if (Platform.isAndroid) {
        diagnostics['exactAlarmPermission'] = await canScheduleExactAlarms();
        diagnostics['batteryOptimizationDisabled'] =
            await isBatteryOptimizationDisabled();

        // Get pending notifications count
        final pending = await getPendingNotifications();
        diagnostics['pendingNotificationsCount'] = pending.length;

        // Check permission_handler status
        final permStatus = await Permission.notification.status;
        diagnostics['permissionHandlerStatus'] = permStatus.toString();

        // Check flutter_local_notifications status
        final androidPlugin = _notifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        if (androidPlugin != null) {
          diagnostics['flnNotificationsEnabled'] = await androidPlugin
              .areNotificationsEnabled();
        }
      }

      debugPrint('NotificationService: Diagnostics = $diagnostics');
    } catch (e) {
      diagnostics['error'] = e.toString();
      debugPrint('NotificationService: Diagnostics error - $e');
    }

    return diagnostics;
  }

  /// Schedule a notification for a tracked item when it reaches 90% of interval.
  /// Also schedules a "smart reminder" 1 day before the interval expires.
  /// The notification is scheduled at the specified hour and minute on the target date.
  /// [notificationHour] should be 0-23 (defaults to 9 for 9:00 AM)
  /// [notificationMinute] should be 0-59 (defaults to 0)
  Future<bool> scheduleItemNotification(
    TrackedItem item, {
    int notificationHour = 9,
    int notificationMinute = 0,
  }) async {
    if (!_isInitialized) {
      debugPrint('NotificationService: Cannot schedule - not initialized');
      return false;
    }

    if (!item.notificationsEnabled) {
      // Cancel any existing notifications for this item
      await cancelItemNotification(item.id);
      await _cancelSmartReminder(item.id);
      return true;
    }

    try {
      // Schedule the main 90% notification
      final mainResult = await _scheduleMainNotification(
        item,
        notificationHour: notificationHour,
        notificationMinute: notificationMinute,
      );

      // Schedule the smart reminder (1 day before due)
      await _scheduleSmartReminder(
        item,
        notificationHour: notificationHour,
        notificationMinute: notificationMinute,
      );

      return mainResult;
    } catch (e, stackTrace) {
      debugPrint(
        'NotificationService: Failed to schedule notifications for "${item.name}" - $e',
      );
      debugPrint('NotificationService: Stack trace - $stackTrace');
      return false;
    }
  }

  /// Schedule the main notification at 90% of interval
  Future<bool> _scheduleMainNotification(
    TrackedItem item, {
    required int notificationHour,
    required int notificationMinute,
  }) async {
    debugPrint(
      'NotificationService: _scheduleMainNotification for "${item.name}" '
      '(interval: ${item.recommendedIntervalDays}, daysSince: ${item.daysSinceReset}, '
      'percentElapsed: ${item.percentageElapsed.toStringAsFixed(1)}%)',
    );

    try {
      // Calculate when to send the notification (at 90% of interval)
      final notificationDate = _calculateNotificationDate(
        item,
        notificationHour: notificationHour,
        notificationMinute: notificationMinute,
      );

      debugPrint(
        'NotificationService: Calculated notificationDate = $notificationDate',
      );

      if (notificationDate == null) {
        // If already at 90% or more, show notification immediately
        // This handles both warning (90-100%) and overdue (>100%) states
        debugPrint(
          'NotificationService: notificationDate is null, checking percentageElapsed >= 90: ${item.percentageElapsed >= 90}',
        );
        if (item.percentageElapsed >= 90) {
          // Show notification now if in the warning or overdue zone
          debugPrint('NotificationService: Triggering immediate notification!');
          return await _showImmediateNotification(item);
        }
        return true;
      }

      // Check if we can schedule exact alarms (Android 12+ requires permission)
      // If not, fall back to inexact scheduling which is more reliable
      final canUseExact = await canScheduleExactAlarms();
      final scheduleMode = canUseExact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle;

      if (!canUseExact) {
        debugPrint(
          'NotificationService: Exact alarms not permitted, using inexact mode for "${item.name}"',
        );
      }

      // Create notification details
      final androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: _androidIcon,
        styleInformation: BigTextStyleInformation(
          _getNotificationBody(item),
          contentTitle: _getNotificationTitle(item),
        ),
        actions: [
          const AndroidNotificationAction(
            'reset_action',
            'Reset Now',
            showsUserInterface: true,
          ),
        ],
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Schedule the notification with appropriate mode
      await _notifications.zonedSchedule(
        _getNotificationId(item.id),
        _getNotificationTitle(item),
        _getNotificationBody(item),
        notificationDate,
        details,
        androidScheduleMode: scheduleMode,
      );

      debugPrint(
        'NotificationService: Scheduled notification for "${item.name}" at $notificationDate (mode: ${canUseExact ? "exact" : "inexact"})',
      );
      return true;
    } catch (e, stackTrace) {
      debugPrint(
        'NotificationService: Failed to schedule notification for "${item.name}" - $e',
      );
      debugPrint('NotificationService: Stack trace - $stackTrace');
      return false;
    }
  }

  /// Cancel a scheduled notification for a tracked item.
  /// Also cancels any smart reminder for this item.
  Future<void> cancelItemNotification(String itemId) async {
    if (!_isInitialized) {
      debugPrint('NotificationService: Cannot cancel - not initialized');
      return;
    }

    try {
      await _notifications.cancel(_getNotificationId(itemId));
      await _cancelSmartReminder(itemId);
      debugPrint(
        'NotificationService: Cancelled all notifications for item $itemId',
      );
    } catch (e) {
      debugPrint(
        'NotificationService: Failed to cancel notification for $itemId - $e',
      );
    }
  }

  /// Cancel all scheduled notifications.
  Future<void> cancelAllNotifications() async {
    if (!_isInitialized) {
      debugPrint('NotificationService: Cannot cancel all - not initialized');
      return;
    }

    try {
      await _notifications.cancelAll();
      debugPrint('NotificationService: Cancelled all notifications');
    } catch (e) {
      debugPrint(
        'NotificationService: Failed to cancel all notifications - $e',
      );
    }
  }

  /// Update notifications for all tracked items.
  /// Call this when app resumes or items change.
  /// [notificationHour] should be 0-23 (defaults to 9 for 9:00 AM)
  /// [notificationMinute] should be 0-59 (defaults to 0)
  Future<void> updateAllNotifications(
    List<TrackedItem> items, {
    int notificationHour = 9,
    int notificationMinute = 0,
  }) async {
    if (!_isInitialized) return;

    for (final item in items) {
      await scheduleItemNotification(
        item,
        notificationHour: notificationHour,
        notificationMinute: notificationMinute,
      );
    }
    debugPrint(
      'NotificationService: Updated notifications for ${items.length} items at $notificationHour:${notificationMinute.toString().padLeft(2, '0')}',
    );
  }

  /// Show an immediate notification for an item that's already due.
  /// Uses a different notification ID suffix to avoid silent replacement.
  Future<bool> _showImmediateNotification(TrackedItem item) async {
    debugPrint(
      'NotificationService: _showImmediateNotification called for "${item.name}" '
      '(daysSince: ${item.daysSinceReset}, percentElapsed: ${item.percentageElapsed.toStringAsFixed(1)}%)',
    );

    try {
      // Use different notification ID for immediate notifications
      // This prevents silent replacement when the same item has a scheduled notification
      final immediateNotificationId = _getNotificationId(item.id) + 1;

      // Cancel any previously scheduled notification for this item
      // to avoid duplicate notifications
      await _notifications.cancel(_getNotificationId(item.id));

      final androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max, // Maximum importance for immediate alerts
        priority: Priority.max, // Maximum priority
        icon: _androidIcon,
        // CRITICAL: Ensure notification always alerts, even if replacing existing
        onlyAlertOnce: false,
        // Show as heads-up notification
        fullScreenIntent: true,
        // Add ticker for accessibility
        ticker: '${item.name} needs attention',
        actions: [
          const AndroidNotificationAction(
            'reset_action',
            'Reset Now',
            showsUserInterface: true,
          ),
        ],
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        // Ensure notification appears even when app is in foreground
        presentBanner: true,
        presentList: true,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        immediateNotificationId,
        _getNotificationTitle(item),
        _getNotificationBody(item),
        details,
        payload: item.id,
      );

      debugPrint(
        'NotificationService: ✅ Showed immediate notification for "${item.name}" (ID: $immediateNotificationId)',
      );
      return true;
    } catch (e) {
      debugPrint(
        'NotificationService: ❌ Failed to show immediate notification - $e',
      );
      return false;
    }
  }

  /// Calculate the date/time when the notification should be sent.
  /// Returns null only if today's scheduled time has already passed.
  /// [notificationHour] should be 0-23 (defaults to 9 for 9:00 AM)
  /// [notificationMinute] should be 0-59 (defaults to 0)
  tz.TZDateTime? _calculateNotificationDate(
    TrackedItem item, {
    int notificationHour = 9,
    int notificationMinute = 0,
  }) {
    // Calculate when 90% of interval is reached
    final daysUntil90Percent =
        (item.recommendedIntervalDays * 0.9).floor() - item.daysSinceReset;

    final now = tz.TZDateTime.now(tz.local);

    // If we're already past 90%, schedule for today's time (if it hasn't passed yet)
    // Otherwise, schedule for the calculated future day
    final daysToAdd = daysUntil90Percent < 0 ? 0 : daysUntil90Percent;

    // Schedule for the user's preferred time on the target day
    final notificationDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day + daysToAdd,
      notificationHour, // User's preferred hour
      notificationMinute, // User's preferred minute
      0,
    );

    // Only return null if today's scheduled time has already passed
    // This is the only case where we should show an immediate notification
    if (notificationDate.isBefore(now)) {
      return null;
    }

    return notificationDate;
  }

  /// Generate a unique integer notification ID from a string item ID.
  /// Uses hash code with absolute value to ensure positive integer.
  int _getNotificationId(String itemId) {
    return itemId.hashCode.abs() % 2147483647; // Max 32-bit signed int
  }

  /// Get the notification title based on item status.
  String _getNotificationTitle(TrackedItem item) {
    if (item.status == ItemStatus.overdue) {
      return '${item.name} is overdue!';
    } else if (item.status == ItemStatus.warning) {
      return '${item.name} reminder';
    } else {
      return '${item.name} coming up';
    }
  }

  /// Get the notification body text.
  String _getNotificationBody(TrackedItem item) {
    final daysSince = item.daysSinceReset;
    final daysUntilDue = item.daysUntilDue;
    final daysSinceLabel = daysSince == 1 ? 'day' : 'days';

    if (daysUntilDue < 0) {
      final overdueCount = -daysUntilDue;
      final overdueLabel = overdueCount == 1 ? 'day' : 'days';
      return 'It has been $daysSince $daysSinceLabel. This is $overdueCount $overdueLabel overdue!';
    } else if (daysUntilDue == 0) {
      return 'It has been $daysSince $daysSinceLabel. Time to take action!';
    } else {
      final dueLabel = daysUntilDue == 1 ? 'day' : 'days';
      return 'It has been $daysSince $daysSinceLabel. Due in $daysUntilDue $dueLabel.';
    }
  }

  // ============================================================
  // SMART REMINDER METHODS
  // Notify user 1 day before the interval expires (100% mark)
  // ============================================================

  /// Generate a unique notification ID for smart reminders
  /// Uses a different hash to avoid conflicts with main notifications
  int _getSmartReminderId(String itemId) {
    return ('smart_$itemId').hashCode.abs() % 2147483647;
  }

  /// Schedule a "smart reminder" notification 1 day before the interval expires.
  /// This gives users a heads-up before items become overdue.
  Future<bool> _scheduleSmartReminder(
    TrackedItem item, {
    required int notificationHour,
    required int notificationMinute,
  }) async {
    try {
      // Only schedule if interval is > 1 day (otherwise 90% notification is enough)
      if (item.recommendedIntervalDays <= 1) {
        return true;
      }

      // Calculate 1 day before the interval expires
      final daysUntilDue = item.daysUntilDue;

      // If already due or less than 1 day away, don't schedule
      if (daysUntilDue <= 1) {
        return true;
      }

      final now = tz.TZDateTime.now(tz.local);
      final smartReminderDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day + daysUntilDue - 1, // 1 day before due
        notificationHour,
        notificationMinute,
        0,
      );

      // Don't schedule if the time has already passed
      if (smartReminderDate.isBefore(now)) {
        return true;
      }

      // Check if we can schedule exact alarms (Android 12+ requires permission)
      final canUseExact = await canScheduleExactAlarms();
      final scheduleMode = canUseExact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle;

      final androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: _androidIcon,
        styleInformation: BigTextStyleInformation(
          '${item.name} is due tomorrow! It has been ${item.daysSinceReset + daysUntilDue - 1} days.',
          contentTitle: '⏰ ${item.name} - Due Tomorrow',
        ),
        actions: [
          const AndroidNotificationAction(
            'reset_action',
            'Reset Now',
            showsUserInterface: true,
          ),
        ],
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.zonedSchedule(
        _getSmartReminderId(item.id),
        '⏰ ${item.name} - Due Tomorrow',
        '${item.name} is due tomorrow! Take action before it becomes overdue.',
        smartReminderDate,
        details,
        androidScheduleMode: scheduleMode,
      );

      debugPrint(
        'NotificationService: Scheduled smart reminder for "${item.name}" at $smartReminderDate (mode: ${canUseExact ? "exact" : "inexact"})',
      );
      return true;
    } catch (e) {
      debugPrint(
        'NotificationService: Failed to schedule smart reminder for "${item.name}" - $e',
      );
      return false;
    }
  }

  /// Cancel a smart reminder notification
  Future<void> _cancelSmartReminder(String itemId) async {
    try {
      await _notifications.cancel(_getSmartReminderId(itemId));
      debugPrint(
        'NotificationService: Cancelled smart reminder for item $itemId',
      );
    } catch (e) {
      debugPrint('NotificationService: Failed to cancel smart reminder - $e');
    }
  }

  /// Default handler for notification taps.
  static void _onNotificationTap(NotificationResponse response) {
    // The payload contains the item ID
    // Navigation to the item will be handled by the app
  }

  /// Handler for background notification taps.
  @pragma('vm:entry-point')
  static void _onBackgroundNotificationTap(NotificationResponse response) {
    // Handle background notification tap
  }

  /// Get pending notification requests (for debugging).
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (!_isInitialized) return [];
    return await _notifications.pendingNotificationRequests();
  }
}
