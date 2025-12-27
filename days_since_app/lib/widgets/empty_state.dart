import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Empty state widget shown when there are no tracked items.
class EmptyState extends StatelessWidget {
  final VoidCallback onAddPressed;

  const EmptyState({
    super.key,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Decorative icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_available,
                size: 64,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 32),
            // Title
            Text(
              'No items yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            // Description
            Text(
              'Start tracking habits and events.\nTap the button below to add your first item.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Add button
            ElevatedButton.icon(
              onPressed: onAddPressed,
              icon: const Icon(Icons.add),
              label: const Text('Add First Item'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 48),
            // Suggestions
            _buildSuggestions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestions(BuildContext context) {
    return Column(
      children: [
        Text(
          'Popular tracking ideas:',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            _buildSuggestionChip(context, Icons.content_cut, 'Haircut'),
            _buildSuggestionChip(context, Icons.directions_car, 'Oil Change'),
            _buildSuggestionChip(context, Icons.bed, 'Bedsheets'),
            _buildSuggestionChip(context, Icons.brush, 'Toothbrush'),
            _buildSuggestionChip(context, Icons.water_drop, 'Water Filter'),
          ],
        ),
      ],
    );
  }

  Widget _buildSuggestionChip(
      BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}
