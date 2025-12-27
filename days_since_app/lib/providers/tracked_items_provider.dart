import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/tracked_item.dart';
import '../services/hive_service.dart';
import '../services/notification_service.dart';

/// Provider that manages the state of all tracked items.
/// Uses ChangeNotifier for reactive updates throughout the app.
class TrackedItemsProvider extends ChangeNotifier {
  List<TrackedItem> _items = [];
  bool _isLoading = false;
  String? _error;
  String _sortOrder = 'status';

  final Uuid _uuid = const Uuid();
  final NotificationService _notificationService = NotificationService();

  /// Get or set the current sort order
  String get sortOrder => _sortOrder;

  set sortOrder(String value) {
    if (_sortOrder != value) {
      _sortOrder = value;
      notifyListeners();
    }
  }

  /// Get all tracked items
  List<TrackedItem> get items => List.unmodifiable(_items);

  /// Get items sorted by status (overdue first, then warning, then good)
  List<TrackedItem> get itemsSortedByStatus {
    final sorted = List<TrackedItem>.from(_items);
    sorted.sort((a, b) {
      // Sort by status priority: overdue > warning > good
      final statusOrder = {
        ItemStatus.overdue: 0,
        ItemStatus.warning: 1,
        ItemStatus.good: 2,
      };
      final statusCompare =
          statusOrder[a.status]!.compareTo(statusOrder[b.status]!);
      if (statusCompare != 0) return statusCompare;
      // If same status, sort by percentage elapsed (descending)
      return b.percentageElapsed.compareTo(a.percentageElapsed);
    });
    return sorted;
  }

  /// Get items sorted by days since reset (descending)
  List<TrackedItem> get itemsSortedByDays {
    final sorted = List<TrackedItem>.from(_items);
    sorted.sort((a, b) => b.daysSinceReset.compareTo(a.daysSinceReset));
    return sorted;
  }

  /// Get items sorted by name (alphabetical)
  List<TrackedItem> get itemsSortedByName {
    final sorted = List<TrackedItem>.from(_items);
    sorted.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return sorted;
  }

  /// Get items sorted by most recently reset
  List<TrackedItem> get itemsSortedByRecent {
    final sorted = List<TrackedItem>.from(_items);
    sorted.sort((a, b) => b.lastResetDate.compareTo(a.lastResetDate));
    return sorted;
  }

  /// Get items sorted by the current sort order setting
  List<TrackedItem> get itemsSortedByPreference {
    switch (_sortOrder) {
      case 'status':
        return itemsSortedByStatus;
      case 'days':
        return itemsSortedByDays;
      case 'name':
        return itemsSortedByName;
      case 'recent':
        return itemsSortedByRecent;
      default:
        return itemsSortedByStatus;
    }
  }

  /// Check if data is currently loading
  bool get isLoading => _isLoading;

  /// Get any error message
  String? get error => _error;

  /// Check if there are any items
  bool get isEmpty => _items.isEmpty;

  /// Get the total number of items
  int get itemCount => _items.length;

  /// Get count of items by status
  int get overdueCount =>
      _items.where((item) => item.status == ItemStatus.overdue).length;
  int get warningCount =>
      _items.where((item) => item.status == ItemStatus.warning).length;
  int get goodCount =>
      _items.where((item) => item.status == ItemStatus.good).length;

  /// Load all items from storage
  Future<void> loadItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _items = HiveService.getAllItems();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load items: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a new tracked item
  Future<bool> addItem({
    required String name,
    required String iconName,
    required int recommendedIntervalDays,
    required String color,
    DateTime? lastResetDate,
    bool notificationsEnabled = true,
    String? notes,
  }) async {
    try {
      final item = TrackedItem(
        id: _uuid.v4(),
        name: name,
        iconName: iconName,
        recommendedIntervalDays: recommendedIntervalDays,
        lastResetDate: lastResetDate ?? DateTime.now(),
        color: color,
        notificationsEnabled: notificationsEnabled,
        notes: notes,
      );

      await HiveService.addItem(item);
      _items.add(item);

      // Schedule notification for the new item
      if (item.notificationsEnabled) {
        _notificationService.scheduleItemNotification(item);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add item: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Update an existing tracked item
  Future<bool> updateItem(TrackedItem updatedItem) async {
    try {
      await HiveService.updateItem(updatedItem);
      final index = _items.indexWhere((item) => item.id == updatedItem.id);
      if (index != -1) {
        _items[index] = updatedItem;

        // Update notification schedule for this item
        _notificationService.scheduleItemNotification(updatedItem);

        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = 'Failed to update item: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Delete a tracked item by ID
  Future<bool> deleteItem(String id) async {
    try {
      // Cancel any pending notification for this item
      await _notificationService.cancelItemNotification(id);

      await HiveService.deleteItem(id);
      _items.removeWhere((item) => item.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete item: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Reset an item (update lastResetDate to now)
  Future<bool> resetItem(String id) async {
    try {
      final index = _items.indexWhere((item) => item.id == id);
      if (index != -1) {
        final item = _items[index];
        final updatedItem = item.copyWith(lastResetDate: DateTime.now());
        await HiveService.updateItem(updatedItem);
        _items[index] = updatedItem;

        // Reschedule notification for the reset item
        _notificationService.scheduleItemNotification(updatedItem);

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to reset item: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Get a single item by ID
  TrackedItem? getItemById(String id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Clear any error messages
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Refresh all items (useful when app resumes)
  Future<void> refresh() async {
    await loadItems();
  }
}
