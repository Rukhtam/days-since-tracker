# Bug Fix Release Guide

A checklist to follow after completing any bug fix or feature implementation.

---

## Pre-Release Checklist

### 1. Bump App Version

Update `pubspec.yaml` with the new version:

```yaml
# Format: major.minor.patch+buildNumber
version: 1.0.11+12
```

| Component | When to Increment |
|-----------|-------------------|
| **major** | Breaking changes, major redesign |
| **minor** | New features, significant improvements |
| **patch** | Bug fixes, small improvements |
| **buildNumber** | Always increment (Play Store requires unique build numbers) |

**File:** `days_since_app/pubspec.yaml`

---

### 2. Build AAB Release Bundle

```bash
cd /Users/rukhtamamin/claude-main/claude-app/days_since_app
flutter build appbundle --release
```

**Expected output location:**
```
build/app/outputs/bundle/release/app-release.aab
```

> ⚠️ **Note:** You may see a warning about "failed to strip debug symbols" — this is a known Flutter issue and does not affect the release. Always verify the AAB file exists in the output directory.

**Verify build:**
```bash
ls -la build/app/outputs/bundle/release/
```

---

### 3. Commit and Push Changes

```bash
cd /Users/rukhtamamin/claude-main/claude-app
git add -A
git commit -m "v1.0.X: Brief description

🐛 Bug Fixes:
- Fix description here

🛡️ Improvements:
- Improvement description here

✨ Features:
- Feature description here

📦 Build:
- Bump version to 1.0.X+Y"

git push
```

**Commit message icons:**
| Icon | Category |
|------|----------|
| 🐛 | Bug Fixes |
| ✨ | New Features |
| 🛡️ | Error Handling / Security |
| ⚡ | Performance |
| 🎨 | UI/UX Changes |
| 📦 | Build / Dependencies |
| 🔧 | Configuration |
| 📝 | Documentation |

---

### 4. Create Play Store Release Notes

**Format for "What's New" section:**

```
What's New

🔔 [Feature Name]
Brief user-friendly description of the feature.

🐛 Bug Fixes
- Fixed [issue description in user terms]
- Improved [area of improvement]

⚡ Under the Hood
- Technical improvements (optional, keep brief)
```

**Short version (for limited character count):**
```
Fixed [main bug]. Added [main feature]. Improved app stability.
```

---

## Quick Reference Commands

```bash
# Navigate to project
cd /Users/rukhtamamin/claude-main/claude-app/days_since_app

# Build release AAB
flutter build appbundle --release

# Check AAB was created
ls -la build/app/outputs/bundle/release/

# Commit and push (from claude-app directory)
cd ..
git add -A && git commit -m "v1.0.X: Description" && git push
```

---

## Troubleshooting

### Build fails completely
```bash
flutter clean
flutter pub get
flutter build appbundle --release
```

### Debug symbols warning
This warning can be ignored:
```
Release app bundle failed to strip debug symbols from native libraries.
```
The AAB is still valid for Play Store upload.

### Git push fails
```bash
git pull --rebase
git push
```

---

## Play Store Upload

1. Go to [Google Play Console](https://play.google.com/console)
2. Select **Days Since Tracker**
3. Navigate to **Release** → **Testing** → **Closed testing**
4. Click **Create new release**
5. Upload `app-release.aab`
6. Add release notes
7. **Review and roll out**

---

*Last updated: January 18, 2026*
