import 'package:hive/hive.dart';

part 'tracked_item.g.dart';

/// Represents an item being tracked by the user.
/// Each item tracks days since an event last occurred and provides
/// visual feedback based on the recommended interval.
@HiveType(typeId: 0)
class TrackedItem extends HiveObject {
  /// Unique identifier for the item (UUID)
  @HiveField(0)
  final String id;

  /// Display name of the tracked item (e.g., "Haircut", "Oil Change")
  @HiveField(1)
  String name;

  /// Material icon name to display for this item
  @HiveField(2)
  String iconName;

  /// Recommended number of days between occurrences
  @HiveField(3)
  int recommendedIntervalDays;

  /// The date when this item was last reset/completed
  @HiveField(4)
  DateTime lastResetDate;

  /// Hex color code for the item's accent color
  @HiveField(5)
  String color;

  /// Whether notifications are enabled for this item
  @HiveField(6)
  bool notificationsEnabled;

  /// Optional notes for the item
  @HiveField(7)
  String? notes;

  TrackedItem({
    required this.id,
    required this.name,
    required this.iconName,
    required this.recommendedIntervalDays,
    required this.lastResetDate,
    required this.color,
    this.notificationsEnabled = true,
    this.notes,
  });

  /// Calculate the number of days since the last reset
  int get daysSinceReset {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastReset = DateTime(
      lastResetDate.year,
      lastResetDate.month,
      lastResetDate.day,
    );
    return today.difference(lastReset).inDays;
  }

  /// Calculate the percentage of the interval that has elapsed
  /// Returns a value between 0.0 and any positive number (can exceed 100%)
  double get percentageElapsed {
    if (recommendedIntervalDays <= 0) return 0.0;
    return (daysSinceReset / recommendedIntervalDays) * 100;
  }

  /// Get the status of this item based on percentage elapsed
  /// - good: < 70% (green)
  /// - warning: 70% - 100% (yellow)
  /// - overdue: > 100% (red)
  ItemStatus get status {
    final percentage = percentageElapsed;
    if (percentage < 70) {
      return ItemStatus.good;
    } else if (percentage <= 100) {
      return ItemStatus.warning;
    } else {
      return ItemStatus.overdue;
    }
  }

  /// Get the status color hex code based on current status
  String get statusColor {
    switch (status) {
      case ItemStatus.good:
        return '#4CAF50'; // Green
      case ItemStatus.warning:
        return '#FFC107'; // Yellow/Amber
      case ItemStatus.overdue:
        return '#F44336'; // Red
    }
  }

  /// Calculate the number of days until the recommended interval is reached
  /// Returns negative value if overdue
  int get daysUntilDue {
    return recommendedIntervalDays - daysSinceReset;
  }

  /// Check if notifications should be triggered (at 90% of interval)
  bool get shouldNotify {
    return notificationsEnabled && percentageElapsed >= 90;
  }

  /// Reset the item to today's date
  void reset() {
    lastResetDate = DateTime.now();
    save(); // Hive will persist the change
  }

  /// Create a copy of this item with optional overrides
  TrackedItem copyWith({
    String? id,
    String? name,
    String? iconName,
    int? recommendedIntervalDays,
    DateTime? lastResetDate,
    String? color,
    bool? notificationsEnabled,
    String? notes,
  }) {
    return TrackedItem(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      recommendedIntervalDays:
          recommendedIntervalDays ?? this.recommendedIntervalDays,
      lastResetDate: lastResetDate ?? this.lastResetDate,
      color: color ?? this.color,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() {
    return 'TrackedItem(id: $id, name: $name, daysSince: $daysSinceReset, status: $status)';
  }
}

/// Status enum for tracked items based on interval percentage
enum ItemStatus {
  good,    // < 70% - Everything is fine
  warning, // 70-100% - Getting close to due date
  overdue, // > 100% - Past the recommended interval
}
