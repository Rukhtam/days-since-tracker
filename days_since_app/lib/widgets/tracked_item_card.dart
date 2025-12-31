import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../models/tracked_item.dart';
import '../providers/tracked_items_provider.dart';
import '../utils/icon_utils.dart';
import 'progress_ring.dart';
import 'edit_item_dialog.dart';

/// Card widget displaying a single tracked item with its day counter
/// and progress ring visualization.
class TrackedItemCard extends StatelessWidget {
  final TrackedItem item;

  const TrackedItemCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = AppColors.fromHex(item.statusColor);
    final itemColor = AppColors.fromHex(item.color);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => _showEditDialog(context),
        onLongPress: () => _showOptionsMenu(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Progress ring with day counter
              ProgressRing(
                percentage: item.percentageElapsed,
                progressColor: statusColor,
                size: 100,
                strokeWidth: 6,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Day counter (large number) - Accessibility: Prominent visual hierarchy
                    Text(
                      item.daysSinceReset.toString(),
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 64,
                          ),
                    ),
                    // "days" label
                    Text(
                      item.daysSinceReset == 1 ? 'day' : 'days',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textTertiary,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Item details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Item icon and name row
                    Row(
                      children: [
                        Icon(
                          IconUtils.getIconData(item.iconName),
                          color: itemColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.name,
                            style: Theme.of(context).textTheme.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Status text
                    _buildStatusText(context, statusColor),
                    const SizedBox(height: 4),
                    // Interval info
                    Text(
                      'Every ${item.recommendedIntervalDays} days',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              // Reset button - Accessibility: 48x48dp touch target
              IconButton(
                onPressed: () => _resetItem(context),
                padding: const EdgeInsets.all(12),
                constraints: const BoxConstraints(
                  minWidth: 48,
                  minHeight: 48,
                ),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.refresh,
                    color: statusColor,
                    size: 24,
                  ),
                ),
                tooltip: 'Reset to today',
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build status text based on item state
  Widget _buildStatusText(BuildContext context, Color statusColor) {
    String statusText;
    switch (item.status) {
      case ItemStatus.good:
        final daysLeft = item.daysUntilDue;
        statusText = '$daysLeft days remaining';
        break;
      case ItemStatus.warning:
        final daysLeft = item.daysUntilDue;
        if (daysLeft > 0) {
          statusText = 'Due in $daysLeft days';
        } else if (daysLeft == 0) {
          statusText = 'Due today';
        } else {
          statusText = 'Overdue';
        }
        break;
      case ItemStatus.overdue:
        final daysOver = -item.daysUntilDue;
        statusText = '$daysOver days overdue';
        break;
    }

    return Text(
      statusText,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: statusColor.withValues(alpha: 0.7),  // Reduced saturation for visual hierarchy
            fontWeight: FontWeight.w500,
          ),
    );
  }

  /// Reset the item to today's date
  void _resetItem(BuildContext context) {
    HapticFeedback.mediumImpact();
    final provider = context.read<TrackedItemsProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final itemName = item.name;
    final previousDate = item.lastResetDate;

    provider.resetItem(item.id).then((success) {
      if (success) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('$itemName reset to today'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                // Undo by setting back to previous date
                final updatedItem = item.copyWith(lastResetDate: previousDate);
                provider.updateItem(updatedItem);
              },
            ),
          ),
        );
      }
    });
  }

  /// Show edit dialog for this item
  void _showEditDialog(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditItemDialog(item: item),
    );
  }

  /// Show options menu (edit/delete)
  void _showOptionsMenu(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            // Item name header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Icon(
                    IconUtils.getIconData(item.iconName),
                    color: AppColors.fromHex(item.color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            // Reset option
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Reset to today'),
              onTap: () {
                Navigator.pop(context);
                _resetItem(context);
              },
            ),
            // Edit option
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit item'),
              onTap: () {
                Navigator.pop(context);
                _showEditDialog(context);
              },
            ),
            // Delete option
            ListTile(
              leading: Icon(Icons.delete_outline, color: AppColors.error),
              title: Text(
                'Delete item',
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Show delete confirmation dialog
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<TrackedItemsProvider>().deleteItem(item.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${item.name} deleted')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
