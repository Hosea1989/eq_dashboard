import 'package:flutter/material.dart';
import '../utils/theme_manager.dart';
import '../utils/feedback_system.dart';

class ReminderWidget extends StatefulWidget {
  final List<dynamic> expenses;
  final VoidCallback onAddExpense;

  const ReminderWidget({
    super.key,
    required this.expenses,
    required this.onAddExpense,
  });

  @override
  State<ReminderWidget> createState() => _ReminderWidgetState();
}

class _ReminderWidgetState extends State<ReminderWidget> {
  bool _isDismissed = false;

  @override
  Widget build(BuildContext context) {
    if (_isDismissed || !_shouldShowReminder()) {
      return const SizedBox.shrink();
    }

    final theme = AppThemeManager.themeData;
    final reminderData = _getReminderData();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(theme.borderRadius),
        border: Border.all(color: theme.primaryColor.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  reminderData['icon'] as IconData,
                  color: theme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminderData['title'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reminderData['message'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _isDismissed = true;
                  });
                },
                icon: Icon(
                  Icons.close,
                  color: theme.textSecondary,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _isDismissed = true;
                    });
                    FeedbackSystem.encourageProgress(context, 'Reminder dismissed');
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: theme.borderColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(theme.borderRadius),
                    ),
                  ),
                  child: Text(
                    'Later',
                    style: TextStyle(color: theme.textSecondary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onAddExpense();
                    setState(() {
                      _isDismissed = true;
                    });
                    FeedbackSystem.encourageProgress(context, 'Great! Let\'s add an expense');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(theme.borderRadius),
                    ),
                  ),
                  child: const Text('Add Expense'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _shouldShowReminder() {
    final now = DateTime.now();
    
    // Don't show if user has added expenses today
    final todayExpenses = widget.expenses.where((expense) {
      final expenseDate = expense.date as DateTime;
      return expenseDate.year == now.year &&
             expenseDate.month == now.month &&
             expenseDate.day == now.day;
    }).toList();

    if (todayExpenses.isNotEmpty) return false;

    // Show reminder if it's been more than 2 days since last expense
    if (widget.expenses.isEmpty) return true;

    final lastExpense = widget.expenses.first;
    final lastExpenseDate = lastExpense.date as DateTime;
    final daysSinceLastExpense = now.difference(lastExpenseDate).inDays;

    return daysSinceLastExpense >= 2;
  }

  Map<String, dynamic> _getReminderData() {
    final now = DateTime.now();
    final hour = now.hour;

    if (widget.expenses.isEmpty) {
      return {
        'icon': Icons.rocket_launch,
        'title': 'Ready to start tracking?',
        'message': 'Begin your financial journey by logging your first expense. Every small step counts!',
      };
    }

    if (hour < 12) {
      return {
        'icon': Icons.wb_sunny,
        'title': 'Good morning!',
        'message': 'Starting the day with expense tracking helps build healthy financial habits.',
      };
    } else if (hour < 17) {
      return {
        'icon': Icons.schedule,
        'title': 'Afternoon check-in',
        'message': 'How\'s your spending going today? A quick log helps you stay on track.',
      };
    } else {
      return {
        'icon': Icons.nightlight_round,
        'title': 'Evening reflection',
        'message': 'Take a moment to log today\'s expenses. You\'re building great habits!',
      };
    }
  }
}

class CheckInPrompt extends StatelessWidget {
  final String message;
  final VoidCallback onCheckIn;
  final VoidCallback? onDismiss;

  const CheckInPrompt({
    super.key,
    required this.message,
    required this.onCheckIn,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeManager.themeData;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.successColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(theme.borderRadius),
        border: Border.all(color: theme.successColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: theme.successColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: onCheckIn,
            child: Text(
              'Check In',
              style: TextStyle(
                color: theme.successColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (onDismiss != null)
            IconButton(
              onPressed: onDismiss,
              icon: Icon(
                Icons.close,
                color: theme.textSecondary,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}

class StreakWidget extends StatelessWidget {
  final int streakDays;
  final String streakType;

  const StreakWidget({
    super.key,
    required this.streakDays,
    required this.streakType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeManager.themeData;

    if (streakDays == 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primaryColor.withOpacity(0.1),
            theme.secondaryColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(theme.borderRadius),
        border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Text(
              '🔥',
              style: TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$streakDays Day Streak!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.textPrimary,
                  ),
                ),
                Text(
                  'Keep up your $streakType tracking momentum!',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.primaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$streakDays',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 