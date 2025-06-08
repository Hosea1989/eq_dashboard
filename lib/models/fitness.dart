import 'package:flutter/material.dart';

enum WorkoutType {
  cardio,
  strength,
  flexibility,
  sports,
  walking,
  running,
  cycling,
  swimming,
  yoga,
  other
}

enum ActivityIntensity {
  light,
  moderate,
  vigorous
}

class FitnessActivity {
  final String id;
  final String name;
  final WorkoutType type;
  final int durationMinutes;
  final ActivityIntensity intensity;
  final DateTime date;
  final int? caloriesBurned;
  final String? notes;
  final MoodTag? moodBefore;
  final MoodTag? moodAfter;
  final int energyLevel; // 1-10 scale

  FitnessActivity({
    required this.id,
    required this.name,
    required this.type,
    required this.durationMinutes,
    required this.intensity,
    required this.date,
    this.caloriesBurned,
    this.notes,
    this.moodBefore,
    this.moodAfter,
    this.energyLevel = 5,
  });

  FitnessActivity copyWith({
    String? id,
    String? name,
    WorkoutType? type,
    int? durationMinutes,
    ActivityIntensity? intensity,
    DateTime? date,
    int? caloriesBurned,
    String? notes,
    MoodTag? moodBefore,
    MoodTag? moodAfter,
    int? energyLevel,
  }) {
    return FitnessActivity(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      intensity: intensity ?? this.intensity,
      date: date ?? this.date,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      notes: notes ?? this.notes,
      moodBefore: moodBefore ?? this.moodBefore,
      moodAfter: moodAfter ?? this.moodAfter,
      energyLevel: energyLevel ?? this.energyLevel,
    );
  }

  String get typeDisplayName {
    switch (type) {
      case WorkoutType.cardio:
        return 'Cardio';
      case WorkoutType.strength:
        return 'Strength';
      case WorkoutType.flexibility:
        return 'Flexibility';
      case WorkoutType.sports:
        return 'Sports';
      case WorkoutType.walking:
        return 'Walking';
      case WorkoutType.running:
        return 'Running';
      case WorkoutType.cycling:
        return 'Cycling';
      case WorkoutType.swimming:
        return 'Swimming';
      case WorkoutType.yoga:
        return 'Yoga';
      case WorkoutType.other:
        return 'Other';
    }
  }

  Color get typeColor {
    switch (type) {
      case WorkoutType.cardio:
        return const Color(0xFFE91E63); // Pink
      case WorkoutType.strength:
        return const Color(0xFF3F51B5); // Indigo
      case WorkoutType.flexibility:
        return const Color(0xFF4CAF50); // Green
      case WorkoutType.sports:
        return const Color(0xFFFF9800); // Orange
      case WorkoutType.walking:
        return const Color(0xFF2196F3); // Blue
      case WorkoutType.running:
        return const Color(0xFFF44336); // Red
      case WorkoutType.cycling:
        return const Color(0xFF9C27B0); // Purple
      case WorkoutType.swimming:
        return const Color(0xFF00BCD4); // Cyan
      case WorkoutType.yoga:
        return const Color(0xFF8BC34A); // Light Green
      case WorkoutType.other:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  IconData get typeIcon {
    switch (type) {
      case WorkoutType.cardio:
        return Icons.favorite;
      case WorkoutType.strength:
        return Icons.fitness_center;
      case WorkoutType.flexibility:
        return Icons.self_improvement;
      case WorkoutType.sports:
        return Icons.sports_basketball;
      case WorkoutType.walking:
        return Icons.directions_walk;
      case WorkoutType.running:
        return Icons.directions_run;
      case WorkoutType.cycling:
        return Icons.directions_bike;
      case WorkoutType.swimming:
        return Icons.pool;
      case WorkoutType.yoga:
        return Icons.spa;
      case WorkoutType.other:
        return Icons.fitness_center;
    }
  }

  String get intensityDisplayName {
    switch (intensity) {
      case ActivityIntensity.light:
        return 'Light';
      case ActivityIntensity.moderate:
        return 'Moderate';
      case ActivityIntensity.vigorous:
        return 'Vigorous';
    }
  }

  Color get intensityColor {
    switch (intensity) {
      case ActivityIntensity.light:
        return const Color(0xFF4CAF50); // Green
      case ActivityIntensity.moderate:
        return const Color(0xFFFF9800); // Orange
      case ActivityIntensity.vigorous:
        return const Color(0xFFF44336); // Red
    }
  }

  int get estimatedCalories {
    if (caloriesBurned != null) return caloriesBurned!;
    
    // Rough estimation based on activity type and duration
    double baseCaloriesPerMinute;
    switch (type) {
      case WorkoutType.running:
        baseCaloriesPerMinute = 12.0;
        break;
      case WorkoutType.cycling:
        baseCaloriesPerMinute = 8.0;
        break;
      case WorkoutType.swimming:
        baseCaloriesPerMinute = 10.0;
        break;
      case WorkoutType.strength:
        baseCaloriesPerMinute = 6.0;
        break;
      case WorkoutType.walking:
        baseCaloriesPerMinute = 4.0;
        break;
      case WorkoutType.yoga:
        baseCaloriesPerMinute = 3.0;
        break;
      default:
        baseCaloriesPerMinute = 5.0;
    }
    
    // Adjust for intensity
    double intensityMultiplier;
    switch (intensity) {
      case ActivityIntensity.light:
        intensityMultiplier = 0.7;
        break;
      case ActivityIntensity.moderate:
        intensityMultiplier = 1.0;
        break;
      case ActivityIntensity.vigorous:
        intensityMultiplier = 1.4;
        break;
    }
    
    return (baseCaloriesPerMinute * durationMinutes * intensityMultiplier).round();
  }
}

class FitnessGoal {
  final String id;
  final String title;
  final String description;
  final FitnessGoalType type;
  final int targetValue;
  final int currentValue;
  final DateTime targetDate;
  final DateTime createdDate;
  final bool isCompleted;

  FitnessGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.targetValue,
    this.currentValue = 0,
    required this.targetDate,
    required this.createdDate,
    this.isCompleted = false,
  });

  FitnessGoal copyWith({
    String? id,
    String? title,
    String? description,
    FitnessGoalType? type,
    int? targetValue,
    int? currentValue,
    DateTime? targetDate,
    DateTime? createdDate,
    bool? isCompleted,
  }) {
    return FitnessGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      targetDate: targetDate ?? this.targetDate,
      createdDate: createdDate ?? this.createdDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  double get progressPercentage {
    if (targetValue <= 0) return 0.0;
    return (currentValue / targetValue).clamp(0.0, 1.0);
  }

  int get daysRemaining {
    return targetDate.difference(DateTime.now()).inDays;
  }

  bool get isOverdue {
    return DateTime.now().isAfter(targetDate) && !isCompleted;
  }

  String get typeDisplayName {
    switch (type) {
      case FitnessGoalType.weeklyWorkouts:
        return 'Weekly Workouts';
      case FitnessGoalType.monthlyMinutes:
        return 'Monthly Minutes';
      case FitnessGoalType.dailySteps:
        return 'Daily Steps';
      case FitnessGoalType.weightLoss:
        return 'Weight Loss';
      case FitnessGoalType.strengthGain:
        return 'Strength Gain';
      case FitnessGoalType.consistency:
        return 'Consistency';
    }
  }

  String get unitLabel {
    switch (type) {
      case FitnessGoalType.weeklyWorkouts:
        return 'workouts';
      case FitnessGoalType.monthlyMinutes:
        return 'minutes';
      case FitnessGoalType.dailySteps:
        return 'steps';
      case FitnessGoalType.weightLoss:
        return 'lbs';
      case FitnessGoalType.strengthGain:
        return 'lbs';
      case FitnessGoalType.consistency:
        return 'days';
    }
  }
}

enum FitnessGoalType {
  weeklyWorkouts,
  monthlyMinutes,
  dailySteps,
  weightLoss,
  strengthGain,
  consistency
}

// Import MoodTag from expense model
enum MoodTag {
  happy,
  stressed,
  anxious,
  excited,
  sad,
  neutral,
  overwhelmed,
  confident
} 