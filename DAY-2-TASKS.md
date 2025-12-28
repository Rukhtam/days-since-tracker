# Day 2 Tasks - Days Since Tracker App

**Date**: December 28, 2025
**Agent**: claude-app
**Status**: 🟢 Ahead of Schedule (40% of Week 1 complete)

---

## 🎯 Today's Mission

Generate Hive code and implement the storage service to get CRUD operations working.

---

## ✅ Already Completed (Day 1 Recap)

- ✅ Flutter project created
- ✅ Complete folder structure (20+ Dart files)
- ✅ All dependencies installed
- ✅ TrackedItem model with Hive annotations
- ✅ 9 custom widgets created
- ✅ Git repository synced to GitHub

---

## 📋 Day 2 Priorities

### Priority 1: Generate Hive Code
**Goal**: Run build_runner to generate Hive type adapters

Tasks:
- [ ] Run `flutter pub run build_runner build --delete-conflicting-outputs`
- [ ] Verify `tracked_item.g.dart` is generated
- [ ] Fix any code generation errors
- [ ] Commit the generated file

**Expected Outcome**: `lib/models/tracked_item.g.dart` exists and compiles

---

### Priority 2: Implement Storage Service
**Goal**: Complete the HiveService implementation

Tasks:
- [ ] Implement `init()` method to initialize Hive
- [ ] Implement `addItem(TrackedItem item)` method
- [ ] Implement `getItems()` method to fetch all items
- [ ] Implement `updateItem(TrackedItem item)` method
- [ ] Implement `deleteItem(String id)` method
- [ ] Add error handling

**Expected Outcome**: Full CRUD operations working with Hive

---

### Priority 3: Update Main App Structure
**Goal**: Initialize Hive and set up Provider

Tasks:
- [ ] Initialize Hive in `main()` before runApp
- [ ] Register Hive adapters
- [ ] Wrap MaterialApp with Provider
- [ ] Set up ChangeNotifierProvider for TrackedItemsProvider
- [ ] Test that app runs without errors

**Expected Outcome**: App initializes properly with Hive and Provider

---

### Priority 4 (Stretch): Test CRUD Operations
**Goal**: Verify everything works end-to-end

Tasks:
- [ ] Add a test item using the add dialog
- [ ] Verify item appears in list
- [ ] Edit the item
- [ ] Delete the item
- [ ] Restart app and verify data persists

**Expected Outcome**: Full CRUD cycle works and data persists

---

## 🔧 Technical Implementation

### build_runner Command

```bash
cd days_since_app

# Generate Hive adapters
flutter pub run build_runner build --delete-conflicting-outputs

# Or use watch mode for development
flutter pub run build_runner watch
```

### HiveService Implementation Template

```dart
// lib/services/hive_service.dart
class HiveService {
  static const String _boxName = 'tracked_items';
  Box<TrackedItem>? _box;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TrackedItemAdapter());
    _box = await Hive.openBox<TrackedItem>(_boxName);
  }

  Future<void> addItem(TrackedItem item) async {
    await _box?.put(item.id, item);
  }

  List<TrackedItem> getItems() {
    return _box?.values.toList() ?? [];
  }

  Future<void> updateItem(TrackedItem item) async {
    await item.save(); // HiveObject method
  }

  Future<void> deleteItem(String id) async {
    await _box?.delete(id);
  }
}
```

### Main.dart Initialization

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  final hiveService = HiveService();
  await hiveService.init();

  runApp(
    ChangeNotifierProvider(
      create: (_) => TrackedItemsProvider(hiveService),
      child: const MyApp(),
    ),
  );
}
```

---

## 📊 Success Metrics

By end of Day 2, you should have:
- ✅ Hive code generated (`tracked_item.g.dart`)
- ✅ Storage service fully implemented
- ✅ App initializes with Hive and Provider
- ✅ Can add items (they persist)
- 🎯 (Stretch) Full CRUD working and tested

---

## 🚀 Getting Started

```bash
# Navigate to Flutter project
cd /Users/rukhtamamin/claude-main/claude-app/days_since_app

# Get dependencies (if needed)
flutter pub get

# Generate Hive code
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app
flutter run

# Or run on specific device
flutter devices
flutter run -d <device-id>
```

---

## 🔧 Troubleshooting

**If build_runner fails:**
- Check that `tracked_item.dart` has proper Hive annotations
- Delete `.dart_tool` and `build` folders
- Run `flutter clean` then try again

**If app crashes on startup:**
- Check that Hive is initialized before opening box
- Verify adapter is registered before opening box
- Check for typos in box name

---

## 📝 Commit Message Template

```
Implement Hive storage and CRUD operations

- Generate Hive type adapters with build_runner
- Implement HiveService with full CRUD methods
- Initialize Hive in main.dart before app starts
- Set up Provider for state management
- Test add/edit/delete operations
- Verify data persistence across app restarts
```

---

**Read AGENT-PROGRESS.md for full context**
**GitHub**: https://github.com/Rukhtam/days-since-tracker
