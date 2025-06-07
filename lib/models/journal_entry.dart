enum Mood { sad, neutral, happy, excited }

class JournalEntry {
  final String id;
  final String content;
  final DateTime date;
  final List<String> tags;
  final Mood? mood;

  JournalEntry({
    required this.id,
    required this.content,
    required this.date,
    this.tags = const [],
    this.mood,
  });

  JournalEntry copyWith({
    String? id,
    String? content,
    DateTime? date,
    List<String>? tags,
    Mood? mood,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      content: content ?? this.content,
      date: date ?? this.date,
      tags: tags ?? this.tags,
      mood: mood ?? this.mood,
    );
  }

  String get moodEmoji {
    switch (mood) {
      case Mood.sad:
        return '😞';
      case Mood.neutral:
        return '😐';
      case Mood.happy:
        return '🙂';
      case Mood.excited:
        return '😄';
      case null:
        return '';
    }
  }

  String get preview {
    const maxLength = 100;
    if (content.length <= maxLength) return content;
    return '${content.substring(0, maxLength)}...';
  }

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today ${_formatTime(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday ${_formatTime(date)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
} 