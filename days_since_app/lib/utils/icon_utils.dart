import 'package:flutter/material.dart';

/// Utility class for mapping icon names to Material Icons.
class IconUtils {
  // Prevent instantiation
  IconUtils._();

  /// Map of icon names to their IconData
  static const Map<String, IconData> _iconMap = {
    // Personal care
    'content_cut': Icons.content_cut,
    'face': Icons.face,
    'spa': Icons.spa,
    'brush': Icons.brush,
    'healing': Icons.healing,
    'medical_services': Icons.medical_services,
    'vaccines': Icons.vaccines,
    'health_and_safety': Icons.health_and_safety,

    // Home & Cleaning
    'cleaning_services': Icons.cleaning_services,
    'local_laundry_service': Icons.local_laundry_service,
    'bed': Icons.bed,
    'bathtub': Icons.bathtub,
    'kitchen': Icons.kitchen,
    'microwave': Icons.microwave,
    'ac_unit': Icons.ac_unit,
    'water_drop': Icons.water_drop,
    'filter_alt': Icons.filter_alt,
    'grass': Icons.grass,
    'yard': Icons.yard,
    'home': Icons.home,
    'chair': Icons.chair,
    'weekend': Icons.weekend,

    // Vehicle & Transportation
    'directions_car': Icons.directions_car,
    'local_gas_station': Icons.local_gas_station,
    'tire_repair': Icons.tire_repair,
    'oil_barrel': Icons.oil_barrel,
    'build': Icons.build,
    'handyman': Icons.handyman,
    'two_wheeler': Icons.two_wheeler,
    'pedal_bike': Icons.pedal_bike,
    'airport_shuttle': Icons.airport_shuttle,

    // Health & Fitness
    'fitness_center': Icons.fitness_center,
    'sports': Icons.sports,
    'directions_run': Icons.directions_run,
    'self_improvement': Icons.self_improvement,
    'favorite': Icons.favorite,
    'monitor_heart': Icons.monitor_heart,
    'medication': Icons.medication,
    'psychology': Icons.psychology,
    'visibility': Icons.visibility,

    // Tech & Electronics
    'phone_android': Icons.phone_android,
    'laptop': Icons.laptop,
    'computer': Icons.computer,
    'backup': Icons.backup,
    'cloud_sync': Icons.cloud_sync,
    'security': Icons.security,
    'password': Icons.password,
    'battery_charging_full': Icons.battery_charging_full,

    // Pets
    'pets': Icons.pets,
    'cruelty_free': Icons.cruelty_free,

    // Finance
    'payments': Icons.payments,
    'account_balance': Icons.account_balance,
    'savings': Icons.savings,
    'receipt': Icons.receipt,
    'credit_card': Icons.credit_card,

    // Social & Communication
    'call': Icons.call,
    'email': Icons.email,
    'people': Icons.people,
    'person': Icons.person,
    'family_restroom': Icons.family_restroom,
    'celebration': Icons.celebration,
    'cake': Icons.cake,
    'card_giftcard': Icons.card_giftcard,

    // Work & Productivity
    'work': Icons.work,
    'task_alt': Icons.task_alt,
    'event': Icons.event,
    'schedule': Icons.schedule,
    'update': Icons.update,
    'sync': Icons.sync,

    // Plants & Garden
    'local_florist': Icons.local_florist,
    'park': Icons.park,
    'nature': Icons.nature,
    'eco': Icons.eco,

    // Food & Kitchen
    'restaurant': Icons.restaurant,
    'coffee': Icons.coffee,
    'icecream': Icons.icecream,
    'liquor': Icons.liquor,
    'bakery_dining': Icons.bakery_dining,

    // Generic/Default
    'check_circle': Icons.check_circle,
    'star': Icons.star,
    'bookmark': Icons.bookmark,
    'flag': Icons.flag,
    'label': Icons.label,
    'more_horiz': Icons.more_horiz,
  };

  /// Get IconData from icon name string
  static IconData getIconData(String iconName) {
    return _iconMap[iconName] ?? Icons.check_circle;
  }

  /// Get all available icon names
  static List<String> get availableIconNames => _iconMap.keys.toList();

  /// Get icons grouped by category
  static Map<String, List<String>> get iconsByCategory => {
        'Personal Care': [
          'content_cut',
          'face',
          'spa',
          'brush',
          'healing',
          'medical_services',
          'vaccines',
          'health_and_safety',
        ],
        'Home & Cleaning': [
          'cleaning_services',
          'local_laundry_service',
          'bed',
          'bathtub',
          'kitchen',
          'microwave',
          'ac_unit',
          'water_drop',
          'filter_alt',
          'grass',
          'yard',
          'home',
          'chair',
          'weekend',
        ],
        'Vehicle': [
          'directions_car',
          'local_gas_station',
          'tire_repair',
          'oil_barrel',
          'build',
          'handyman',
          'two_wheeler',
          'pedal_bike',
          'airport_shuttle',
        ],
        'Health & Fitness': [
          'fitness_center',
          'sports',
          'directions_run',
          'self_improvement',
          'favorite',
          'monitor_heart',
          'medication',
          'psychology',
          'visibility',
        ],
        'Tech': [
          'phone_android',
          'laptop',
          'computer',
          'backup',
          'cloud_sync',
          'security',
          'password',
          'battery_charging_full',
        ],
        'Pets': [
          'pets',
          'cruelty_free',
        ],
        'Finance': [
          'payments',
          'account_balance',
          'savings',
          'receipt',
          'credit_card',
        ],
        'Social': [
          'call',
          'email',
          'people',
          'person',
          'family_restroom',
          'celebration',
          'cake',
          'card_giftcard',
        ],
        'Work': [
          'work',
          'task_alt',
          'event',
          'schedule',
          'update',
          'sync',
        ],
        'Plants': [
          'local_florist',
          'park',
          'nature',
          'eco',
          'grass',
          'yard',
        ],
        'Food': [
          'restaurant',
          'coffee',
          'icecream',
          'liquor',
          'bakery_dining',
        ],
        'General': [
          'check_circle',
          'star',
          'bookmark',
          'flag',
          'label',
          'more_horiz',
        ],
      };

  /// Check if an icon name is valid
  static bool isValidIcon(String iconName) {
    return _iconMap.containsKey(iconName);
  }
}
