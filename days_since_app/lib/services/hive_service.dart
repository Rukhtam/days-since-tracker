import 'package:hive_flutter/hive_flutter.dart';
import '../models/tracked_item.dart';

/// Service class that handles all Hive database operations.
/// This abstracts the storage layer from the rest of the application.
class HiveService {
  static const String _trackedItemsBoxName = 'tracked_items';

  static Box<TrackedItem>? _trackedItemsBox;

  /// Initialize Hive and register all type adapters.
  /// Must be called before any other Hive operations.
  static Future<void> initialize() async {
    await Hive.initFlutter();

    // Register type adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TrackedItemAdapter());
    }

    // Open boxes
    _trackedItemsBox = await Hive.openBox<TrackedItem>(_trackedItemsBoxName);
  }

  /// Get the tracked items box, throwing an error if not initialized
  static Box<TrackedItem> get trackedItemsBox {
    if (_trackedItemsBox == null || !_trackedItemsBox!.isOpen) {
      throw StateError(
        'HiveService not initialized. Call HiveService.initialize() first.',
      );
    }
    return _trackedItemsBox!;
  }

  /// Get all tracked items from storage
  static List<TrackedItem> getAllItems() {
    return trackedItemsBox.values.toList();
  }

  /// Get a single tracked item by its ID
  static TrackedItem? getItemById(String id) {
    try {
      return trackedItemsBox.values.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Add a new tracked item to storage
  static Future<void> addItem(TrackedItem item) async {
    await trackedItemsBox.put(item.id, item);
  }

  /// Update an existing tracked item
  static Future<void> updateItem(TrackedItem item) async {
    await trackedItemsBox.put(item.id, item);
  }

  /// Delete a tracked item by its ID
  static Future<void> deleteItem(String id) async {
    await trackedItemsBox.delete(id);
  }

  /// Delete all tracked items (use with caution)
  static Future<void> deleteAllItems() async {
    await trackedItemsBox.clear();
  }

  /// Check if the service is initialized and box is open
  static bool get isInitialized {
    return _trackedItemsBox != null && _trackedItemsBox!.isOpen;
  }

  /// Get the number of tracked items
  static int get itemCount {
    return trackedItemsBox.length;
  }

  /// Close all open boxes (call when app is disposed)
  static Future<void> close() async {
    await _trackedItemsBox?.close();
  }

  /// Listen to changes in the tracked items box
  /// Returns a listenable that can be used with ValueListenableBuilder
  static Box<TrackedItem> listenableBox() {
    return trackedItemsBox;
  }
}
