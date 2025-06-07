import 'package:flutter/material.dart';

enum HabitFrequency { daily, weekly, custom }

enum HabitType { good, bad }

class Habit {
  final String id;
  final String name;
  final HabitFrequency frequency;
  final HabitType type;
  final List<int>? customDays; // 1=Monday, 7=Sunday
  final String? linkedGoalId;
  final DateTime createdDate;
  final bool isActive;
  final Map<String, bool> completionHistory; // date string -> completed

  Habit({
    required this.id,
    required this.name,
    required this.frequency,
    required this.type,
    this.customDays,
    this.linkedGoalId,
    required this.createdDate,
    this.isActive = true,
    Map<String, bool>? completionHistory,
  }) : completionHistory = completionHistory ?? {};

  Habit copyWith({
    String? id,
    String? name,
    HabitFrequency? frequency,
    HabitType? type,
    List<int>? customDays,
    String? linkedGoalId,
    DateTime? createdDate,
    bool? isActive,
    Map<String, bool>? completionHistory,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      frequency: frequency ?? this.frequency,
      type: type ?? this.type,
      customDays: customDays ?? this.customDays,
      linkedGoalId: linkedGoalId ?? this.linkedGoalId,
      createdDate: createdDate ?? this.createdDate,
      isActive: isActive ?? this.isActive,
      completionHistory: completionHistory ?? this.completionHistory,
    );
  }

  bool get isScheduledForToday {
    final today = DateTime.now();
    final weekday = today.weekday; // 1=Monday, 7=Sunday
    
    switch (frequency) {
      case HabitFrequency.daily:
        return true;
      case HabitFrequency.weekly:
        return weekday == 1; // Monday
      case HabitFrequency.custom:
        return customDays?.contains(weekday) ?? false;
    }
  }

  bool get isCompletedToday {
    final today = _dateKey(DateTime.now());
    return completionHistory[today] ?? false;
  }

  int get currentStreak {
    int streak = 0;
    final today = DateTime.now();
    
    for (int i = 0; i < 365; i++) {
      final date = today.subtract(Duration(days: i));
      if (!_isScheduledForDate(date)) continue;
      
      final dateKey = _dateKey(date);
      if (completionHistory[dateKey] == true) {
        streak++;
      } else {
        break;
      }
    }
    
    return streak;
  }

  double get weeklyCompletionRate {
    final today = DateTime.now();
    int scheduledDays = 0;
    int completedDays = 0;
    
    for (int i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: i));
      if (_isScheduledForDate(date)) {
        scheduledDays++;
        final dateKey = _dateKey(date);
        if (completionHistory[dateKey] == true) {
          completedDays++;
        }
      }
    }
    
    return scheduledDays > 0 ? completedDays / scheduledDays : 0.0;
  }

  List<bool> get last7DaysCompletion {
    final today = DateTime.now();
    List<bool> completion = [];
    
    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      if (_isScheduledForDate(date)) {
        final dateKey = _dateKey(date);
        completion.add(completionHistory[dateKey] ?? false);
      } else {
        completion.add(false); // Not scheduled
      }
    }
    
    return completion;
  }

  bool _isScheduledForDate(DateTime date) {
    final weekday = date.weekday;
    
    switch (frequency) {
      case HabitFrequency.daily:
        return true;
      case HabitFrequency.weekly:
        return weekday == 1; // Monday
      case HabitFrequency.custom:
        return customDays?.contains(weekday) ?? false;
    }
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String get frequencyText {
    switch (frequency) {
      case HabitFrequency.daily:
        return 'Daily';
      case HabitFrequency.weekly:
        return 'Weekly';
      case HabitFrequency.custom:
        final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        final selectedDays = customDays?.map((day) => days[day - 1]).join(', ') ?? '';
        return selectedDays;
    }
  }

  String get typeText {
    switch (type) {
      case HabitType.good:
        return 'Good Habit';
      case HabitType.bad:
        return 'Bad Habit';
    }
  }

  String get habitMessage {
    switch (type) {
      case HabitType.good:
        return 'Good habits typically take 21-66 days to form. Stay consistent! 🌱';
      case HabitType.bad:
        return 'Breaking bad habits takes time and patience. You\'ve got this! 💪';
    }
  }

  Color get habitColor {
    switch (type) {
      case HabitType.good:
        return const Color(0xFF4CAF50); // Green for good habits
      case HabitType.bad:
        return const Color(0xFFFF5722); // Red-orange for bad habits
    }
  }
} 