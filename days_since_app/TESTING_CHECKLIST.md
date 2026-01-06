# Days Since Tracker - Testing Checklist

Use this checklist to verify all app functionality before release.

## Test Environment Setup
- [x] Install release APK on test device
- [x] Clear app data before testing
- [x] Test on Android 7.0+ (API 24+)
- [x] Test on at least 2 different screen sizes

---

## 1. First Launch Experience

### Initial State
- [x] App opens without crash
- [x] Empty state message is displayed
- [x] "Add your first tracker" button is visible
- [x] FAB (floating action button) is visible
- [x] Settings icon is visible in app bar

### Notification Permission
- [x] Permission dialog appears on first launch
- [x] Granting permission works correctly
- [x] Denying permission doesn't crash the app
- [x] App functions correctly without notification permission

---

## 2. Create (Add) Operations

### Add via FAB
- [x] Tap FAB opens add dialog
- [x] Dialog slides up smoothly
- [x] Name field is focused
- [x] Keyboard appears automatically

### Add Dialog Fields
- [x] Name field accepts text input
- [x] Name field has character limit (if any)
- [x] Interval field defaults to reasonable value
- [x] Interval field only accepts positive numbers
- [x] Icon picker displays available icons
- [x] Selecting icon updates preview
- [x] Color picker displays available colors
- [x] Selecting color updates preview
- [x] Notifications toggle works
- [x] "Reset date" picker works (optional field)

### Template Quick-Add
- [x] Template button is visible
- [x] Tap opens template selection
- [x] Each template has icon, name, interval
- [x] Selecting template fills form fields
- [x] Can modify template values before saving

### Saving New Item
- [x] Save button creates item
- [x] Item appears in list immediately
- [x] Haptic feedback on save (if enabled)
- [x] Dialog closes after save
- [x] Item has correct initial values

### Validation
- [x] Empty name shows error
- [x] Zero/negative interval shows error
- [x] Cancel button closes dialog without saving
- [x] Swiping down closes dialog without saving

---

## 3. Read (Display) Operations

### Home Screen List
- [x] Items display correctly in cards
- [x] Each card shows progress ring
- [x] Each card shows day count
- [x] Each card shows item name
- [x] Each card shows item icon with correct color
- [x] Each card shows status text
- [x] Each card shows interval info
- [x] Each card shows reset button

### Progress Ring
- [x] Ring shows correct percentage
- [x] Ring color matches status (green/yellow/red)
- [x] Ring animates on load (if applicable)
- [x] Day number is readable inside ring

### Status Colors
- [x] < 70%: Green (#4CAF50)
- [x] 70-100%: Yellow (#FFC107)
- [x] > 100%: Red (#F44336)

### Status Text
- [x] Green: "X days remaining"
- [x] Yellow: "Due in X days" or "Due today"
- [x] Red: "X days overdue"

### App Bar Stats
- [x] Status badges show in app bar
- [x] Red count shows overdue items
- [x] Yellow count shows warning items
- [x] Green count shows good items
- [x] Badges update when items change

### Sorting
- [x] Default sort by status works
- [x] Sort by days works
- [x] Sort by name works
- [x] Sort by recent works
- [x] Sort preference persists

### Refresh
- [x] Pull-to-refresh updates data
- [x] Day counts update after midnight

---

## 4. Update (Edit) Operations

### Opening Edit Dialog
- [x] Tap on card opens edit dialog
- [x] Dialog pre-fills with current values
- [x] All fields are editable

### Editing Fields
- [x] Can change name
- [x] Can change interval
- [x] Can change icon
- [x] Can change color
- [x] Can toggle notifications
- [x] Can change reset date

### Saving Edits
- [x] Save updates item in list
- [x] Changes reflect immediately
- [x] Notification schedule updates

### Cancel Editing
- [x] Cancel button discards changes
- [x] Swiping down discards changes
- [x] Original values remain unchanged

---

## 5. Delete Operations

### Long-Press Menu
- [x] Long-press shows options menu
- [x] Menu has handle bar at top
- [x] Shows item icon and name
- [x] Shows "Reset to today" option
- [x] Shows "Edit item" option
- [x] Shows "Delete item" option (red)
- [x] Haptic feedback on long-press

### Delete Confirmation
- [x] Delete option shows confirmation dialog
- [x] Dialog shows item name
- [x] Cancel button works
- [x] Confirm delete removes item
- [x] Snackbar confirms deletion
- [x] Item removed from list immediately
- [x] Notifications cancelled for deleted item

---

## 6. Reset Operations

### Reset Button (on card)
- [x] Tap reset icon resets item
- [x] Haptic feedback on reset
- [x] Day count goes to 0
- [x] Progress ring resets to empty
- [x] Status changes to green
- [x] Snackbar shows confirmation

### Undo Reset
- [x] Snackbar has "Undo" button
- [x] Undo restores previous date
- [x] All values restore correctly

### Reset from Menu
- [x] Long-press menu reset works
- [x] Same behavior as reset button

---

## 7. Data Persistence

### App Restart
- [x] Close app completely
- [x] Reopen app
- [x] All items are present
- [x] All values are correct
- [x] Sort order is preserved

### Device Restart
- [x] Restart device
- [x] Open app
- [x] All data intact

### Settings Persistence
- [x] Notifications enabled/disabled persists
- [x] Sort order persists
- [x] Haptic feedback setting persists
- [x] First launch flag persists

---

## 8. Notifications

### Permission
- [x] Can enable/disable in settings
- [x] Per-item toggle works

### Scheduling
- [x] Notification scheduled at 90% of interval
- [x] Correct notification appears at scheduled time
- [x] Notification shows item name
- [x] Notification shows relevant message

### Interaction
- [x] Tapping notification opens app
- [x] Notification dismissed after tap

### After Reset
- [x] New notification scheduled after reset
- [x] Old notification cancelled

---

## 9. Settings Screen

### Access
- [x] Settings icon opens settings screen
- [x] Back navigation works

### Notification Settings
- [x] Master toggle for notifications
- [x] Toggle reflects current state
- [x] Changes apply immediately

### Sort Order
- [x] Sort order option is visible
- [x] Can change sort order
- [x] Change applies to home screen

### Haptic Feedback
- [x] Toggle is present
- [ ] Toggle reflects current state
- [ ] Enabling/disabling works

### About Section (if present)
- [x] Version number displays
- [x] Any links work

---

## 10. Edge Cases

### Large Numbers
- [x] 1000+ days displays correctly
- [x] Progress > 200% handles gracefully

### Long Names
- [x] Long item names truncate with ellipsis
- [x] UI doesn't break with long names

### Many Items
- [x] 50+ items scroll smoothly
- [x] No performance issues

### Dates
- [x] Future reset dates handled (shows negative days)
- [x] Timezone changes don't break calculations
- [x] Daylight saving transitions work

### Empty States
- [x] Deleting last item shows empty state
- [x] Empty state prompts adding item

---

## 11. UI/UX Quality

### Animations
- [x] Dialog slide-up is smooth
- [x] Progress ring animations smooth
- [x] List animations (if any) are smooth

### Haptic Feedback
- [x] FAB tap has feedback
- [x] Reset has feedback
- [x] Long-press has feedback
- [x] Save has feedback

### Dark Theme
- [x] All text is readable
- [x] No contrast issues
- [x] Colors are consistent

### Touch Targets
- [x] All buttons are easily tappable
- [x] No accidental taps on adjacent elements

### Keyboard
- [x] Keyboard doesn't obscure inputs
- [x] Keyboard dismisses appropriately

---

## 12. Performance

### Startup Time
- [ ] Cold start < 3 seconds
- [ ] Warm start < 1 second

### Memory
- [ ] No memory leaks (test with repeated add/delete)
- [ ] Memory usage stays reasonable

### Battery
- [ ] No excessive background activity
- [ ] Notifications don't drain battery

### APK Size
- [ ] Release APK < 30MB (ideally < 20MB)

---

## 13. Accessibility (Optional but Recommended)

### Screen Reader
- [ ] TalkBack can read all elements
- [ ] Semantic labels are meaningful

### Text Scaling
- [ ] UI works with large text setting
- [ ] No text overflow

### Touch Target
- [ ] All targets at least 48dp

---

## Test Results Summary

| Category      | Pass | Fail | Notes |
| ------------- | ---- | ---- | ----- |
| First Launch  |      |      |       |
| Create        |      |      |       |
| Read          |      |      |       |
| Update        |      |      |       |
| Delete        |      |      |       |
| Reset         |      |      |       |
| Persistence   |      |      |       |
| Notifications |      |      |       |
| Settings      |      |      |       |
| Edge Cases    |      |      |       |
| UI/UX         |      |      |       |
| Performance   |      |      |       |

---

## Sign-off

**Tested By:** _______________Rukhtam Amin
**Date:** _______________06-Jan-2026
**Device(s):** _______________A52s
**Android Version(s):** _______________14
**APK Version:** _______________1.0

**Ready for Release:** [x] Yes [ ] No (list blockers below)

**Notes/Issues Found:**

---
