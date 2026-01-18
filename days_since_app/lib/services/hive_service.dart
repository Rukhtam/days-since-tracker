import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/tracked_item.dart';

/// Custom exception for HiveService errors
class HiveServiceException implements Exception {
  final String message;
  final dynamic originalError;

  HiveServiceException(this.message, [this.originalError]);

  @override
  String toString() => 'HiveServiceException: $message${originalError != null ? ' ($originalError)' : ''}';
}

/// Service class that handles all Hive database operations.
/// This abstracts the storage layer from the rest of the application.
class HiveService {
  static const String _trackedItemsBoxName = 'tracked_items';

  static Box<TrackedItem>? _trackedItemsBox;
  
  /// Track initialization errors for diagnostics
  static String? _initializationError;
  
  /// Get initialization error if any
  static String? get initializationError => _initializationError;

  /// Initialize Hive and register all type adapters.
  /// Must be called before any other Hive operations.
  static Future<void> initialize() async {
    try {
      _initializationError = null;
      await Hive.initFlutter();

      // Register type adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(TrackedItemAdapter());
      }

      // Open boxes
      _trackedItemsBox = await Hive.openBox<TrackedItem>(_trackedItemsBoxName);
      debugPrint('HiveService: Initialized successfully with ${_trackedItemsBox?.length ?? 0} items');
    } catch (e, stackTrace) {
      _initializationError = e.toString();
      debugPrint('HiveService: Initialization failed - $e');
      debugPrint('HiveService: Stack trace - $stackTrace');
      rethrow;
    }
  }

  /// Get the tracked items box, throwing an error if not initialized
  static Box<TrackedItem> get trackedItemsBox {
    if (_trackedItemsBox == null || !_trackedItemsBox!.isOpen) {
      throw HiveServiceException(
        'HiveService not initialized. Call HiveService.initialize() first.',
        _initializationError,
      );
    }
    return _trackedItemsBox!;
  }

  /// Get all tracked items from storage
  static List<TrackedItem> getAllItems() {
    try {
      return trackedItemsBox.values.toList();
    } catch (e) {
      debugPrint('HiveService: Failed to get all items - $e');
      if (e is HiveServiceException) rethrow;
      throw HiveServiceException('Failed to retrieve items', e);
    }
  }

  /// Get a single tracked item by its ID
  static TrackedItem? getItemById(String id) {
    try {
      return trackedItemsBox.values.firstWhere((item) => item.id == id);
    } on StateError {
      // Item not found - this is expected behavior, not an error
      return null;
    } catch (e) {
      debugPrint('HiveService: Failed to get item by ID - $e');
      return null;
    }
  }

  /// Add a new tracked item to storage
  static Future<void> addItem(TrackedItem item) async {
    try {
      await trackedItemsBox.put(item.id, item);
      debugPrint('HiveService: Added item "${item.name}" (${item.id})');
    } catch (e) {
      debugPrint('HiveService: Failed to add item - $e');
      if (e is HiveServiceException) rethrow;
      throw HiveServiceException('Failed to add item "${item.name}"', e);
    }
  }

  /// Update an existing tracked item
  static Future<void> updateItem(TrackedItem item) async {
    try {
      await trackedItemsBox.put(item.id, item);
      debugPrint('HiveService: Updated item "${item.name}" (${item.id})');
    } catch (e) {
      debugPrint('HiveService: Failed to update item - $e');
      if (e is HiveServiceException) rethrow;
      throw HiveServiceException('Failed to update item "${item.name}"', e);
    }
  }

  /// Delete a tracked item by its ID
  static Future<void> deleteItem(String id) async {
    try {
      await trackedItemsBox.delete(id);
      debugPrint('HiveService: Deleted item ($id)');
    } catch (e) {
      debugPrint('HiveService: Failed to delete item - $e');
      if (e is HiveServiceException) rethrow;
      throw HiveServiceException('Failed to delete item', e);
    }
  }

  /// Delete all tracked items (use with caution)
  static Future<void> deleteAllItems() async {
    try {
      await trackedItemsBox.clear();
      debugPrint('HiveService: Deleted all items');
    } catch (e) {
      debugPrint('HiveService: Failed to delete all items - $e');
      if (e is HiveServiceException) rethrow;
      throw HiveServiceException('Failed to delete all items', e);
    }
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
