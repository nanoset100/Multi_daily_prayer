import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/stats_model.dart';

class StatsService {
  static const String _statsKey = 'user_stats';
  static const String _lastVisitDateKey = 'last_visit_date';
  static const String _lastResetDateKey = 'last_reset_date';

  // Get user stats from SharedPreferences
  static Future<StatsModel> getStats() async {
    final prefs = await SharedPreferences.getInstance();
    final statsJson = prefs.getString(_statsKey);

    if (statsJson == null) {
      return StatsModel();
    }

    try {
      return StatsModel.fromJson(jsonDecode(statsJson));
    } catch (e) {
      // Handle any JSON parsing issues
      return StatsModel();
    }
  }

  // Save user stats to SharedPreferences
  static Future<void> saveStats(StatsModel stats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_statsKey, jsonEncode(stats.toJson()));
  }

  // Update stats when the app is opened
  static Future<StatsModel> updateStatsOnAppOpen() async {
    final prefs = await SharedPreferences.getInstance();
    final today =
        DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD format
    final lastVisit = prefs.getString(_lastVisitDateKey);

    // Check if we need to reset daily count
    await checkAndResetDailyCount();

    final stats = await getStats();

    if (lastVisit == null) {
      // First time using the app
      final newStats = stats.copyWith(
        streak: 1,
        todayAccessCount: 1,
        totalAccessCount: 1,
      );
      await saveStats(newStats);
      await prefs.setString(_lastVisitDateKey, today);
      return newStats;
    }

    if (lastVisit == today) {
      // Already visited today, just increase counts
      final newStats = stats.copyWith(
        todayAccessCount: stats.todayAccessCount + 1,
        totalAccessCount: stats.totalAccessCount + 1,
      );
      await saveStats(newStats);
      return newStats;
    }

    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayStr =
        "${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}";

    if (lastVisit == yesterdayStr) {
      // Consecutive day, increase streak
      final newStats = stats.copyWith(
        streak: stats.streak + 1,
        todayAccessCount: 1,
        totalAccessCount: stats.totalAccessCount + 1,
      );
      await saveStats(newStats);
      await prefs.setString(_lastVisitDateKey, today);
      return newStats;
    } else {
      // Streak broken
      final newStats = stats.copyWith(
        streak: 1, // Reset streak
        todayAccessCount: 1,
        totalAccessCount: stats.totalAccessCount + 1,
      );
      await saveStats(newStats);
      await prefs.setString(_lastVisitDateKey, today);
      return newStats;
    }
  }

  // Check if we need to reset daily count and do so if needed
  static Future<void> checkAndResetDailyCount() async {
    final prefs = await SharedPreferences.getInstance();
    final today =
        DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD format
    final lastResetDate = prefs.getString(_lastResetDateKey);

    if (lastResetDate != today) {
      // It's a new day, reset the count
      await resetDailyCount();
      await prefs.setString(_lastResetDateKey, today);
    }
  }

  // Reset today's access count at midnight
  static Future<void> resetDailyCount() async {
    final stats = await getStats();
    if (stats.todayAccessCount > 0) {
      final newStats = stats.copyWith(todayAccessCount: 0);
      await saveStats(newStats);
    }
  }

  // Set daily reminder time
  static Future<void> setReminderTime(String time) async {
    final stats = await getStats();
    final newStats = stats.copyWith(reminderTime: time);
    await saveStats(newStats);
  }
}
