import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import '../models/tracked_item.dart';

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

  /// Initialize the notification service.
  /// Must be called before any other notification operations.
  Future<bool> initialize({
    void Function(NotificationResponse)? onNotificationTap,
  }) async {
    if (_isInitialized) return true;

    try {
      // Initialize timezone database and set local timezone
      tz_data.initializeTimeZones();
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      debugPrint('NotificationService: Timezone set to $timeZoneName');

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
      } else {
        debugPrint('NotificationService: Initialization returned false');
      }

      return _isInitialized;
    } catch (e) {
      debugPrint('NotificationService: Failed to initialize - $e');
      return false;
    }
  }

  /// Request notification permissions from the user.
  /// Returns true if permissions were granted.
  Future<bool> requestPermissions() async {
    if (!_isInitialized) {
      debugPrint(
        'NotificationService: Not initialized, cannot request permissions',
      );
      return false;
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

  /// Check if notifications are permitted using permission_handler.
  /// This provides accurate status even for permanently denied permissions.
  Future<bool> areNotificationsEnabled() async {
    if (!_isInitialized) return false;

    try {
      final status = await Permission.notification.status;
      debugPrint('NotificationService: Permission status = $status');
      return status.isGranted;
    } catch (e) {
      debugPrint('NotificationService: Failed to check permissions - $e');
      return false;
    }
  }

  /// Check if notification permission is permanently denied.
  /// If true, user must go to system settings to enable.
  Future<bool> isPermissionPermanentlyDenied() async {
    try {
      final status = await Permission.notification.status;
      return status.isPermanentlyDenied;
    } catch (e) {
      return false;
    }
  }

  /// Open app settings so user can enable notification permission.
  Future<bool> openNotificationSettings() async {
    return await openAppSettings();
  }

  /// Schedule a notification for a tracked item when it reaches 90% of interval.
  /// The notification is scheduled at the specified hour and minute on the target date.
  /// [notificationHour] should be 0-23 (defaults to 9 for 9:00 AM)
  /// [notificationMinute] should be 0-59 (defaults to 0)
  Future<bool> scheduleItemNotification(
    TrackedItem item, {
    int notificationHour = 9,
    int notificationMinute = 0,
  }) async {
    if (!_isInitialized) {
      return false;
    }

    if (!item.notificationsEnabled) {
      // Cancel any existing notification for this item
      await cancelItemNotification(item.id);
      return true;
    }

    try {
      // Calculate when to send the notification (at 90% of interval)
      final notificationDate = _calculateNotificationDate(
        item,
        notificationHour: notificationHour,
        notificationMinute: notificationMinute,
      );

      if (notificationDate == null) {
        // If already at 90% or more, show notification immediately
        // This handles both warning (90-100%) and overdue (>100%) states
        if (item.percentageElapsed >= 90) {
          // Show notification now if in the warning or overdue zone
          return await _showImmediateNotification(item);
        }
        return true;
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

      // Schedule the notification
      await _notifications.zonedSchedule(
        _getNotificationId(item.id),
        _getNotificationTitle(item),
        _getNotificationBody(item),
        notificationDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: null, // One-time notification
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Cancel a scheduled notification for a tracked item.
  Future<void> cancelItemNotification(String itemId) async {
    if (!_isInitialized) return;

    try {
      await _notifications.cancel(_getNotificationId(itemId));
    } catch (e) {
      // Silently fail
    }
  }

  /// Cancel all scheduled notifications.
  Future<void> cancelAllNotifications() async {
    if (!_isInitialized) return;

    try {
      await _notifications.cancelAll();
    } catch (e) {
      // Silently fail
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
  Future<bool> _showImmediateNotification(TrackedItem item) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: _androidIcon,
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

      await _notifications.show(
        _getNotificationId(item.id),
        _getNotificationTitle(item),
        _getNotificationBody(item),
        details,
        payload: item.id,
      );

      debugPrint(
        'NotificationService: Showed immediate notification for ${item.name}',
      );
      return true;
    } catch (e) {
      debugPrint(
        'NotificationService: Failed to show immediate notification - $e',
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
