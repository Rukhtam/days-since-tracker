import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../providers/tracked_items_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/tracked_item_card.dart';
import '../widgets/add_item_dialog.dart';
import '../widgets/empty_state.dart';
import 'settings_screen.dart';

/// The main home screen displaying all tracked items.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // Add observer to refresh data when app resumes
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh items when app resumes to update day counts
    if (state == AppLifecycleState.resumed) {
      context.read<TrackedItemsProvider>().refresh();
    }
  }

  void _showAddItemDialog() {
    // Haptic feedback when opening dialog
    final settings = context.read<SettingsProvider>();
    if (settings.hapticFeedbackEnabled) {
      HapticFeedback.mediumImpact();
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddItemDialog(),
    );
  }

  void _openSettings() {
    final settings = context.read<SettingsProvider>();
    if (settings.hapticFeedbackEnabled) {
      HapticFeedback.lightImpact();
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Days Since'),
        actions: [
          // Stats summary in app bar
          Consumer<TrackedItemsProvider>(
            builder: (context, provider, _) {
              if (provider.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildStatusBadge(
                      count: provider.overdueCount,
                      color: AppColors.statusOverdue,
                    ),
                    const SizedBox(width: 6),
                    _buildStatusBadge(
                      count: provider.warningCount,
                      color: AppColors.statusWarning,
                    ),
                    const SizedBox(width: 6),
                    _buildStatusBadge(
                      count: provider.goodCount,
                      color: AppColors.statusGood,
                    ),
                  ],
                ),
              );
            },
          ),
          // Settings button
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: _openSettings,
          ),
        ],
      ),
      body: Consumer<TrackedItemsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Something went wrong',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.error!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => provider.refresh(),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          if (provider.isEmpty) {
            return EmptyState(
              onAddPressed: _showAddItemDialog,
            );
          }

          // Display items sorted by user preference
          final items = provider.itemsSortedByPreference;
          return RefreshIndicator(
            onRefresh: () => provider.refresh(),
            color: AppColors.primary,
            child: ListView.builder(
              padding: const EdgeInsets.only(
                top: 8,
                bottom: 100, // Extra padding for FAB
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return TrackedItemCard(
                  item: items[index],
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        tooltip: 'Add new item',
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Build a small status indicator badge showing count
  Widget _buildStatusBadge({
    required int count,
    required Color color,
  }) {
    if (count == 0) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        count.toString(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
