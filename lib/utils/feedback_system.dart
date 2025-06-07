import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum AchievementType {
  firstExpense,
  weeklyGoal,
  monthlyGoal,
  budgetStayed,
  streakMilestone,
  categoryGoal,
  moodTracking,
}

class Achievement {
  final AchievementType type;
  final String title;
  final String description;
  final String emoji;
  final Color color;

  const Achievement({
    required this.type,
    required this.title,
    required this.description,
    required this.emoji,
    required this.color,
  });
}

class FeedbackSystem {
  static const Map<AchievementType, Achievement> _achievements = {
    AchievementType.firstExpense: Achievement(
      type: AchievementType.firstExpense,
      title: 'First Step!',
      description: 'You logged your first expense!',
      emoji: '🎉',
      color: Color(0xFF4CAF50),
    ),
    AchievementType.weeklyGoal: Achievement(
      type: AchievementType.weeklyGoal,
      title: 'Week Champion!',
      description: 'You stayed within budget this week!',
      emoji: '🏆',
      color: Color(0xFFFFD700),
    ),
    AchievementType.monthlyGoal: Achievement(
      type: AchievementType.monthlyGoal,
      title: 'Monthly Master!',
      description: 'Amazing! You met your monthly budget goal!',
      emoji: '🌟',
      color: Color(0xFF9C27B0),
    ),
    AchievementType.budgetStayed: Achievement(
      type: AchievementType.budgetStayed,
      title: 'Budget Boss!',
      description: 'You stayed under budget today!',
      emoji: '💪',
      color: Color(0xFF2196F3),
    ),
    AchievementType.streakMilestone: Achievement(
      type: AchievementType.streakMilestone,
      title: 'Streak Star!',
      description: 'You\'ve logged expenses for 7 days straight!',
      emoji: '🔥',
      color: Color(0xFFFF5722),
    ),
    AchievementType.categoryGoal: Achievement(
      type: AchievementType.categoryGoal,
      title: 'Category Champion!',
      description: 'You stayed within your category budget!',
      emoji: '🎯',
      color: Color(0xFF00BCD4),
    ),
    AchievementType.moodTracking: Achievement(
      type: AchievementType.moodTracking,
      title: 'Mindful Spender!',
      description: 'You\'ve been tracking your mood with expenses!',
      emoji: '🧠',
      color: Color(0xFF8BC34A),
    ),
  };

  static Achievement? getAchievement(AchievementType type) {
    return _achievements[type];
  }

  static void showAchievement(BuildContext context, AchievementType type, {bool useHaptics = true}) {
    final achievement = _achievements[type];
    if (achievement == null) return;

    // Haptic feedback
    if (useHaptics) {
      HapticFeedback.lightImpact();
    }

    // Show achievement dialog
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AchievementDialog(achievement: achievement),
    );
  }

  static void showQuickFeedback(BuildContext context, String message, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Text('✨'),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color ?? const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static void celebrateSuccess(BuildContext context, String message) {
    HapticFeedback.mediumImpact();
    showQuickFeedback(context, message, color: const Color(0xFF4CAF50));
  }

  static void encourageProgress(BuildContext context, String message) {
    HapticFeedback.lightImpact();
    showQuickFeedback(context, message, color: const Color(0xFF2196F3));
  }
}

class AchievementDialog extends StatefulWidget {
  final Achievement achievement;

  const AchievementDialog({super.key, required this.achievement});

  @override
  State<AchievementDialog> createState() => _AchievementDialogState();
}

class _AchievementDialogState extends State<AchievementDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: widget.achievement.color.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Emoji with glow effect
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: widget.achievement.color.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widget.achievement.color.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          widget.achievement.emoji,
                          style: const TextStyle(fontSize: 40),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Title
                    Text(
                      widget.achievement.title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: widget.achievement.color,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    
                    // Description
                    Text(
                      widget.achievement.description,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    
                    // Close button
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.achievement.color,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Awesome!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
} 