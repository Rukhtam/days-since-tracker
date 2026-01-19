import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_colors.dart';
import '../providers/tracked_items_provider.dart';
import '../providers/settings_provider.dart';
import '../services/notification_service.dart';
import '../widgets/modern_event_card.dart';
import '../widgets/add_item_dialog.dart';
import '../widgets/empty_state.dart';
import 'settings_screen.dart';

/// The main home screen displaying all tracked items with modern UI.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  // Track when startup is complete to trigger ring animations
  bool _startupComplete = false;
  
  // OEM battery optimization warning
  bool _showOemWarning = false;
  bool _warningDismissed = false;
  String _oemBrand = '';
  String _oemGuideUrl = 'https://dontkillmyapp.com';

  @override
  void initState() {
    super.initState();
    // Add observer to refresh data when app resumes
    WidgetsBinding.instance.addObserver(this);
    
    // Wait for first frame to be rendered, then trigger animations
    // Using 400ms delay as per animation best practices - allows UI to fully settle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) {
          setState(() => _startupComplete = true);
        }
      });
      // Check for aggressive OEM battery optimization issue
      _checkOemBatteryOptimization();
    });
  }
  
  /// Check if this is an aggressive OEM device with battery optimization enabled
  /// Based on dontkillmyapp.com rankings
  Future<void> _checkOemBatteryOptimization() async {
    if (!Platform.isAndroid) return;
    
    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final brand = androidInfo.brand.toLowerCase();
      
      // List of aggressive OEMs from dontkillmyapp.com
      // Ranked by severity: Samsung, Xiaomi, Huawei, OnePlus, OPPO, Vivo, Realme, etc.
      final aggressiveOems = {
        'samsung': 'https://dontkillmyapp.com/samsung',
        'xiaomi': 'https://dontkillmyapp.com/xiaomi',
        'huawei': 'https://dontkillmyapp.com/huawei',
        'oneplus': 'https://dontkillmyapp.com/oneplus',
        'oppo': 'https://dontkillmyapp.com/oppo',
        'vivo': 'https://dontkillmyapp.com/vivo',
        'realme': 'https://dontkillmyapp.com/realme',
        'meizu': 'https://dontkillmyapp.com/meizu',
        'asus': 'https://dontkillmyapp.com/asus',
        'lenovo': 'https://dontkillmyapp.com/lenovo',
        'nokia': 'https://dontkillmyapp.com/nokia',
        'tecno': 'https://dontkillmyapp.com/tecno',
        'infinix': 'https://dontkillmyapp.com/infinix',
      };
      
      // Check if this is an aggressive OEM
      String? guideUrl;
      for (final entry in aggressiveOems.entries) {
        if (brand.contains(entry.key)) {
          guideUrl = entry.value;
          _oemBrand = entry.key[0].toUpperCase() + entry.key.substring(1); // Capitalize
          break;
        }
      }
      
      if (guideUrl == null) return; // Not an aggressive OEM
      
      _oemGuideUrl = guideUrl;
      
      // Check if battery optimization is disabled
      final isBatteryOptDisabled = await NotificationService().isBatteryOptimizationDisabled();
      
      if (!isBatteryOptDisabled && mounted && !_warningDismissed) {
        setState(() => _showOemWarning = true);
      }
    } catch (e) {
      debugPrint('HomeScreen: Error checking OEM battery optimization: $e');
    }
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
      // Re-check OEM battery optimization (user might have fixed it)
      _checkOemBatteryOptimization();
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
    final settings = context.watch<SettingsProvider>();
    final isDarkMode = settings.flutterThemeMode == ThemeMode.dark ||
        (settings.flutterThemeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    // Modern color scheme
    final backgroundColor = isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF2F5F9);
    final headerColor = isDarkMode ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B);
    final subColor = isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: backgroundColor,
      extendBody: true,
      extendBodyBehindAppBar: true,
      
      // Modern FAB
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: _showAddItemDialog,
        tooltip: 'Add new item',
        child: const Icon(Icons.add, color: Colors.white),
      ),
      
      body: SafeArea(
        bottom: false, // Allow content to extend behind navigation bar
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Modern Custom Header ---
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Days Since",
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: headerColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Track your recurring events",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: subColor,
                        ),
                      ),
                    ],
                  ),
                  // Status summary and settings
                  Row(
                    children: [
                      // Status indicators
                      Consumer<TrackedItemsProvider>(
                        builder: (context, provider, _) {
                          if (provider.isEmpty) return const SizedBox.shrink();
                          return _buildStatusSummary(provider, isDarkMode);
                        },
                      ),
                      const SizedBox(width: 8),
                      // Settings button
                      Container(
                        decoration: BoxDecoration(
                          color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            if (!isDarkMode)
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(Icons.settings_outlined, color: headerColor),
                          onPressed: _openSettings,
                          tooltip: 'Settings',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // --- OEM Battery Warning Banner ---
            if (_showOemWarning)
              _buildOemWarningBanner(isDarkMode),

            // --- List of Cards ---
            Expanded(
              child: Consumer<TrackedItemsProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  if (provider.error != null) {
                    return _buildErrorState(context, provider);
                  }

                  if (provider.isEmpty) {
                    return EmptyState(
                      onAddPressed: _showAddItemDialog,
                    );
                  }

                  final items = provider.itemsSortedByPreference;
                  return RefreshIndicator(
                    onRefresh: () => provider.refresh(),
                    color: AppColors.primary,
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(), // iOS feel
                      padding: const EdgeInsets.only(
                        top: 8,
                        bottom: 100, // Extra padding for FAB
                      ),
                      itemCount: items.length,
                      // Performance optimizations
                      addAutomaticKeepAlives: false,
                      addRepaintBoundaries: true,
                      cacheExtent: 200, // Pre-render items slightly off-screen
                      itemBuilder: (context, index) {
                        return RepaintBoundary(
                          child: ModernEventCard(
                            key: ValueKey(items[index].id),
                            item: items[index],
                            index: index,
                            startupComplete: _startupComplete,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build OEM battery optimization warning banner
  /// Supports Samsung, Xiaomi, Huawei, OnePlus, OPPO, Vivo, Realme, etc.
  Widget _buildOemWarningBanner(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0), // Orange background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFF9800), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFE65100),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_oemBrand Battery Optimization',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFE65100),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Notifications may not work. Disable battery optimization and add this app to "Never sleeping apps".',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF795548),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        await NotificationService().requestDisableBatteryOptimization();
                        // Re-check after user returns
                        if (mounted) {
                          final isDisabled = await NotificationService().isBatteryOptimizationDisabled();
                          if (isDisabled) {
                            setState(() => _showOemWarning = false);
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF9800),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Fix Now',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        final uri = Uri.parse(_oemGuideUrl);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFFF9800), width: 1),
                        ),
                        child: Text(
                          'Learn More',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFE65100),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showOemWarning = false;
                          _warningDismissed = true;
                        });
                      },
                      child: Text(
                        'Dismiss',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFF795548),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build compact status summary
  Widget _buildStatusSummary(TrackedItemsProvider provider, bool isDarkMode) {
    final overdueCount = provider.overdueCount;
    final warningCount = provider.warningCount;
    
    if (overdueCount == 0 && warningCount == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (!isDarkMode)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (overdueCount > 0) ...[
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.statusOverdue,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '$overdueCount',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.statusOverdue,
              ),
            ),
          ],
          if (overdueCount > 0 && warningCount > 0)
            const SizedBox(width: 8),
          if (warningCount > 0) ...[
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.statusWarning,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '$warningCount',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.statusWarning,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build error state widget
  Widget _buildErrorState(BuildContext context, TrackedItemsProvider provider) {
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
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            provider.error!,
            style: GoogleFonts.poppins(fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => provider.refresh(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
