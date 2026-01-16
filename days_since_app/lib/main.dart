import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'constants/app_theme.dart';
import 'providers/tracked_items_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/home_screen.dart';
import 'services/haptic_service.dart';
import 'services/hive_service.dart';
import 'services/notification_service.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations (portrait only for now)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Enable edge-to-edge display
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Note: System UI overlay style will be set dynamically based on theme

  // Initialize Hive for local storage
  await HiveService.initialize();

  // Initialize haptic service
  await HapticService.initialize();

  // Initialize notification service
  await NotificationService().initialize(
    onNotificationTap: _handleNotificationTap,
  );

  runApp(const DaysSinceApp());
}

/// Handle notification tap to navigate to the relevant item
void _handleNotificationTap(dynamic response) {
  debugPrint('Notification tapped with payload: ${response.payload}');
  // The payload contains the item ID
  // Navigation will be handled by the app when it opens
}

/// The root widget of the Days Since Tracker app.
class DaysSinceApp extends StatelessWidget {
  const DaysSinceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Settings provider - initialize first as others may depend on it
        ChangeNotifierProvider(
          create: (_) => SettingsProvider()..initialize(),
        ),
        // Tracked items provider
        ChangeNotifierProxyProvider<SettingsProvider, TrackedItemsProvider>(
          create: (_) => TrackedItemsProvider()..loadItems(),
          update: (_, settings, previous) {
            // Sync settings to items provider
            if (previous != null && settings.isInitialized) {
              previous.sortOrder = settings.sortOrder;
              previous.notificationHour = settings.notificationTimeHour;
              previous.notificationMinute = settings.notificationTimeMinute;
            }
            return previous ?? (TrackedItemsProvider()..loadItems());
          },
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          // Determine theme - uses system theme as default before settings load
          final isDark = settings.flutterThemeMode == ThemeMode.dark ||
              (settings.flutterThemeMode == ThemeMode.system &&
                  MediaQuery.platformBrightnessOf(context) == Brightness.dark);

          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness:
                  isDark ? Brightness.light : Brightness.dark,
              systemNavigationBarColor: Colors.transparent,
              systemNavigationBarIconBrightness:
                  isDark ? Brightness.light : Brightness.dark,
              systemNavigationBarContrastEnforced: false,
            ),
          );

          return MaterialApp(
            title: 'Days Since',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme.copyWith(
              scaffoldBackgroundColor: const Color(0xFFF2F5F9),
            ),
            darkTheme: AppTheme.darkTheme.copyWith(
              scaffoldBackgroundColor: const Color(0xFF0F172A),
            ),
            themeMode: settings.flutterThemeMode,
            // Wrap the entire app in AnnotatedRegion for system UI control
            home: AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
                systemNavigationBarColor: Colors.transparent,
                systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
                systemNavigationBarContrastEnforced: false,
                systemNavigationBarDividerColor: Colors.transparent,
              ),
              child: const AppInitializer(child: HomeScreen()),
            ),
          );
        },
      ),
    );
  }
}

/// Widget that handles app initialization tasks after providers are ready.
class AppInitializer extends StatefulWidget {
  final Widget child;

  const AppInitializer({super.key, required this.child});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    // CRITICAL: Wait for Activity to be fully attached and have window focus
    // Android 13+ will ignore permission requests if the Activity isn't ready
    // See: suggestions.md - "Context-less Request in main()"
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _initializeApp();
        }
      });
    });
  }

  Future<void> _initializeApp() async {
    if (!mounted) return;

    final settings = context.read<SettingsProvider>();
    final itemsProvider = context.read<TrackedItemsProvider>();

    // Wait for SettingsProvider to be fully initialized before checking isFirstLaunch
    // This prevents race conditions where the Hive box is not yet open
    int waitAttempts = 0;
    const maxWaitAttempts = 50; // Max 5 seconds (50 * 100ms)
    while (!settings.isInitialized && waitAttempts < maxWaitAttempts) {
      await Future.delayed(const Duration(milliseconds: 100));
      waitAttempts++;
      if (!mounted) return;
    }

    if (!settings.isInitialized) {
      debugPrint('AppInitializer: SettingsProvider failed to initialize after ${maxWaitAttempts * 100}ms');
      return;
    }

    debugPrint('AppInitializer: SettingsProvider initialized, isFirstLaunch=${settings.isFirstLaunch}');

    // Get the NotificationService instance
    final notificationService = NotificationService();

    // Verify NotificationService is initialized before proceeding
    if (!notificationService.isInitialized) {
      debugPrint('AppInitializer: NotificationService not initialized, waiting...');
      // Wait a bit more for notification service to initialize
      int nsWaitAttempts = 0;
      const maxNsWaitAttempts = 30; // Max 3 seconds
      while (!notificationService.isInitialized && nsWaitAttempts < maxNsWaitAttempts) {
        await Future.delayed(const Duration(milliseconds: 100));
        nsWaitAttempts++;
        if (!mounted) return;
      }

      if (!notificationService.isInitialized) {
        debugPrint('AppInitializer: NotificationService failed to initialize, skipping permission request');
        return;
      }
    }

    debugPrint('AppInitializer: NotificationService.isInitialized = ${notificationService.isInitialized}');

    // Request notification permissions on first launch
    if (settings.isFirstLaunch) {
      debugPrint('AppInitializer: First launch detected, requesting notification permissions');

      // IMPORTANT: Use forceShowDialog=true on first launch
      // This ensures we try to show the system permission dialog on Android 13+
      // even if permission_handler incorrectly reports permission as "granted"
      final result = await notificationService.requestPermissionsWithStatus(
        forceShowDialog: true,
      );
      debugPrint('AppInitializer: Permission request result: $result');

      // Only mark first launch complete if we actually showed the dialog or got a definitive answer
      // Do NOT mark complete if the service was not initialized (dialog never showed)
      if (result != PermissionRequestResult.notInitialized &&
          result != PermissionRequestResult.error) {
        settings.markFirstLaunchComplete();
        debugPrint('AppInitializer: Marked first launch complete');
      } else {
        debugPrint('AppInitializer: NOT marking first launch complete due to permission request failure');
      }
    }

    // Schedule notifications for all items if enabled
    // IMPORTANT: Wrap in try-catch to prevent exact alarm failures from
    // crashing the app or stopping execution before permission dialog shows
    // See: suggestions.md - "Exact Alarm Catch-22"
    if (settings.notificationsEnabled) {
      try {
        // Verify permission was actually granted before scheduling
        final hasPermission = await notificationService.areNotificationsEnabled();
        if (hasPermission) {
          final items = itemsProvider.items;
          await notificationService.updateAllNotifications(
            items,
            notificationHour: settings.notificationTimeHour,
            notificationMinute: settings.notificationTimeMinute,
          );
          debugPrint('AppInitializer: Notifications scheduled successfully');
        } else {
          debugPrint('AppInitializer: Skipping notification scheduling - permission not granted');
        }
      } catch (e) {
        // Don't let scheduling failures crash the app or block initialization
        debugPrint('AppInitializer: Error scheduling notifications - $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show the main app immediately, initialization happens in background
    return widget.child;
  }
}
