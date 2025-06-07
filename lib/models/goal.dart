enum GoalType { financial, life }

class Goal {
  final String id;
  final String title;
  final GoalType type;
  final double? targetAmount;
  final double? currentAmount;
  final List<String>? checklist;
  final Map<String, bool>? checklistCompletion;
  final DateTime createdDate;
  final DateTime? targetDate;
  final bool isCompleted;

  Goal({
    required this.id,
    required this.title,
    required this.type,
    this.targetAmount,
    this.currentAmount,
    this.checklist,
    this.checklistCompletion,
    required this.createdDate,
    this.targetDate,
    this.isCompleted = false,
  });

  Goal copyWith({
    String? id,
    String? title,
    GoalType? type,
    double? targetAmount,
    double? currentAmount,
    List<String>? checklist,
    Map<String, bool>? checklistCompletion,
    DateTime? createdDate,
    DateTime? targetDate,
    bool? isCompleted,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      checklist: checklist ?? this.checklist,
      checklistCompletion: checklistCompletion ?? this.checklistCompletion,
      createdDate: createdDate ?? this.createdDate,
      targetDate: targetDate ?? this.targetDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  double get progress {
    if (type == GoalType.financial && targetAmount != null && targetAmount! > 0) {
      return (currentAmount ?? 0) / targetAmount!;
    } else if (type == GoalType.life && checklist != null && checklist!.isNotEmpty) {
      final completedItems = checklistCompletion?.values.where((completed) => completed).length ?? 0;
      return completedItems / checklist!.length;
    }
    return 0.0;
  }

  bool get isOverdue {
    if (targetDate == null || isCompleted) return false;
    return DateTime.now().isAfter(targetDate!);
  }

  int get daysRemaining {
    if (targetDate == null || isCompleted) return 0;
    final difference = targetDate!.difference(DateTime.now());
    return difference.inDays;
  }

  String get typeIcon {
    switch (type) {
      case GoalType.financial:
        return '💰';
      case GoalType.life:
        return '🎯';
    }
  }

  String get statusText {
    if (isCompleted) return 'Completed';
    if (isOverdue) return 'Overdue';
    if (daysRemaining <= 7) return 'Due soon';
    return 'In progress';
  }
} 