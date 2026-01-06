import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../models/tracked_item.dart';
import '../providers/tracked_items_provider.dart';
import '../providers/settings_provider.dart';
import '../services/haptic_service.dart';
import '../utils/icon_utils.dart';
import '../utils/milestone_utils.dart';
import 'edit_item_dialog.dart';

/// Modern event card with soft UI design, circular progress indicator,
/// and animated interactions.
class ModernEventCard extends StatefulWidget {
  final TrackedItem item;
  final int index; // Index in the list for staggered animation
  final bool startupComplete; // Whether app startup is complete

  const ModernEventCard({
    super.key,
    required this.item,
    this.index = 0,
    this.startupComplete = false,
  });

  @override
  State<ModernEventCard> createState() => _ModernEventCardState();
}

class _ModernEventCardState extends State<ModernEventCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _percentAnimation;
  bool _hasTriggeredAnimation = false;
  double _targetPercent = 0.0;
  bool _animationsDisabled = false;

  @override
  void initState() {
    super.initState();
    _targetPercent = (widget.item.percentageElapsed / 100).clamp(0.0, 1.0);

    _animController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Start with ring at 0% - will animate to target after startup completes
    _percentAnimation = const AlwaysStoppedAnimation(0.0);

    if (widget.startupComplete) {
      // If startup already complete, show final value immediately
      _percentAnimation = AlwaysStoppedAnimation(_targetPercent);
      _hasTriggeredAnimation = true;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Respect system animation preferences (accessibility)
    _animationsDisabled = MediaQuery.of(context).disableAnimations;
  }

  @override
  void didUpdateWidget(ModernEventCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // When startup completes, trigger staggered animation
    if (widget.startupComplete && !_hasTriggeredAnimation) {
      _hasTriggeredAnimation = true;

      // Skip animation if system animations are disabled (accessibility)
      if (_animationsDisabled) {
        return;
      }

      // Animate from 0 to target with staggered delay
      // Each card delays by 60ms based on index (max 300ms) for waterfall effect
      final delayMs = (widget.index * 60).clamp(0, 300);
      _percentAnimation = Tween<double>(begin: 0.0, end: _targetPercent)
          .animate(
            CurvedAnimation(
              parent: _animController,
              curve: Curves.easeOutCubic,
            ),
          );

      Future.delayed(Duration(milliseconds: delayMs), () {
        if (mounted) {
          _animController.forward();
        }
      });
    }

    // Update target if item data changed (e.g., after reset)
    if (oldWidget.item.percentageElapsed != widget.item.percentageElapsed) {
      final newTarget = (widget.item.percentageElapsed / 100).clamp(0.0, 1.0);
      if (_hasTriggeredAnimation && !_animationsDisabled) {
        // Animate to new value
        _percentAnimation = Tween<double>(begin: _targetPercent, end: newTarget)
            .animate(
              CurvedAnimation(
                parent: _animController,
                curve: Curves.easeOutCubic,
              ),
            );
        _animController.forward(from: 0);
      } else {
        // No animation - just update to new value
        _percentAnimation = AlwaysStoppedAnimation(newTarget);
      }
      _targetPercent = newTarget;
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final settings = context.watch<SettingsProvider>();
    final isDarkMode =
        settings.flutterThemeMode == ThemeMode.dark ||
        (settings.flutterThemeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    // Dynamic colors based on theme
    final bgColor = isDarkMode
        ? const Color(0xFF1E293B)
        : const Color(0xFFFFFFFF);
    final titleColor = isDarkMode
        ? const Color(0xFFF8FAFC)
        : const Color(0xFF1E293B);
    final subColor = isDarkMode
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    // Soft shadow for depth
    final shadow = isDarkMode
        ? BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        : BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          );

    // Get status color and item accent color
    final statusColor = AppColors.fromHex(item.statusColor);
    final itemColor = AppColors.fromHex(item.color);

    return GestureDetector(
      onTap: () => _showEditDialog(context),
      onLongPress: () => _showOptionsMenu(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24), // Squircle shape
          boxShadow: [shadow],
        ),
        child: Row(
          children: [
            // --- Circular Progress Indicator with smooth animation ---
            AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                return CircularPercentIndicator(
                  radius: 42.0,
                  lineWidth: 8.0,
                  percent: _percentAnimation.value,
                  circularStrokeCap: CircularStrokeCap.round,
                  center: child,
                  backgroundColor: isDarkMode
                      ? Colors.white10
                      : const Color(0xFFF1F5F9),
                  progressColor: statusColor,
                  animation: false, // We handle animation ourselves
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.daysSinceReset.toString(),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                      color: titleColor,
                    ),
                  ),
                  Text(
                    item.daysSinceReset == 1 ? "day" : "days",
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: subColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 20),

            // --- Text & Icon Info ---
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Icon Container (Squircle)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: itemColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          IconUtils.getIconData(item.iconName),
                          size: 18,
                          color: itemColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Title
                      Expanded(
                        child: Text(
                          item.name,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: titleColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Status Text
                  Text(
                    _getStatusText(),
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // --- Action Button (Reset) ---
            IconButton(
              icon: Icon(
                Icons.refresh_rounded,
                color: subColor.withValues(alpha: 0.6),
              ),
              onPressed: () => _resetItem(context),
              tooltip: 'Reset to today',
            ),
          ],
        ),
      ),
    );
  }

  /// Get status text based on item state
  String _getStatusText() {
    switch (widget.item.status) {
      case ItemStatus.good:
        final daysLeft = widget.item.daysUntilDue;
        return '$daysLeft days remaining';
      case ItemStatus.warning:
        final daysLeft = widget.item.daysUntilDue;
        if (daysLeft > 0) {
          return 'Due in $daysLeft days';
        } else if (daysLeft == 0) {
          return 'Due today';
        } else {
          return 'Overdue';
        }
      case ItemStatus.overdue:
        final daysOver = -widget.item.daysUntilDue;
        return 'Overdue by $daysOver days';
    }
  }

  /// Show edit dialog
  void _showEditDialog(BuildContext context) {
    final settings = context.read<SettingsProvider>();
    if (settings.hapticFeedbackEnabled) {
      HapticService.lightImpact();
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditItemDialog(item: widget.item),
    );
  }

  /// Show context menu with options
  void _showOptionsMenu(BuildContext context) {
    final settings = context.read<SettingsProvider>();
    if (settings.hapticFeedbackEnabled) {
      HapticService.mediumImpact();
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildOptionsSheet(context),
    );
  }

  Widget _buildOptionsSheet(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                _showEditDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh_rounded),
              title: const Text('Reset to Today'),
              onTap: () {
                Navigator.pop(context);
                _resetItem(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: AppColors.error),
              title: Text('Delete', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// Reset the item to today's date
  void _resetItem(BuildContext context) {
    final settings = context.read<SettingsProvider>();
    if (settings.hapticFeedbackEnabled) {
      HapticService.mediumImpact();
    }

    final provider = context.read<TrackedItemsProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final itemName = widget.item.name;
    final previousDate = widget.item.lastResetDate;
    final daysSinceReset = widget.item.daysSinceReset;
    final isMilestone = MilestoneUtils.isMilestone(daysSinceReset);

    // Clear any existing snackbars first
    messenger.clearSnackBars();

    provider.resetItem(widget.item.id).then((success) {
      if (success && context.mounted) {
        final snackBarController = messenger.showSnackBar(
          SnackBar(
            content: Text('$itemName reset to today'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 3),
            dismissDirection: DismissDirection.horizontal,
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                final updatedItem = widget.item.copyWith(
                  lastResetDate: previousDate,
                );
                provider.updateItem(updatedItem);
              },
            ),
          ),
        );

        // Ensure snackbar closes after duration
        Future.delayed(const Duration(seconds: 3), () {
          snackBarController.close();
        });

        // Show celebration if milestone reached
        if (isMilestone && context.mounted) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (context.mounted) {
              MilestoneUtils.showCelebration(
                context: context,
                itemName: itemName,
                days: daysSinceReset,
              );
            }
          });
        }
      }
    });
  }

  /// Confirm deletion
  void _confirmDelete(BuildContext context) {
    final settings = context.read<SettingsProvider>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${widget.item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (settings.hapticFeedbackEnabled) {
                HapticService.mediumImpact();
              }
              context.read<TrackedItemsProvider>().deleteItem(widget.item.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${widget.item.name} deleted'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
