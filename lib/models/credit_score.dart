import 'package:flutter/material.dart';

class CreditScore {
  final String id;
  final int score;
  final String provider; // FICO, VantageScore, etc.
  final DateTime date;
  final String? notes;

  CreditScore({
    required this.id,
    required this.score,
    required this.provider,
    required this.date,
    this.notes,
  });

  CreditScore copyWith({
    String? id,
    int? score,
    String? provider,
    DateTime? date,
    String? notes,
  }) {
    return CreditScore(
      id: id ?? this.id,
      score: score ?? this.score,
      provider: provider ?? this.provider,
      date: date ?? this.date,
      notes: notes ?? this.notes,
    );
  }

  String get creditRange {
    if (score >= 800) return 'Exceptional';
    if (score >= 740) return 'Very Good';
    if (score >= 670) return 'Good';
    if (score >= 580) return 'Fair';
    return 'Poor';
  }

  Color get rangeColor {
    if (score >= 800) return const Color(0xFF4CAF50); // Green
    if (score >= 740) return const Color(0xFF8BC34A); // Light Green
    if (score >= 670) return const Color(0xFFFFC107); // Amber
    if (score >= 580) return const Color(0xFFFF9800); // Orange
    return const Color(0xFFF44336); // Red
  }

  String get improvementTip {
    if (score >= 800) return 'Excellent! Maintain your great habits.';
    if (score >= 740) return 'Great score! Keep utilization low and payments on time.';
    if (score >= 670) return 'Good progress! Focus on reducing debt and avoiding new credit.';
    if (score >= 580) return 'Keep improving! Pay down balances and make all payments on time.';
    return 'Focus on payment history and reducing credit utilization below 30%.';
  }
}

class CreditGoal {
  final String id;
  final int targetScore;
  final DateTime targetDate;
  final String description;
  final bool isCompleted;
  final DateTime createdDate;

  CreditGoal({
    required this.id,
    required this.targetScore,
    required this.targetDate,
    required this.description,
    this.isCompleted = false,
    required this.createdDate,
  });

  CreditGoal copyWith({
    String? id,
    int? targetScore,
    DateTime? targetDate,
    String? description,
    bool? isCompleted,
    DateTime? createdDate,
  }) {
    return CreditGoal(
      id: id ?? this.id,
      targetScore: targetScore ?? this.targetScore,
      targetDate: targetDate ?? this.targetDate,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdDate: createdDate ?? this.createdDate,
    );
  }

  int daysUntilTarget() {
    return targetDate.difference(DateTime.now()).inDays;
  }

  bool get isOverdue {
    return DateTime.now().isAfter(targetDate) && !isCompleted;
  }
} 