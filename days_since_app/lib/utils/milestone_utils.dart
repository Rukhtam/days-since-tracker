import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Utility class for handling milestone celebrations
class MilestoneUtils {
  // Prevent instantiation
  MilestoneUtils._();

  /// Check if a given day count is a milestone
  static bool isMilestone(int days) {
    return getMilestoneText(days) != null;
  }

  /// Get milestone text for a given day count, or null if not a milestone
  static String? getMilestoneText(int days) {
    if (days == 7) return 'One week!';
    if (days == 30) return 'One month!';
    if (days == 60) return 'Two months!';
    if (days == 100) return 'Triple digits!';
    if (days == 365) return 'One full year!';

    // After 365, celebrate every 100 days
    if (days > 365 && days % 100 == 0) {
      return '$days days!';
    }

    return null;
  }

  /// Show a celebration dialog for reaching a milestone
  static void showCelebration({
    required BuildContext context,
    required String itemName,
    required int days,
  }) {
    final milestoneText = getMilestoneText(days);
    if (milestoneText == null) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.celebration,
          size: 48,
          color: AppColors.statusGood,
        ),
        title: const Text('Milestone Reached!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              milestoneText,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'You\'ve maintained "$itemName" for $days days!',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Awesome!'),
          ),
        ],
      ),
    );
  }

  /// Get all milestone thresholds (for reference)
  static List<int> getAllMilestones() {
    return [7, 30, 60, 100, 365];
  }

  /// Get the next milestone after a given day count
  static int? getNextMilestone(int currentDays) {
    final milestones = getAllMilestones();

    for (final milestone in milestones) {
      if (currentDays < milestone) {
        return milestone;
      }
    }

    // After 365, next milestone is next 100-day increment
    if (currentDays >= 365) {
      final nextHundred = ((currentDays ~/ 100) + 1) * 100;
      return nextHundred;
    }

    return null;
  }

  /// Get days until next milestone
  static int? getDaysUntilNextMilestone(int currentDays) {
    final nextMilestone = getNextMilestone(currentDays);
    if (nextMilestone == null) return null;
    return nextMilestone - currentDays;
  }
}
