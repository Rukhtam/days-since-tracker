# Day 3 Tasks - Days Since Tracker App

**Date**: December 29, 2025
**Agent**: claude-app
**Status**: 🟢 Week 1 Complete - Moving to Week 2 Polish

---

## 🎉 Day 2 Recap

**AMAZING PROGRESS!** You completed:
- ✅ All Week 1 features
- ✅ Device testing complete
- ✅ Dark/Light theme implementation
- ✅ Zero compilation errors
- ✅ App is production-ready functionally

---

## 🎯 Today's Mission

Focus on **visual polish and branding** to prepare for Play Store launch.

---

## 📋 Day 3 Priorities

### Priority 1: App Icon Design
**Goal**: Create adaptive app icon for Android (and iOS if time permits)

Tasks:
- [ ] Design app icon concept
  - Consider: Calendar/clock theme
  - Simple, recognizable at small sizes
  - Follows Material Design principles
- [ ] Create icon assets:
  - Android: `mipmap-*/ic_launcher.png` (48dp to 192dp)
  - Foreground and background layers for adaptive icon
  - Optional: Monochrome icon for themed icons
- [ ] Update `android/app/src/main/res/` with new icons
- [ ] Test icon on device/emulator
- [ ] Verify adaptive icon works on Android 8+

**Tools/Resources**:
- Use Figma, Adobe Illustrator, or online tools
- Android Asset Studio: https://romannurik.github.io/AndroidAssetStudio/
- Material icons for inspiration

**Expected Outcome**: Custom app icon showing in launcher

---

### Priority 2: Splash Screen
**Goal**: Add branded splash screen for professional feel

Tasks:
- [ ] Design splash screen:
  - App icon/logo centered
  - App name "Days Since Tracker"
  - Simple, clean background
  - Match theme colors
- [ ] Implement using `flutter_native_splash` package:
  ```bash
  flutter pub add flutter_native_splash
  ```
- [ ] Configure in `pubspec.yaml`:
  ```yaml
  flutter_native_splash:
    color: "#2196F3"  # or your brand color
    image: assets/splash_logo.png
    android: true
    ios: true
  ```
- [ ] Generate splash screens:
  ```bash
  flutter pub run flutter_native_splash:create
  ```
- [ ] Test on device

**Expected Outcome**: Professional splash screen on app launch

---

### Priority 3: UI Polish & Refinements
**Goal**: Fine-tune UI based on testing experience

Tasks:
- [ ] Review and improve spacing/padding
- [ ] Ensure consistent color usage
- [ ] Check text sizes and readability
- [ ] Smooth out any animation jank
- [ ] Verify empty states are helpful
- [ ] Test edge cases:
  - Very long item names
  - Many items in list
  - Items with very high day counts
- [ ] Polish progress ring appearance
- [ ] Refine color picker UI

**Expected Outcome**: Pixel-perfect, polished UI

---

### Priority 4 (Stretch): Play Store Assets Preparation
**Goal**: Start preparing marketing materials

Tasks:
- [ ] Write app description (short and full)
- [ ] Create feature graphic (1024x500px)
- [ ] Take screenshots on device:
  - Home screen with items
  - Add item dialog
  - Settings screen
  - Dark and light mode examples
- [ ] Plan promotional content

**Expected Outcome**: Draft Play Store listing materials ready

---

## 🎨 Design Guidelines

### App Icon Ideas
- **Option 1**: Calendar page with number
- **Option 2**: Circular timer/stopwatch
- **Option 3**: Abstract arrows forming a cycle
- **Option 4**: Simple checkmark with date

### Color Scheme
- Light theme accent: #2196F3 (Blue)
- Dark theme accent: #9C27B0 (Purple)
- Keep icons simple and bold

### Splash Screen Timing
- Keep it brief (1-2 seconds max)
- Don't block app startup unnecessarily
- Should feel fast, not sluggish

---

## 📊 Success Metrics

By end of Day 3, you should have:
- ✅ Custom app icon designed and implemented
- ✅ Splash screen working
- ✅ UI refined and polished
- 🎯 (Stretch) Play Store assets drafted

---

## 🔧 Technical Commands

### Icon Generation
```bash
# If using flutter_launcher_icons package
flutter pub add flutter_launcher_icons

# Configure in pubspec.yaml then run:
flutter pub run flutter_launcher_icons:main
```

### Splash Screen
```bash
# Add package
flutter pub add flutter_native_splash

# Generate
flutter pub run flutter_native_splash:create

# Remove (if needed)
flutter pub run flutter_native_splash:remove
```

### Testing
```bash
# Run on device
flutter run

# Build release APK to test final appearance
flutter build apk --release

# Install release build
flutter install
```

---

## 📝 Commit Message Template

```
Add app icon, splash screen, and UI polish

- Design and implement custom app icon
- Add branded splash screen with flutter_native_splash
- Refine UI spacing, colors, and animations
- Polish progress ring and color picker
- Test edge cases and improve empty states
- Prepare for Play Store submission
```

---

## 🎯 Week 2 Goals (This Week)

According to master plan, Week 2 should focus on:
- ✅ App icon (doing today)
- ✅ Splash screen (doing today)
- Settings screen polish
- Local notifications testing
- Pre-set templates refinement
- Play Store preparation

You're right on track! 🚀

---

## 💡 Tips

- **Keep it simple**: Over-designed icons don't work at small sizes
- **Test on device**: Icons and splash screens look different on real devices
- **Get feedback**: Show the icon to someone before finalizing
- **Material guidelines**: Follow Android design principles

---

**Read AGENT-PROGRESS.md for full context**
**GitHub**: https://github.com/Rukhtam/days-since-tracker
