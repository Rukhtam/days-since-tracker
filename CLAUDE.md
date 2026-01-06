# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Days Since Tracker is a minimalist Flutter mobile app for tracking days since recurring events (haircuts, oil changes, etc.). Features progress ring visualization with color-coded status indicators (green/yellow/red) and 35+ pre-set templates. Target launch: January 25, 2026 (Android via Google Play Store).

**Framework**: Flutter SDK ^3.10.4
**Language**: Dart
**Target Platform**: Android (iOS support included but not primary)

## Development Commands

```bash
# Navigate to the Flutter project directory
cd days_since_app

# Install dependencies
flutter pub get

# Run code generation for Hive models
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app (debug mode)
flutter run

# Run on specific device
flutter run -d <device-id>

# List available devices
flutter devices

# Build release APK
flutter build apk --release

# Build release App Bundle (for Play Store)
flutter build appbundle --release

# Generate app icons
flutter pub run flutter_launcher_icons

# Generate splash screens
flutter pub run flutter_native_splash:create

# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
dart format .
```

**Note**: The actual Flutter project is in `days_since_app/` subdirectory, NOT the root.

## Project Structure

```
days_since_app/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── models/
│   │   ├── tracked_item.dart        # TrackedItem data model with Hive annotations
│   │   └── tracked_item.g.dart      # Generated Hive adapter
│   ├── screens/
│   │   ├── home_screen.dart         # Main screen with item list
│   │   └── settings_screen.dart     # Settings and preferences
│   ├── widgets/
│   │   ├── tracked_item_card.dart   # Item card with progress ring
│   │   ├── add_item_dialog.dart     # Dialog for creating items
│   │   ├── edit_item_dialog.dart    # Dialog for editing items
│   │   ├── empty_state.dart         # Empty state placeholder
│   │   ├── icon_picker.dart         # Icon selection widget
│   │   ├── color_picker.dart        # Color selection widget
│   │   └── ...                      # Other widgets
│   ├── providers/
│   │   ├── tracked_items_provider.dart  # State management for items
│   │   └── settings_provider.dart       # App settings state
│   ├── services/
│   │   ├── hive_service.dart           # Hive initialization & management
│   │   └── notification_service.dart   # Local notifications
│   ├── constants/
│   │   ├── app_theme.dart              # Light/dark theme definitions
│   │   ├── app_colors.dart             # Color constants
│   │   └── templates.dart              # Pre-set item templates (35+)
│   └── utils/
│       ├── milestone_utils.dart        # Milestone calculations
│       └── icon_utils.dart             # Icon utilities
├── assets/
│   ├── icon/                           # App icon files
│   └── splash/                         # Splash screen files
├── android/                            # Android-specific config
├── ios/                                # iOS-specific config
├── pubspec.yaml                        # Dependencies and config
└── README.md
```

## Core Architecture

### State Management (Provider)

The app uses `provider` package for state management with two main providers:

#### SettingsProvider (`lib/providers/settings_provider.dart`)
Manages app-wide settings persisted to Hive.

**Key properties**:
- `flutterThemeMode: ThemeMode` - Light/dark/system theme
- `notificationsEnabled: bool` - Global notification toggle
- `sortOrder: SortOrder` - Item sort order (dateAdded, daysElapsed, name, interval)
- `isFirstLaunch: bool` - First launch flag
- `isInitialized: bool` - Provider ready state

**Usage**:
```dart
final settings = Provider.of<SettingsProvider>(context);
final themeMode = settings.flutterThemeMode;

// Or with Consumer
Consumer<SettingsProvider>(
  builder: (context, settings, _) {
    return Switch(value: settings.notificationsEnabled, ...);
  },
)
```

#### TrackedItemsProvider (`lib/providers/tracked_items_provider.dart`)
Manages the list of tracked items.

**Key methods**:
- `loadItems()` - Load from Hive
- `addItem(TrackedItem item)` - Add new item
- `updateItem(TrackedItem item)` - Update existing
- `deleteItem(String id)` - Delete item
- `resetItem(String id)` - Reset date to today
- `sortOrder` setter - Update sort order

**Usage**:
```dart
final itemsProvider = Provider.of<TrackedItemsProvider>(context);
itemsProvider.addItem(newItem);

// Or with Consumer
Consumer<TrackedItemsProvider>(
  builder: (context, provider, _) {
    final items = provider.items;
    return ListView.builder(...);
  },
)
```

### Data Model (Hive)

**TrackedItem** (`lib/models/tracked_item.dart`) with Hive type annotations:

```dart
@HiveType(typeId: 0)
class TrackedItem extends HiveObject {
  @HiveField(0) final String id;              // UUID
  @HiveField(1) String name;                  // Display name
  @HiveField(2) String iconName;              // Material icon name
  @HiveField(3) int recommendedIntervalDays;  // Interval in days
  @HiveField(4) DateTime lastResetDate;       // Last reset/completion
  @HiveField(5) String color;                 // Hex color code
  @HiveField(6) bool notificationsEnabled;    // Per-item notifications
  @HiveField(7) String? notes;                // Optional notes

  // Computed properties
  int get daysSinceReset;         // Days since last reset
  double get percentageElapsed;   // Percentage of interval elapsed
  ItemStatus get status;          // good/warning/overdue
  String get statusColor;         // Hex color for status
  int get daysUntilDue;          // Days until recommended interval
  bool get shouldNotify;         // Whether to send notification

  void reset();                   // Reset to today
}
```

**Status Logic**:
- **good** (green #4CAF50): < 70% of interval
- **warning** (yellow #FFC107): 70% - 100% of interval
- **overdue** (red #F44336): > 100% of interval

**Code Generation**:
After modifying `tracked_item.dart`, run:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```
This generates `tracked_item.g.dart` with Hive adapters.

### Services

#### HiveService (`lib/services/hive_service.dart`)
Handles Hive database initialization.

```dart
// Initialize in main.dart
await HiveService.initialize();

// Access boxes
final itemsBox = await Hive.openBox<TrackedItem>('tracked_items');
final settingsBox = await Hive.openBox('settings');
```

#### NotificationService (`lib/services/notification_service.dart`)
Manages local notifications using `flutter_local_notifications`.

**Key methods**:
- `initialize({Function(dynamic)? onNotificationTap})`
- `requestPermissions() -> Future<bool>`
- `scheduleNotificationForItem(TrackedItem item)`
- `cancelNotificationForItem(String itemId)`
- `updateAllNotifications(List<TrackedItem> items)`

**Notification Trigger**: At 90% of the recommended interval.

### Theme System (`lib/constants/app_theme.dart`)

Light and dark themes with Material Design 3 principles:

**Light Theme**:
- Background: #FAFAFA
- Surface: #FFFFFF
- Primary: #4CAF50 (green)

**Dark Theme**:
- Background: #121212
- Surface: #1E1E1E
- Primary: #4CAF50 (green, same as light)

**System UI**: Status bar and navigation bar colors update dynamically based on theme.

### Templates (`lib/constants/templates.dart`)

35+ pre-configured templates in categories:
- Personal Care (haircut, skincare, dental cleaning, etc.)
- Health & Fitness (exercise, vitamins, checkup, etc.)
- Home & Auto (oil change, air filter, lawn care, etc.)
- Finance (budget review, subscription check, etc.)
- Technology (password update, backup, software update, etc.)

Each template includes:
- `name: String`
- `iconName: String` (Material Icons name)
- `recommendedIntervalDays: int`
- `color: String` (hex code)
- `category: String`

## Key Features Implementation

### Progress Ring Visualization
Located in `TrackedItemCard` widget. Uses `CustomPaint` to draw:
1. Background ring (light grey)
2. Progress ring (colored by status)
3. Status indicator dot

**Colors**:
- Green: < 70%
- Yellow: 70-100%
- Red: > 100%

### Icon & Color Picker
- **IconPicker**: Grid of Material Icons with search
- **ColorPicker**: Pre-defined color palette matching app theme

### Sorting
Four sort orders:
- `dateAdded`: Newest first
- `daysElapsed`: Most days first
- `name`: Alphabetical
- `interval`: Shortest interval first

## App Configuration Files

### pubspec.yaml
Key dependencies:
- `provider: ^6.1.2` - State management
- `hive: ^2.2.3` + `hive_flutter: ^1.1.0` - Local storage
- `flutter_local_notifications: ^18.0.1` - Notifications
- `permission_handler: ^11.3.1` - Permissions
- `uuid: ^4.5.1` - ID generation
- `vibration: ^2.0.0` - Haptic feedback

Dev dependencies:
- `hive_generator: ^2.0.1` + `build_runner: ^2.4.13` - Code gen
- `flutter_launcher_icons: ^0.13.1` - Icon generation
- `flutter_native_splash: ^2.3.10` - Splash screen

### Android Configuration
**Important files**:
- `android/app/build.gradle` - Build config, signing, min SDK (21)
- `android/app/src/main/AndroidManifest.xml` - Permissions, app name
- `android/key.properties` - Release signing config (NOT committed)

**Permissions required**:
- `POST_NOTIFICATIONS` - For local notifications (Android 13+)
- `VIBRATE` - For haptic feedback
- `RECEIVE_BOOT_COMPLETED` - For notification persistence

## Release Process

### Building Release APK
```bash
cd days_since_app
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### Building App Bundle (for Play Store)
```bash
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

**Critical**: Ensure `android/key.properties` is configured with release keystore before building.

### App Signing
1. Create keystore: `keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`
2. Create `android/key.properties`:
```
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=<path-to-jks>
```
3. Verify `android/app/build.gradle` references `key.properties`

## Current State (As of Jan 2026)

**Completed** (95%):
- ✅ All core CRUD operations
- ✅ 35+ templates
- ✅ Local notifications
- ✅ Dark/light themes
- ✅ App icon (adaptive for Android)
- ✅ Splash screen
- ✅ Progress ring visualization
- ✅ Status color coding
- ✅ Hive persistence
- ✅ Full UI implementation

**Remaining for Release**:
- [ ] Google Play Store screenshots (7 required)
- [ ] Play Store listing (description, graphics)
- [ ] Final device testing on multiple Android versions
- [ ] Release signing and upload

## Common Development Tasks

### Adding a New Template
Edit `lib/constants/templates.dart`:
```dart
Template(
  name: 'New Item',
  iconName: 'icon_name',  // From Material Icons
  recommendedIntervalDays: 30,
  color: '#4CAF50',
  category: 'Category Name',
)
```

### Adding a New Field to TrackedItem
1. Add field to `tracked_item.dart` with `@HiveField(N)` annotation
2. Run `flutter pub run build_runner build --delete-conflicting-outputs`
3. Update `copyWith()` method
4. Increment typeId if breaking changes

### Debugging Notifications
```dart
// Check permissions
final granted = await NotificationService().requestPermissions();
print('Permissions: $granted');

// Manually schedule test notification
await NotificationService().scheduleNotificationForItem(testItem);
```

### Clearing Hive Data (for testing)
```dart
await Hive.deleteBoxFromDisk('tracked_items');
await Hive.deleteBoxFromDisk('settings');
```
Or: Uninstall and reinstall the app.

## Troubleshooting

**Build fails with Hive errors**:
- Run `flutter pub run build_runner build --delete-conflicting-outputs`
- Check that `part 'tracked_item.g.dart';` is at top of model file

**Notifications not appearing**:
- Verify permissions granted
- Check Android notification settings for the app
- Ensure item has `notificationsEnabled: true`
- Verify global `notificationsEnabled` in settings

**Icons not rendering**:
- Verify icon name matches Material Icons exactly
- Check `icon_utils.dart` for icon name mapping

**Theme not updating**:
- Check `SettingsProvider.flutterThemeMode` value
- Verify `MaterialApp` is wrapped in `Consumer<SettingsProvider>`
- System theme changes require app restart

## Testing Checklist

Before release:
- [ ] CRUD operations work correctly
- [ ] Progress rings update accurately
- [ ] Status colors change at correct thresholds (70%, 100%)
- [ ] Notifications trigger at 90% of interval
- [ ] Theme switching works (light/dark/system)
- [ ] App persists data after restart
- [ ] Templates load correctly
- [ ] Reset functionality works
- [ ] Sorting works for all options
- [ ] Empty state displays when no items
- [ ] Haptic feedback triggers appropriately
- [ ] App works on Android 5.0+ (API 21+)
