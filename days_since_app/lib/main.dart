import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'constants/app_theme.dart';
import 'providers/tracked_items_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/home_screen.dart';
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

  // Note: System UI overlay style will be set dynamically based on theme

  // Initialize Hive for local storage
  await HiveService.initialize();

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
            // Sync sort order from settings to items provider
            if (previous != null && settings.isInitialized) {
              previous.sortOrder = settings.sortOrder;
            }
            return previous ?? (TrackedItemsProvider()..loadItems());
          },
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          // Update system UI overlay style based on theme
          final isDark = settings.flutterThemeMode == ThemeMode.dark ||
              (settings.flutterThemeMode == ThemeMode.system &&
                  MediaQuery.platformBrightnessOf(context) == Brightness.dark);

          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness:
                  isDark ? Brightness.light : Brightness.dark,
              systemNavigationBarColor:
                  isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA),
              systemNavigationBarIconBrightness:
                  isDark ? Brightness.light : Brightness.dark,
            ),
          );

          return MaterialApp(
            title: 'Days Since',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.flutterThemeMode,
            home: const AppInitializer(child: HomeScreen()),
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
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Give providers time to initialize
    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;

    final settings = context.read<SettingsProvider>();
    final itemsProvider = context.read<TrackedItemsProvider>();

    // Request notification permissions on first launch
    if (settings.isFirstLaunch) {
      final notificationService = NotificationService();
      final granted = await notificationService.requestPermissions();
      debugPrint('Notification permissions granted: $granted');
      settings.markFirstLaunchComplete();
    }

    // Schedule notifications for all items if enabled
    if (settings.notificationsEnabled) {
      final items = itemsProvider.items;
      await NotificationService().updateAllNotifications(items);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show the main app immediately, initialization happens in background
    return widget.child;
  }
}
