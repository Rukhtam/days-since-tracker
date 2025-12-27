/// Pre-set templates for common tracking items.
/// These help users quickly add common items without typing everything.
class ItemTemplate {
  final String name;
  final String iconName;
  final int recommendedIntervalDays;
  final String color;
  final String category;

  const ItemTemplate({
    required this.name,
    required this.iconName,
    required this.recommendedIntervalDays,
    required this.color,
    required this.category,
  });
}

/// All available pre-set templates organized by category.
class Templates {
  // Prevent instantiation
  Templates._();

  static const List<ItemTemplate> all = [
    // Personal Care
    ItemTemplate(
      name: 'Haircut',
      iconName: 'content_cut',
      recommendedIntervalDays: 30,
      color: '#9C27B0',
      category: 'Personal Care',
    ),
    ItemTemplate(
      name: 'Toothbrush',
      iconName: 'brush',
      recommendedIntervalDays: 90,
      color: '#2196F3',
      category: 'Personal Care',
    ),
    ItemTemplate(
      name: 'Dental Checkup',
      iconName: 'medical_services',
      recommendedIntervalDays: 180,
      color: '#00BCD4',
      category: 'Personal Care',
    ),
    ItemTemplate(
      name: 'Eye Exam',
      iconName: 'visibility',
      recommendedIntervalDays: 365,
      color: '#3F51B5',
      category: 'Personal Care',
    ),
    ItemTemplate(
      name: 'Physical Checkup',
      iconName: 'health_and_safety',
      recommendedIntervalDays: 365,
      color: '#4CAF50',
      category: 'Personal Care',
    ),
    ItemTemplate(
      name: 'Flu Shot',
      iconName: 'vaccines',
      recommendedIntervalDays: 365,
      color: '#E91E63',
      category: 'Personal Care',
    ),

    // Home & Cleaning
    ItemTemplate(
      name: 'Change Bedsheets',
      iconName: 'bed',
      recommendedIntervalDays: 14,
      color: '#9C27B0',
      category: 'Home',
    ),
    ItemTemplate(
      name: 'Deep Clean Kitchen',
      iconName: 'kitchen',
      recommendedIntervalDays: 30,
      color: '#FF9800',
      category: 'Home',
    ),
    ItemTemplate(
      name: 'Clean Bathroom',
      iconName: 'bathtub',
      recommendedIntervalDays: 7,
      color: '#00BCD4',
      category: 'Home',
    ),
    ItemTemplate(
      name: 'Replace AC Filter',
      iconName: 'ac_unit',
      recommendedIntervalDays: 90,
      color: '#2196F3',
      category: 'Home',
    ),
    ItemTemplate(
      name: 'Replace Water Filter',
      iconName: 'water_drop',
      recommendedIntervalDays: 60,
      color: '#03A9F4',
      category: 'Home',
    ),
    ItemTemplate(
      name: 'Vacuum Home',
      iconName: 'cleaning_services',
      recommendedIntervalDays: 7,
      color: '#607D8B',
      category: 'Home',
    ),
    ItemTemplate(
      name: 'Wash Towels',
      iconName: 'local_laundry_service',
      recommendedIntervalDays: 3,
      color: '#009688',
      category: 'Home',
    ),
    ItemTemplate(
      name: 'Mow Lawn',
      iconName: 'grass',
      recommendedIntervalDays: 7,
      color: '#4CAF50',
      category: 'Home',
    ),
    ItemTemplate(
      name: 'Water Plants',
      iconName: 'local_florist',
      recommendedIntervalDays: 3,
      color: '#8BC34A',
      category: 'Home',
    ),

    // Vehicle
    ItemTemplate(
      name: 'Oil Change',
      iconName: 'oil_barrel',
      recommendedIntervalDays: 90,
      color: '#795548',
      category: 'Vehicle',
    ),
    ItemTemplate(
      name: 'Tire Rotation',
      iconName: 'tire_repair',
      recommendedIntervalDays: 180,
      color: '#607D8B',
      category: 'Vehicle',
    ),
    ItemTemplate(
      name: 'Car Wash',
      iconName: 'directions_car',
      recommendedIntervalDays: 14,
      color: '#2196F3',
      category: 'Vehicle',
    ),
    ItemTemplate(
      name: 'Check Tire Pressure',
      iconName: 'tire_repair',
      recommendedIntervalDays: 30,
      color: '#FF5722',
      category: 'Vehicle',
    ),
    ItemTemplate(
      name: 'Brake Inspection',
      iconName: 'build',
      recommendedIntervalDays: 180,
      color: '#F44336',
      category: 'Vehicle',
    ),

    // Pets
    ItemTemplate(
      name: 'Pet Grooming',
      iconName: 'pets',
      recommendedIntervalDays: 60,
      color: '#FF9800',
      category: 'Pets',
    ),
    ItemTemplate(
      name: 'Pet Vet Visit',
      iconName: 'pets',
      recommendedIntervalDays: 365,
      color: '#4CAF50',
      category: 'Pets',
    ),
    ItemTemplate(
      name: 'Pet Flea Treatment',
      iconName: 'pets',
      recommendedIntervalDays: 30,
      color: '#E91E63',
      category: 'Pets',
    ),

    // Tech
    ItemTemplate(
      name: 'Backup Data',
      iconName: 'backup',
      recommendedIntervalDays: 7,
      color: '#3F51B5',
      category: 'Tech',
    ),
    ItemTemplate(
      name: 'Change Passwords',
      iconName: 'password',
      recommendedIntervalDays: 90,
      color: '#F44336',
      category: 'Tech',
    ),
    ItemTemplate(
      name: 'Update Software',
      iconName: 'sync',
      recommendedIntervalDays: 30,
      color: '#2196F3',
      category: 'Tech',
    ),
    ItemTemplate(
      name: 'Clean Phone Screen',
      iconName: 'phone_android',
      recommendedIntervalDays: 7,
      color: '#607D8B',
      category: 'Tech',
    ),
    ItemTemplate(
      name: 'Clean Computer',
      iconName: 'computer',
      recommendedIntervalDays: 30,
      color: '#9E9E9E',
      category: 'Tech',
    ),

    // Finance
    ItemTemplate(
      name: 'Review Budget',
      iconName: 'payments',
      recommendedIntervalDays: 30,
      color: '#4CAF50',
      category: 'Finance',
    ),
    ItemTemplate(
      name: 'Check Credit Report',
      iconName: 'credit_card',
      recommendedIntervalDays: 365,
      color: '#FF9800',
      category: 'Finance',
    ),
    ItemTemplate(
      name: 'Pay Bills',
      iconName: 'receipt',
      recommendedIntervalDays: 30,
      color: '#F44336',
      category: 'Finance',
    ),

    // Social
    ItemTemplate(
      name: 'Call Parents',
      iconName: 'call',
      recommendedIntervalDays: 7,
      color: '#E91E63',
      category: 'Social',
    ),
    ItemTemplate(
      name: 'Catch Up With Friends',
      iconName: 'people',
      recommendedIntervalDays: 14,
      color: '#9C27B0',
      category: 'Social',
    ),

    // Fitness
    ItemTemplate(
      name: 'Replace Running Shoes',
      iconName: 'directions_run',
      recommendedIntervalDays: 365,
      color: '#FF5722',
      category: 'Fitness',
    ),
    ItemTemplate(
      name: 'Gym Session',
      iconName: 'fitness_center',
      recommendedIntervalDays: 2,
      color: '#F44336',
      category: 'Fitness',
    ),
    ItemTemplate(
      name: 'Meditation',
      iconName: 'self_improvement',
      recommendedIntervalDays: 1,
      color: '#9C27B0',
      category: 'Fitness',
    ),
  ];

  /// Get templates grouped by category
  static Map<String, List<ItemTemplate>> get byCategory {
    final Map<String, List<ItemTemplate>> grouped = {};
    for (final template in all) {
      grouped.putIfAbsent(template.category, () => []);
      grouped[template.category]!.add(template);
    }
    return grouped;
  }

  /// Get all unique category names
  static List<String> get categories {
    return byCategory.keys.toList();
  }

  /// Search templates by name
  static List<ItemTemplate> search(String query) {
    if (query.isEmpty) return all;
    final lowerQuery = query.toLowerCase();
    return all
        .where((t) =>
            t.name.toLowerCase().contains(lowerQuery) ||
            t.category.toLowerCase().contains(lowerQuery))
        .toList();
  }
}
