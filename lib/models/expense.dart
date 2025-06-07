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

class Expense {
  final String id;
  final double amount;
  final String category;
  final String note;
  final DateTime date;
  final MoodTag? moodTag;

  Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.note,
    required this.date,
    this.moodTag,
  });

  Expense copyWith({
    String? id,
    double? amount,
    String? category,
    String? note,
    DateTime? date,
    MoodTag? moodTag,
  }) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      note: note ?? this.note,
      date: date ?? this.date,
      moodTag: moodTag ?? this.moodTag,
    );
  }

  String get moodEmoji {
    switch (moodTag) {
      case MoodTag.happy:
        return '😊';
      case MoodTag.stressed:
        return '😰';
      case MoodTag.anxious:
        return '😟';
      case MoodTag.excited:
        return '🤩';
      case MoodTag.sad:
        return '😢';
      case MoodTag.neutral:
        return '😐';
      case MoodTag.overwhelmed:
        return '🤯';
      case MoodTag.confident:
        return '😎';
      case null:
        return '';
    }
  }

  String get moodText {
    switch (moodTag) {
      case MoodTag.happy:
        return 'Happy';
      case MoodTag.stressed:
        return 'Stressed';
      case MoodTag.anxious:
        return 'Anxious';
      case MoodTag.excited:
        return 'Excited';
      case MoodTag.sad:
        return 'Sad';
      case MoodTag.neutral:
        return 'Neutral';
      case MoodTag.overwhelmed:
        return 'Overwhelmed';
      case MoodTag.confident:
        return 'Confident';
      case null:
        return 'No mood';
    }
  }
} 