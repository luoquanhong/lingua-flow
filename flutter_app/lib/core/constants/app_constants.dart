import 'package:flutter/material.dart';

/// App-wide route paths
class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String wordAdd = '/word/add';
  static const String sceneLearn = '/scene/learn';
  static const String review = '/review';
  static const String profile = '/profile';
}

/// Route name identifiers (used for go_router named routes)
class RouteNames {
  RouteNames._();

  static const String home = 'home';
  static const String wordAdd = 'word-add';
  static const String sceneLearn = 'scene-learn';
  static const String review = 'review';
  static const String profile = 'profile';
}

/// App color palette
class AppColors {
  AppColors._();

  // Primary brand colors
  static const Color primary = Color(0xFF6366F1);   // Indigo-500
  static const Color primaryLight = Color(0xFF818CF8); // Indigo-400
  static const Color primaryDark = Color(0xFF4F46E5);  // Indigo-600

  // Secondary / accent
  static const Color secondary = Color(0xFF10B981);   // Emerald-500
  static const Color secondaryLight = Color(0xFF34D399); // Emerald-400

  // Neutral
  static const Color background = Color(0xFFF8FAFC);  // Slate-50
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1E293B);  // Slate-800
  static const Color textSecondary = Color(0xFF64748B); // Slate-500
  static const Color divider = Color(0xFFE2E8F0);      // Slate-200

  // Status colors
  static const Color success = Color(0xFF22C55E);       // Green-500
  static const Color warning = Color(0xFFF59E0B);      // Amber-500
  static const Color error = Color(0xFFEF4444);         // Red-500
  static const Color info = Color(0xFF3B82F6);         // Blue-500

  // Word mastery levels
  static const Color masteryNew = Color(0xFFE0E7FF);   // Indigo-100
  static const Color masteryLearning = Color(0xFFFEF3C7); // Amber-100
  static const Color masteryFamiliar = Color(0xFFD1FAE5); // Emerald-100
  static const Color masteryMastered = Color(0xFFDCFCE7); // Green-100

  // Dark theme colors
  static const Color darkBackground = Color(0xFF0F172A); // Slate-900
  static const Color darkSurface = Color(0xFF1E293B);   // Slate-800
  static const Color darkTextPrimary = Color(0xFFF1F5F9); // Slate-100
  static const Color darkTextSecondary = Color(0xFF94A3B8); // Slate-400
}

/// App spacing and sizing constants
class AppSizes {
  AppSizes._();

  // Padding & margin
  static const double paddingXs = 4.0;
  static const double paddingSm = 8.0;
  static const double paddingMd = 16.0;
  static const double paddingLg = 24.0;
  static const double paddingXl = 32.0;

  // Border radius
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 9999.0;

  // Icon sizes
  static const double iconSm = 16.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;

  // Button heights
  static const double buttonHeightSm = 36.0;
  static const double buttonHeightMd = 48.0;
  static const double buttonHeightLg = 56.0;

  // Card elevation
  static const double elevationSm = 2.0;
  static const double elevationMd = 4.0;
  static const double elevationLg = 8.0;
}

/// Hive box names for local persistence
class HiveBoxes {
  HiveBoxes._();

  static const String wordBoxName = 'words';
  static const String sceneBoxName = 'scenes';
  static const String reviewBoxName = 'reviews';
  static const String userBoxName = 'user';
}

/// SharedPreferences keys
class PrefsKeys {
  PrefsKeys._();

  static const String onboardingComplete = 'onboarding_complete';
  static const String lastReviewDate = 'last_review_date';
  static const String dailyGoal = 'daily_goal';
  static const String notificationEnabled = 'notification_enabled';
  static const String reminderTime = 'reminder_time';
  static const String totalWordsLearned = 'total_words_learned';
  static const String currentStreak = 'current_streak';
}

/// API endpoints (backend is Go)
class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'http://localhost:8080/api/v1';

  // Word endpoints
  static const String words = '/words';
  static const String wordById = '/words/{id}';

  // Scene endpoints
  static const String scenes = '/scenes';
  static const String sceneGenerate = '/scenes/generate';
  static const String sceneById = '/scenes/{id}';

  // Review endpoints
  static const String reviews = '/reviews';
  static const String reviewSchedule = '/reviews/schedule';
  static const String reviewRecord = '/reviews/record';

  // User endpoints
  static const String userStats = '/user/stats';
  static const String userProfile = '/user/profile';
}

/// Default learning goal constants
class LearningDefaults {
  LearningDefaults._();

  static const int dailyWordGoal = 10;
  static const int dailySceneGoal = 1;
  static const int reviewBatchSize = 20;
  static const int maxWordsPerScene = 8;
}

/// Ebbinghaus review intervals (in days)
class ReviewIntervals {
  ReviewIntervals._();

  /// Intervals for spaced repetition: 1 day, 3 days, 7 days, 14 days, 30 days, 60 days
  static const List<int> intervals = [1, 3, 7, 14, 30, 60];
  static const List<int> maxIntervals = [1, 3, 7, 14, 30, 60, 120];
}
