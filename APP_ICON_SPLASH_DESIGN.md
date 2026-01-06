# Days Since - App Icon & Splash Screen Design Specification

**Version:** 1.0
**Date:** January 1, 2026
**Designer:** Claude (Senior UI/UX Design Consultant)
**Target Platforms:** iOS 18+, Android 12+

---

## Design Philosophy

Following 2025-2026 minimalist design trends, the Days Since app icon uses **dynamic minimalism** - extremely simplified iconography with bold color contrast and essential forms. The design centers on a single, instantly recognizable element: a circular progress ring with a number, representing the core app function of tracking elapsed days.

**Key Principles:**
- Single main element (users recognize icons in under 1 second)
- Works at all sizes (512px down to 48px)
- Distinctive in both light and dark system contexts
- Scalable, memorable, and professional

---

## App Icon Design

### Concept: "Progress Counter"

The icon features a **bold number "7" inside a partial progress ring** on a dark circular background. This immediately communicates:
- **Counting/tracking** (the number)
- **Progress over time** (the ring)
- **Days elapsed** (contextual meaning)

The design is inspired by successful productivity apps like Streaks, Habitica, and Apple's Activity rings, but simplified to a single, bold element.

### Visual Specifications

#### Icon Dimensions
- **Master Icon:** 1024x1024px (iOS requirement)
- **Android Adaptive:** 432x432px safe zone within 512x512px canvas
- **Export all required sizes** (see Asset Requirements section)

#### Layout & Grid
```
Canvas: 1024x1024px
Outer circle diameter: 896px (leaves 64px margin on all sides)
Inner safe zone: 768px diameter (for Android adaptive masks)

Progress ring:
- Outer diameter: 720px
- Stroke width: 72px
- Center point: 512, 512 (canvas center)
- Arc: 270° (three-quarter circle, starting from top)

Number "7":
- Font: SF Pro Rounded (iOS) / Roboto Bold (Android) - use system default
- Font size: 420px
- Weight: Bold (700)
- Center-aligned in canvas
- Vertical position: 512px (perfectly centered)
```

#### Color Palette

**Light Mode Icon:**
```
Background circle: #1A1A1A (dark charcoal, not pure black)
Progress ring (active): #4CAF50 (primary green)
Progress ring (inactive/background): #2A2A2A (subtle dark grey)
Number "7": #FFFFFF (white)
```

**Dark Mode Icon (iOS 18):**
```
Background circle: #0A0A0A (deeper dark for OLED)
Progress ring (active): #5FD068 (slightly brighter green for contrast)
Progress ring (inactive): #1F1F1F
Number "7": #FFFFFF
```

**Tinted Icon (iOS 18):**
```
Export as grayscale with black background:
Background: #000000
All elements: Grayscale gradient #313131 (top) to #212121 (bottom)
This allows iOS to apply system tint colors
```

**Contrast Ratios:**
- White number on #1A1A1A background: 17.8:1 (exceeds WCAG AAA)
- Green ring on dark background: 6.2:1 (exceeds WCAG AA)

#### SVG Code (Master Icon - Light Mode)

```svg
<svg width="1024" height="1024" viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">
  <!-- Background Circle -->
  <circle cx="512" cy="512" r="448" fill="#1A1A1A"/>

  <!-- Progress Ring Background (inactive) -->
  <circle
    cx="512"
    cy="512"
    r="324"
    fill="none"
    stroke="#2A2A2A"
    stroke-width="72"
    stroke-linecap="round"
  />

  <!-- Progress Ring Active (270° arc = 75% progress) -->
  <circle
    cx="512"
    cy="512"
    r="324"
    fill="none"
    stroke="#4CAF50"
    stroke-width="72"
    stroke-linecap="round"
    stroke-dasharray="2035.75 679.25"
    transform="rotate(-90 512 512)"
  />

  <!-- Number "7" -->
  <text
    x="512"
    y="630"
    font-family="system-ui, -apple-system, sans-serif"
    font-size="420"
    font-weight="700"
    fill="#FFFFFF"
    text-anchor="middle"
  >7</text>
</svg>
```

**Mathematical Notes:**
- Circle circumference: 2πr = 2 × π × 324 = 2036px (approx)
- 270° = 75% of circle = 1527px active, 509px inactive
- Stroke-dasharray creates the gap for the inactive portion

---

## Splash Screen Design

### Concept: "Minimal Icon on Dark Canvas"

The splash screen follows Material Design 3 and iOS best practices for **quick, unobtrusive loading**. It features a centered, slightly scaled-down version of the app icon with subtle fade-in animation.

### Visual Specifications

#### Layout
```
Canvas: Device screen size (responsive)
Background: #121212 (matches app's dark theme)

Icon placement:
- Width/Height: 180dp (iOS) / 192dp (Android)
- Vertical position: Centered, offset -48dp from true center (slightly higher)
- Horizontal position: Centered

Optional tagline (if desired):
- Text: "Days Since"
- Font: SF Pro Display / Roboto Medium
- Size: 24sp
- Color: #FFFFFF with 60% opacity
- Position: 32dp below icon
```

#### Android 12+ Splash Screen (Adaptive)

Android 12 requires a specific splash screen format:

```xml
<!-- res/values/styles.xml -->
<style name="Theme.DaysSince.Splash" parent="Theme.SplashScreen">
    <item name="windowSplashScreenBackground">#121212</item>
    <item name="windowSplashScreenAnimatedIcon">@drawable/splash_icon</item>
    <item name="windowSplashScreenIconBackgroundColor">#1A1A1A</item>
    <item name="postSplashScreenTheme">@style/Theme.DaysSince</item>
</style>
```

**Splash Icon Asset:**
- Size: 960x960px (with 640px diameter safe zone)
- Format: Centered progress ring with "7" (same design as app icon)
- Background: Transparent (system applies windowSplashScreenIconBackgroundColor)

#### iOS Splash Screen (Storyboard)

iOS uses LaunchScreen.storyboard or static images:

```
Image size: 1242x2688px (@3x for iPhone)
Background: #121212
Icon: 540x540px centered
Format: PNG with transparency
```

### Animation Concept (Optional)

For enhanced user experience, consider a subtle animation:

**Android 12+ (Built-in):**
- System handles icon scale-up (0.85 to 1.0 over 150ms)
- Use `windowSplashScreenAnimationDuration` if needed

**iOS (Custom - implement in Flutter):**
- Fade in: Opacity 0 to 1 over 200ms
- Scale: 0.92 to 1.0 over 200ms with ease-out curve
- Start animation immediately on load
- Total duration: 200-300ms (keep it quick!)

**CRITICAL:** Splash screens should be SHORT (under 1 second). Don't add unnecessary delays.

---

## Asset Requirements

### iOS Assets

Generate all required sizes for Assets.xcassets:

| Size | Purpose | Filename |
|------|---------|----------|
| 1024x1024px | App Store | icon_1024.png |
| 180x180px | iPhone @3x | icon_180.png |
| 120x120px | iPhone @2x | icon_120.png |
| 167x167px | iPad Pro @2x | icon_167.png |
| 152x152px | iPad @2x | icon_152.png |
| 76x76px | iPad @1x | icon_76.png |

**iOS 18 Variants:**
- Export separate Dark Mode and Tinted versions of each size
- Use Asset Catalog Appearances: "Any, Light, Dark"
- Tinted icons: Grayscale with transparent background

**Launch Screen:**
- 1242x2688px (iPhone 13 Pro Max)
- 1125x2436px (iPhone 13 Pro)
- 828x1792px (iPhone 11)

### Android Assets

Generate adaptive icon layers:

| Layer | Size | Purpose |
|-------|------|---------|
| Foreground | 432x432px in 512x512px canvas | Progress ring + number |
| Background | 512x512px solid | #1A1A1A fill |
| Monochrome | 432x432px in 512x512px canvas | For themed icons |

**Density Variants (optional):**
- mdpi: 48x48px
- hdpi: 72x72px
- xhdpi: 96x96px
- xxhdpi: 144x144px
- xxxhdpi: 192x192px

**Splash Screen (Android 12+):**
- Icon: 960x960px (640px safe zone)
- Background: Define in styles.xml

---

## Implementation Guide for Flutter Developer

### Step 1: Generate Assets

**Option A - Manual (using design specs above):**
1. Use Figma, Sketch, or Adobe XD to create the icon from SVG specs
2. Export at all required sizes
3. Use online tools like [AppIcon.co](https://appicon.co/) for bulk resizing

**Option B - Automated (recommended):**
1. Create master 1024x1024px PNG from SVG
2. Use `flutter_launcher_icons` package:

```yaml
# pubspec.yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon.png"
  adaptive_icon_foreground: "assets/icon/foreground.png"
  adaptive_icon_background: "#1A1A1A"
  remove_alpha_ios: true
```

Run: `flutter pub run flutter_launcher_icons`

### Step 2: Implement Splash Screen

**Use flutter_native_splash package:**

```yaml
# pubspec.yaml
dev_dependencies:
  flutter_native_splash: ^2.3.10

flutter_native_splash:
  color: "#121212"
  image: "assets/splash/splash_icon.png"
  android_12:
    image: "assets/splash/android12_splash.png"
    icon_background_color: "#1A1A1A"
  ios_content_mode: "center"
```

Run: `flutter pub run flutter_native_splash:create`

### Step 3: Test on Devices

**Critical checks:**
- Icon visibility on light AND dark home screens
- Icon clarity at smallest size (48x48dp)
- Splash screen doesn't flicker or delay
- Colors match app theme exactly
- No pixelation or artifacts

**Testing devices:**
- iOS: iPhone with iOS 18 (test dark mode icons)
- Android: Pixel with Android 12+ (test adaptive icon)
- Both: Try different wallpapers (light/dark/colorful)

---

## Design Rationale

### Why This Design Works

**1. Instant Recognition (< 1 second):**
- Single main element (progress ring + number)
- No competing visual elements
- Bold, simple shapes

**2. Scalability:**
- Thick stroke width (72px) remains visible at 48px
- Large number maintains legibility when scaled down
- No fine details that get lost

**3. Brand Alignment:**
- Dark background matches app's #121212 theme
- Green accent color (#4CAF50) is primary brand color
- Progress ring directly relates to app's core UI

**4. Platform Optimization:**
- Dark mode variant for iOS 18 OLED displays
- Adaptive layers for Android Material You theming
- Contrast ratios exceed WCAG AAA standards

**5. Competitive Differentiation:**
- Most tracking apps use calendar or list icons
- Progress ring + number is unique in this category
- Modern, premium aesthetic stands out in app stores

### Real-World References

**Similar successful approaches:**
- **Streaks (iOS):** Uses simple colored circles for habit tracking
- **Apple Activity Rings:** Three-ring progress system, instantly recognizable
- **Habitica:** Game-style progress indicators with bold numbers
- **Notion:** Single letter icon with subtle background

---

## Alternative Design Concepts (For Future Consideration)

### Concept 2: "Calendar Flip"
- Stylized calendar page with large number
- Minimalist tear-off page effect
- More literal interpretation of "days"

### Concept 3: "Tick Mark Counter"
- Abstract tally marks or tick marks
- Represents counting/tracking
- Very minimal, possibly too abstract

**Recommendation:** Stick with Progress Counter (Concept 1) for launch. It best balances memorability, clarity, and brand alignment.

---

## Color Accessibility Matrix

Ensuring visibility across all contexts:

| Element | Background | Contrast Ratio | WCAG Level |
|---------|-----------|----------------|------------|
| White number (#FFFFFF) | Dark bg (#1A1A1A) | 17.8:1 | AAA |
| Green ring (#4CAF50) | Dark bg (#1A1A1A) | 6.2:1 | AA |
| Dark icon (#1A1A1A) | iOS light wallpaper (#FFFFFF) | 17.8:1 | AAA |
| Dark icon (#1A1A1A) | Typical colored wallpaper | 4.5:1+ | AA |

---

## Next Steps

### Immediate Actions (1-2 hours):

1. **Create master icon from SVG specs** (use Figma, Sketch, or online SVG editor)
2. **Export 1024x1024px PNG** at maximum quality
3. **Set up flutter_launcher_icons and flutter_native_splash** in pubspec.yaml
4. **Generate all platform assets** using the packages
5. **Test on at least one iOS and one Android device**

### Asset Checklist:

- [ ] Master icon 1024x1024px (light mode)
- [ ] Dark mode variant 1024x1024px (iOS 18)
- [ ] Tinted variant 1024x1024px (iOS 18)
- [ ] Android adaptive foreground layer 512x512px
- [ ] Android adaptive background (solid #1A1A1A)
- [ ] Splash screen icon 960x960px (Android 12)
- [ ] Splash screen icon 540x540px (iOS)
- [ ] All sizes generated via flutter_launcher_icons

### Future Enhancements:

- A/B test icon variations in limited TestFlight/beta release
- Consider seasonal icon variants (iOS supports this)
- Monitor app store analytics for icon click-through rate
- User feedback on icon recognition and appeal

---

## Technical Notes for Developer

### Common Pitfalls to Avoid:

1. **Don't use pure black (#000000)** for backgrounds - use #1A1A1A or #121212 for better OLED performance and reduced eye strain
2. **Don't add text or complex details** - they become illegible at small sizes
3. **Don't forget iOS 18 dark mode icons** - required for optimal appearance in iOS 18+
4. **Don't skip testing on actual devices** - simulator colors differ from physical screens
5. **Don't make splash screen too long** - users hate waiting, keep it under 1 second

### Package Versions (as of January 2026):

- flutter_launcher_icons: ^0.13.1
- flutter_native_splash: ^2.3.10

Check for updates: `flutter pub outdated`

### File Paths in Flutter Project:

```
your_project/
  assets/
    icon/
      app_icon.png (1024x1024px master)
      foreground.png (512x512px adaptive layer)
    splash/
      splash_icon.png (960x960px Android 12)
      ios_splash.png (1242x2688px iOS)
  android/
    app/src/main/res/
      mipmap-*/ (generated by flutter_launcher_icons)
      drawable/ (generated by flutter_native_splash)
  ios/
    Runner/Assets.xcassets/
      AppIcon.appiconset/ (generated by flutter_launcher_icons)
      LaunchImage.imageset/ (generated by flutter_native_splash)
```

---

## Estimated Implementation Time

- **Icon creation from specs:** 30-45 minutes (if using design tools)
- **Asset generation with Flutter packages:** 10-15 minutes
- **Testing and refinement:** 15-30 minutes
- **Total:** 1-1.5 hours

This is a **high-impact, low-effort task** that significantly improves app polish and professional appearance.

---

## Success Metrics

After launch, monitor:

- **App Store CTR:** Icon click-through rate from search results
- **User feedback:** Mentions of app appearance in reviews
- **Brand recognition:** Ability to identify app on crowded home screens
- **Platform compliance:** No rejection issues related to icon assets

Target: Professional, memorable icon that requires zero revisions during app store submission.

---

## Contact & Credits

**Design Research Sources:**
- [ASOMobile: App Icon Trends 2025](https://asomobile.net/en/blog/app-icon-trends-and-best-practices-2025/)
- [MobileAction: App Icon Guide 2026](https://www.mobileaction.co/guide/app-icon-guide/)
- [CreateWithSwift: Dark Mode App Icons](https://www.createwithswift.com/preparing-your-app-icon-for-dark-and-tinted-appearance/)
- [Flutter Documentation: Android Splash Screen](https://docs.flutter.dev/platform-integration/android/splash-screen)

**Design Inspiration:**
- Apple Activity Rings
- Streaks (iOS habit tracker)
- Notion (minimalist icon design)

**Design Consultant:** Claude (Anthropic)
**Date:** January 1, 2026

---

## Appendix: SVG Templates

### Dark Mode Variant (iOS 18)

```svg
<svg width="1024" height="1024" viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">
  <circle cx="512" cy="512" r="448" fill="#0A0A0A"/>
  <circle cx="512" cy="512" r="324" fill="none" stroke="#1F1F1F" stroke-width="72" stroke-linecap="round"/>
  <circle cx="512" cy="512" r="324" fill="none" stroke="#5FD068" stroke-width="72" stroke-linecap="round" stroke-dasharray="2035.75 679.25" transform="rotate(-90 512 512)"/>
  <text x="512" y="630" font-family="system-ui" font-size="420" font-weight="700" fill="#FFFFFF" text-anchor="middle">7</text>
</svg>
```

### Tinted Variant (iOS 18)

```svg
<svg width="1024" height="1024" viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="tintGradient" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" style="stop-color:#313131;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#212121;stop-opacity:1" />
    </linearGradient>
  </defs>
  <circle cx="512" cy="512" r="448" fill="#000000"/>
  <circle cx="512" cy="512" r="324" fill="none" stroke="url(#tintGradient)" stroke-width="72" stroke-linecap="round" stroke-dasharray="2035.75 679.25" transform="rotate(-90 512 512)"/>
  <text x="512" y="630" font-family="system-ui" font-size="420" font-weight="700" fill="url(#tintGradient)" text-anchor="middle">7</text>
</svg>
```

### Android Adaptive Foreground Layer

```svg
<svg width="512" height="512" viewBox="0 0 512 512" xmlns="http://www.w3.org/2000/svg">
  <!-- Center safe zone: 432x432 -->
  <!-- Progress ring scaled to fit -->
  <circle cx="256" cy="256" r="162" fill="none" stroke="#2A2A2A" stroke-width="36" stroke-linecap="round"/>
  <circle cx="256" cy="256" r="162" fill="none" stroke="#4CAF50" stroke-width="36" stroke-linecap="round" stroke-dasharray="1017.88 339.29" transform="rotate(-90 256 256)"/>
  <text x="256" y="315" font-family="system-ui" font-size="210" font-weight="700" fill="#FFFFFF" text-anchor="middle">7</text>
</svg>
```

---

**END OF DESIGN SPECIFICATION**
