# Days Since Tracker - Release Guide

This guide covers everything needed to prepare the app for Google Play Store release.

## Table of Contents
1. [App Icon Generation](#app-icon-generation)
2. [Signing Configuration](#signing-configuration)
3. [Building Release APK/AAB](#building-release)
4. [Play Store Assets](#play-store-assets)
5. [Play Store Listing](#play-store-listing)
6. [Testing Checklist](#testing-checklist)

---

## App Icon Generation

### Android (Adaptive Icons)
The adaptive icon is already configured with vector drawables:
- Foreground: `android/app/src/main/res/drawable/ic_launcher_foreground.xml`
- Background: Dark (#121212) defined in `values/ic_launcher_background.xml`
- Adaptive config: `mipmap-anydpi-v26/ic_launcher.xml`

The icon features:
- Green circular progress ring (matching app's status colors)
- Dark inner circle with "D" letter
- Yellow accent arc (representing warning state)

### iOS Icons (Manual Generation Required)
iOS requires PNG files. Use the vector design as reference and create:

| Size | Filename | Purpose |
|------|----------|---------|
| 20x20 | Icon-App-20x20@1x.png | iPad Notifications |
| 40x40 | Icon-App-20x20@2x.png | iPhone Notifications |
| 60x60 | Icon-App-20x20@3x.png | iPhone Notifications |
| 29x29 | Icon-App-29x29@1x.png | iPad Settings |
| 58x58 | Icon-App-29x29@2x.png | iPhone Settings |
| 87x87 | Icon-App-29x29@3x.png | iPhone Settings |
| 40x40 | Icon-App-40x40@1x.png | iPad Spotlight |
| 80x80 | Icon-App-40x40@2x.png | iPhone Spotlight |
| 120x120 | Icon-App-40x40@3x.png | iPhone Spotlight |
| 120x120 | Icon-App-60x60@2x.png | iPhone App |
| 180x180 | Icon-App-60x60@3x.png | iPhone App |
| 76x76 | Icon-App-76x76@1x.png | iPad App |
| 152x152 | Icon-App-76x76@2x.png | iPad App |
| 167x167 | Icon-App-83.5x83.5@2x.png | iPad Pro App |
| 1024x1024 | Icon-App-1024x1024@1x.png | App Store |

Place all icons in: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

**Icon Design Guidelines:**
- Background: #121212 (dark)
- Primary circle: #4CAF50 (green)
- Inner circle: #1E1E1E
- Letter/icon: #FFFFFF (white)
- Accent arc: #FFC107 (yellow/amber)

---

## Signing Configuration

### Step 1: Generate a Keystore
```bash
keytool -genkey -v -keystore ~/days-since-upload-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

When prompted:
- Enter a secure password (save this!)
- Provide organization details
- Confirm the information

### Step 2: Create key.properties
Copy the template and fill in your values:
```bash
cp android/key.properties.template android/key.properties
```

Edit `android/key.properties`:
```properties
storePassword=YOUR_SECURE_PASSWORD
keyPassword=YOUR_SECURE_PASSWORD
keyAlias=upload
storeFile=/Users/YOUR_USERNAME/days-since-upload-key.jks
```

**IMPORTANT:**
- Never commit `key.properties` to version control
- Back up your keystore file securely
- If you lose the keystore, you cannot update your app on Play Store

### Step 3: Verify Signing
The `build.gradle.kts` is already configured to:
- Load signing config from `key.properties`
- Fall back to debug signing if no keystore found
- Enable R8 minification for release builds

---

## Building Release

### Build APK (for direct distribution)
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### Build App Bundle (for Play Store - recommended)
```bash
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

### Build with Specific Version
Edit `pubspec.yaml`:
```yaml
version: 1.0.0+1  # format: version_name+version_code
```
- `version_name`: User-visible (e.g., "1.0.0")
- `version_code`: Integer for Play Store updates (must increase each release)

---

## Play Store Assets

### Required Screenshots
Prepare screenshots for different device types:

| Device Type | Dimensions | Required |
|-------------|------------|----------|
| Phone | 1080x1920 or 1080x2340 | Yes (2-8) |
| 7" Tablet | 1200x1920 | Optional |
| 10" Tablet | 1600x2560 | Optional |

**Recommended Screenshots:**
1. Empty state with "Add your first tracker" prompt
2. Home screen with multiple items (showing good, warning, overdue states)
3. Adding a new item (bottom sheet dialog)
4. Item card detail showing progress ring
5. Settings screen
6. Reset confirmation with undo snackbar

**Screenshot Tips:**
- Use a device with notch for modern look
- Show diverse tracker examples (haircut, oil change, dentist, etc.)
- Highlight the color-coded status system
- Show notification examples if possible

### Feature Graphic
- Size: 1024x500 pixels
- Used at top of Play Store listing
- Should convey app purpose at a glance

**Suggested Design:**
- Dark background (#121212)
- App icon prominently displayed
- Tagline: "Track days since your last... everything"
- Show 2-3 example tracker cards

### High-res Icon
- Size: 512x512 pixels
- Used in Play Store search and listings
- Same design as app icon but larger

---

## Play Store Listing

### App Details

**Title:** Days Since - Habit & Task Tracker
(Max 50 characters, include keywords)

**Short Description:** (Max 80 characters)
```
Track days since recurring events. Simple reminders for life's regular tasks.
```

**Full Description:** (Max 4000 characters)
```
Days Since is a minimal, beautiful tracker app that helps you remember when you last did important recurring tasks.

KEY FEATURES:

- Simple Day Counter - See at a glance how many days have passed since your last haircut, oil change, dentist visit, or any recurring task.

- Visual Progress Rings - Beautiful circular progress indicators show exactly where you are in each cycle.

- Smart Status Colors:
  Green - You're on track, plenty of time remaining
  Yellow - Approaching your recommended interval
  Red - Overdue! Time to take action

- Quick Templates - Get started fast with pre-configured templates for common trackers like:
  * Personal care (haircut, skincare, dental)
  * Home maintenance (filters, cleaning, inspections)
  * Vehicle care (oil change, tire rotation)
  * Health (checkups, prescriptions, vitamins)

- Customizable - Set your own intervals, choose icons and colors to personalize each tracker.

- Reminders - Get notified when tasks are approaching their due date.

- One-Tap Reset - Quickly mark a task as done with haptic feedback confirmation.

- Dark Theme - Easy on the eyes, beautiful minimal design.

- Offline First - All data stored locally on your device. No account required.

PERFECT FOR:
- Tracking personal grooming schedules
- Vehicle and home maintenance reminders
- Health and wellness check-up schedules
- Any recurring task you want to stay on top of

Days Since uses a clean, distraction-free interface to help you maintain good habits without the complexity of full task management apps.

Privacy: All data is stored locally on your device. No data is collected or transmitted.
```

### Category
- Primary: Productivity
- Secondary: Tools

### Content Rating
- Complete the content rating questionnaire (IARC)
- Expected rating: Everyone

### Tags/Keywords
- days since
- tracker
- habit tracker
- maintenance reminder
- recurring tasks
- interval tracker
- routine tracker

---

## Testing Checklist

### Pre-Release Testing

#### CRUD Operations
- [ ] Add new item with all fields
- [ ] Add item from template
- [ ] Edit existing item (all fields)
- [ ] Delete item with confirmation
- [ ] Reset item to today
- [ ] Undo reset action

#### Data Persistence
- [ ] Items persist after app restart
- [ ] Items persist after device restart
- [ ] Settings persist across sessions
- [ ] Sort order preference saves

#### UI/UX
- [ ] All status colors display correctly (green/yellow/red)
- [ ] Progress rings animate smoothly
- [ ] Day counters update correctly
- [ ] Empty state displays when no items
- [ ] Pull-to-refresh works
- [ ] Haptic feedback on actions
- [ ] Swipe/long-press menus work

#### Notifications
- [ ] Permission request on first launch
- [ ] Notifications scheduled correctly
- [ ] Notification appears at 90% of interval
- [ ] Tapping notification opens app

#### Edge Cases
- [ ] Very long item names (text truncation)
- [ ] Zero-day intervals handled
- [ ] Future dates handled gracefully
- [ ] Timezone changes don't break calculations

#### Performance
- [ ] App launches quickly (< 2 seconds)
- [ ] Scrolling is smooth with many items
- [ ] No memory leaks on repeated add/delete
- [ ] Release APK size is reasonable (< 30MB preferred)

#### Device Testing
- [ ] Small phone (5" screen)
- [ ] Large phone (6.5"+ screen)
- [ ] Tablet (if supporting)
- [ ] Different Android versions (API 24+)

---

## Version History

### v1.0.0 (Initial Release)
- Core day tracking functionality
- Add, edit, delete, reset operations
- Progress ring visualization
- Status color coding (good/warning/overdue)
- Template quick-add
- Local notifications
- Dark theme
- Hive local storage
- Provider state management

---

## Support & Feedback

For the Play Store listing, include:
- Privacy Policy URL (required)
- Support email address
- Website (optional)

**Privacy Policy Requirements:**
Since the app uses local storage only and doesn't collect user data, the privacy policy can be simple. Key points to include:
1. No data collection
2. All data stored locally on device
3. Notification permission usage
4. No third-party data sharing

---

## Quick Reference

### Build Commands
```bash
# Development
flutter run

# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# Play Store Bundle
flutter build appbundle --release

# Analyze code
flutter analyze

# Run tests
flutter test
```

### File Locations
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`
- Keystore: `~/days-since-upload-key.jks` (your location)
- Signing config: `android/key.properties`

### Important Files
- `pubspec.yaml` - Version and dependencies
- `android/app/build.gradle.kts` - Android configuration
- `android/app/src/main/AndroidManifest.xml` - Permissions and app name
- `ios/Runner/Info.plist` - iOS configuration
