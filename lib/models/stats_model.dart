class StatsModel {
  final int streak;
  final int todayAccessCount;
  final int totalAccessCount;
  final String? reminderTime;

  StatsModel({
    this.streak = 0,
    this.todayAccessCount = 0,
    this.totalAccessCount = 0,
    this.reminderTime,
  });

  // Create from JSON
  factory StatsModel.fromJson(Map<String, dynamic> json) {
    return StatsModel(
      streak: json['streak'] ?? 0,
      todayAccessCount: json['todayAccessCount'] ?? 0,
      totalAccessCount: json['totalAccessCount'] ?? 0,
      reminderTime: json['reminderTime'],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'streak': streak,
      'todayAccessCount': todayAccessCount,
      'totalAccessCount': totalAccessCount,
      'reminderTime': reminderTime,
    };
  }

  // Create a copy with updated values
  StatsModel copyWith({
    int? streak,
    int? todayAccessCount,
    int? totalAccessCount,
    String? reminderTime,
  }) {
    return StatsModel(
      streak: streak ?? this.streak,
      todayAccessCount: todayAccessCount ?? this.todayAccessCount,
      totalAccessCount: totalAccessCount ?? this.totalAccessCount,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }
}
