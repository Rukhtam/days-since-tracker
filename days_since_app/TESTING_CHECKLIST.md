# Days Since Tracker - Testing Checklist

Use this checklist to verify all app functionality before release.

## Test Environment Setup
- [ ] Install release APK on test device
- [ ] Clear app data before testing
- [ ] Test on Android 7.0+ (API 24+)
- [ ] Test on at least 2 different screen sizes

---

## 1. First Launch Experience

### Initial State
- [ ] App opens without crash
- [ ] Empty state message is displayed
- [ ] "Add your first tracker" button is visible
- [ ] FAB (floating action button) is visible
- [ ] Settings icon is visible in app bar

### Notification Permission
- [ ] Permission dialog appears on first launch
- [ ] Granting permission works correctly
- [ ] Denying permission doesn't crash the app
- [ ] App functions correctly without notification permission

---

## 2. Create (Add) Operations

### Add via FAB
- [ ] Tap FAB opens add dialog
- [ ] Dialog slides up smoothly
- [ ] Name field is focused
- [ ] Keyboard appears automatically

### Add Dialog Fields
- [ ] Name field accepts text input
- [ ] Name field has character limit (if any)
- [ ] Interval field defaults to reasonable value
- [ ] Interval field only accepts positive numbers
- [ ] Icon picker displays available icons
- [ ] Selecting icon updates preview
- [ ] Color picker displays available colors
- [ ] Selecting color updates preview
- [ ] Notifications toggle works
- [ ] "Reset date" picker works (optional field)

### Template Quick-Add
- [ ] Template button is visible
- [ ] Tap opens template selection
- [ ] Each template has icon, name, interval
- [ ] Selecting template fills form fields
- [ ] Can modify template values before saving

### Saving New Item
- [ ] Save button creates item
- [ ] Item appears in list immediately
- [ ] Haptic feedback on save (if enabled)
- [ ] Dialog closes after save
- [ ] Item has correct initial values

### Validation
- [ ] Empty name shows error
- [ ] Zero/negative interval shows error
- [ ] Cancel button closes dialog without saving
- [ ] Swiping down closes dialog without saving

---

## 3. Read (Display) Operations

### Home Screen List
- [ ] Items display correctly in cards
- [ ] Each card shows progress ring
- [ ] Each card shows day count
- [ ] Each card shows item name
- [ ] Each card shows item icon with correct color
- [ ] Each card shows status text
- [ ] Each card shows interval info
- [ ] Each card shows reset button

### Progress Ring
- [ ] Ring shows correct percentage
- [ ] Ring color matches status (green/yellow/red)
- [ ] Ring animates on load (if applicable)
- [ ] Day number is readable inside ring

### Status Colors
- [ ] < 70%: Green (#4CAF50)
- [ ] 70-100%: Yellow (#FFC107)
- [ ] > 100%: Red (#F44336)

### Status Text
- [ ] Green: "X days remaining"
- [ ] Yellow: "Due in X days" or "Due today"
- [ ] Red: "X days overdue"

### App Bar Stats
- [ ] Status badges show in app bar
- [ ] Red count shows overdue items
- [ ] Yellow count shows warning items
- [ ] Green count shows good items
- [ ] Badges update when items change

### Sorting
- [ ] Default sort by status works
- [ ] Sort by days works
- [ ] Sort by name works
- [ ] Sort by recent works
- [ ] Sort preference persists

### Refresh
- [ ] Pull-to-refresh updates data
- [ ] Day counts update after midnight

---

## 4. Update (Edit) Operations

### Opening Edit Dialog
- [ ] Tap on card opens edit dialog
- [ ] Dialog pre-fills with current values
- [ ] All fields are editable

### Editing Fields
- [ ] Can change name
- [ ] Can change interval
- [ ] Can change icon
- [ ] Can change color
- [ ] Can toggle notifications
- [ ] Can change reset date

### Saving Edits
- [ ] Save updates item in list
- [ ] Changes reflect immediately
- [ ] Notification schedule updates

### Cancel Editing
- [ ] Cancel button discards changes
- [ ] Swiping down discards changes
- [ ] Original values remain unchanged

---

## 5. Delete Operations

### Long-Press Menu
- [ ] Long-press shows options menu
- [ ] Menu has handle bar at top
- [ ] Shows item icon and name
- [ ] Shows "Reset to today" option
- [ ] Shows "Edit item" option
- [ ] Shows "Delete item" option (red)
- [ ] Haptic feedback on long-press

### Delete Confirmation
- [ ] Delete option shows confirmation dialog
- [ ] Dialog shows item name
- [ ] Cancel button works
- [ ] Confirm delete removes item
- [ ] Snackbar confirms deletion
- [ ] Item removed from list immediately
- [ ] Notifications cancelled for deleted item

---

## 6. Reset Operations

### Reset Button (on card)
- [ ] Tap reset icon resets item
- [ ] Haptic feedback on reset
- [ ] Day count goes to 0
- [ ] Progress ring resets to empty
- [ ] Status changes to green
- [ ] Snackbar shows confirmation

### Undo Reset
- [ ] Snackbar has "Undo" button
- [ ] Undo restores previous date
- [ ] All values restore correctly

### Reset from Menu
- [ ] Long-press menu reset works
- [ ] Same behavior as reset button

---

## 7. Data Persistence

### App Restart
- [ ] Close app completely
- [ ] Reopen app
- [ ] All items are present
- [ ] All values are correct
- [ ] Sort order is preserved

### Device Restart
- [ ] Restart device
- [ ] Open app
- [ ] All data intact

### Settings Persistence
- [ ] Notifications enabled/disabled persists
- [ ] Sort order persists
- [ ] Haptic feedback setting persists
- [ ] First launch flag persists

---

## 8. Notifications

### Permission
- [ ] Can enable/disable in settings
- [ ] Per-item toggle works

### Scheduling
- [ ] Notification scheduled at 90% of interval
- [ ] Correct notification appears at scheduled time
- [ ] Notification shows item name
- [ ] Notification shows relevant message

### Interaction
- [ ] Tapping notification opens app
- [ ] Notification dismissed after tap

### After Reset
- [ ] New notification scheduled after reset
- [ ] Old notification cancelled

---

## 9. Settings Screen

### Access
- [ ] Settings icon opens settings screen
- [ ] Back navigation works

### Notification Settings
- [ ] Master toggle for notifications
- [ ] Toggle reflects current state
- [ ] Changes apply immediately

### Sort Order
- [ ] Sort order option is visible
- [ ] Can change sort order
- [ ] Change applies to home screen

### Haptic Feedback
- [ ] Toggle is present
- [ ] Toggle reflects current state
- [ ] Enabling/disabling works

### About Section (if present)
- [ ] Version number displays
- [ ] Any links work

---

## 10. Edge Cases

### Large Numbers
- [ ] 1000+ days displays correctly
- [ ] Progress > 200% handles gracefully

### Long Names
- [ ] Long item names truncate with ellipsis
- [ ] UI doesn't break with long names

### Many Items
- [ ] 50+ items scroll smoothly
- [ ] No performance issues

### Dates
- [ ] Future reset dates handled (shows negative days)
- [ ] Timezone changes don't break calculations
- [ ] Daylight saving transitions work

### Empty States
- [ ] Deleting last item shows empty state
- [ ] Empty state prompts adding item

---

## 11. UI/UX Quality

### Animations
- [ ] Dialog slide-up is smooth
- [ ] Progress ring animations smooth
- [ ] List animations (if any) are smooth

### Haptic Feedback
- [ ] FAB tap has feedback
- [ ] Reset has feedback
- [ ] Long-press has feedback
- [ ] Save has feedback

### Dark Theme
- [ ] All text is readable
- [ ] No contrast issues
- [ ] Colors are consistent

### Touch Targets
- [ ] All buttons are easily tappable
- [ ] No accidental taps on adjacent elements

### Keyboard
- [ ] Keyboard doesn't obscure inputs
- [ ] Keyboard dismisses appropriately

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

| Category | Pass | Fail | Notes |
|----------|------|------|-------|
| First Launch | | | |
| Create | | | |
| Read | | | |
| Update | | | |
| Delete | | | |
| Reset | | | |
| Persistence | | | |
| Notifications | | | |
| Settings | | | |
| Edge Cases | | | |
| UI/UX | | | |
| Performance | | | |

---

## Sign-off

**Tested By:** _______________
**Date:** _______________
**Device(s):** _______________
**Android Version(s):** _______________
**APK Version:** _______________

**Ready for Release:** [ ] Yes [ ] No (list blockers below)

**Notes/Issues Found:**

---
