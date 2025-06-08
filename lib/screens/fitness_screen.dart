import 'package:flutter/material.dart';
import '../models/fitness.dart';
import '../utils/theme_manager.dart';
import '../utils/feedback_system.dart';

class FitnessScreen extends StatefulWidget {
  final List<FitnessActivity> activities;
  final List<FitnessGoal> fitnessGoals;

  const FitnessScreen({
    super.key,
    required this.activities,
    required this.fitnessGoals,
  });

  @override
  State<FitnessScreen> createState() => _FitnessScreenState();
}

class _FitnessScreenState extends State<FitnessScreen> {
  final _activityNameController = TextEditingController();
  final _durationController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _notesController = TextEditingController();
  
  WorkoutType _selectedWorkoutType = WorkoutType.walking;
  ActivityIntensity _selectedIntensity = ActivityIntensity.moderate;
  int _energyLevel = 5;
  MoodTag? _moodBefore;
  MoodTag? _moodAfter;

  @override
  void dispose() {
    _activityNameController.dispose();
    _durationController.dispose();
    _caloriesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  int get _totalWorkoutsThisWeek {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return widget.activities.where((activity) => 
        activity.date.isAfter(weekStart) && 
        activity.date.isBefore(now.add(const Duration(days: 1)))
    ).length;
  }

  int get _totalMinutesThisMonth {
    final now = DateTime.now();
    return widget.activities.where((activity) => 
        activity.date.year == now.year && 
        activity.date.month == now.month
    ).fold(0, (sum, activity) => sum + activity.durationMinutes);
  }

  int get _totalCaloriesThisWeek {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return widget.activities.where((activity) => 
        activity.date.isAfter(weekStart) && 
        activity.date.isBefore(now.add(const Duration(days: 1)))
    ).fold(0, (sum, activity) => sum + activity.estimatedCalories);
  }

  int get _currentStreak {
    if (widget.activities.isEmpty) return 0;
    
    final sortedActivities = List<FitnessActivity>.from(widget.activities)
      ..sort((a, b) => b.date.compareTo(a.date));
    
    int streak = 0;
    DateTime currentDate = DateTime.now();
    
    for (final activity in sortedActivities) {
      final daysDiff = currentDate.difference(activity.date).inDays;
      if (daysDiff <= 1) {
        streak++;
        currentDate = activity.date;
      } else {
        break;
      }
    }
    
    return streak;
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeManager.themeData;
    
    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fitness Overview Card
            _buildFitnessOverviewCard(theme),
            const SizedBox(height: 20),
            
            // Quick Stats
            _buildQuickStatsCard(theme),
            const SizedBox(height: 20),
            
            // Fitness Goals
            _buildFitnessGoalsCard(theme),
            const SizedBox(height: 20),
            
            // Recent Activities
            _buildRecentActivitiesCard(theme),
            const SizedBox(height: 20),
            
            // Motivation Section
            _buildMotivationCard(theme),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddActivityDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Log Workout'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildFitnessOverviewCard(AppThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primaryColor,
            theme.primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(theme.borderRadius),
        boxShadow: theme.useGradients ? [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.3),
            blurRadius: theme.elevation * 2,
            offset: const Offset(0, 4),
          ),
        ] : null,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fitness Journey',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Keep moving forward! 💪',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.fitness_center,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Current Streak
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.local_fire_department,
                  color: Colors.orange,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  '$_currentStreak Day Streak!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsCard(AppThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(theme.borderRadius),
        border: Border.all(color: theme.borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This Week\'s Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Workouts',
                  '$_totalWorkoutsThisWeek',
                  Icons.fitness_center,
                  const Color(0xFF4CAF50),
                  theme,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Minutes',
                  '$_totalMinutesThisMonth',
                  Icons.timer,
                  const Color(0xFF2196F3),
                  theme,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Calories',
                  '$_totalCaloriesThisWeek',
                  Icons.local_fire_department,
                  const Color(0xFFFF9800),
                  theme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color, AppThemeData theme) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: theme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildFitnessGoalsCard(AppThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(theme.borderRadius),
        border: Border.all(color: theme.borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Fitness Goals',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () => _showAddGoalDialog(),
                child: Text(
                  'Add Goal',
                  style: TextStyle(color: theme.primaryColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (widget.fitnessGoals.isEmpty) ...[
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.track_changes,
                    size: 48,
                    color: theme.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No fitness goals yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Set a goal to track your progress!',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            ...widget.fitnessGoals.take(3).map((goal) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: goal.isCompleted 
                      ? theme.successColor.withOpacity(0.1)
                      : theme.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: goal.isCompleted 
                        ? theme.successColor.withOpacity(0.3)
                        : theme.borderColor,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            goal.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          '${goal.currentValue}/${goal.targetValue} ${goal.unitLabel}',
                          style: TextStyle(
                            color: theme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: goal.progressPercentage,
                      backgroundColor: theme.borderColor,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        goal.isCompleted ? theme.successColor : theme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      goal.isCompleted 
                          ? 'Completed! 🎉'
                          : '${goal.daysRemaining} days remaining',
                      style: TextStyle(
                        color: goal.isCompleted ? theme.successColor : theme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            )).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildRecentActivitiesCard(AppThemeData theme) {
    final recentActivities = widget.activities.take(5).toList();
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(theme.borderRadius),
        border: Border.all(color: theme.borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activities',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          if (recentActivities.isEmpty) ...[
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.directions_run,
                    size: 48,
                    color: theme.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No activities yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Log your first workout to get started!',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            ...recentActivities.map((activity) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: activity.typeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: activity.typeColor.withOpacity(0.3)),
                    ),
                    child: Icon(
                      activity.typeIcon,
                      color: activity.typeColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.textPrimary,
                          ),
                        ),
                        Text(
                          '${activity.durationMinutes} min • ${activity.intensityDisplayName} • ${activity.estimatedCalories} cal',
                          style: TextStyle(
                            color: theme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  Text(
                    _formatDate(activity.date),
                    style: TextStyle(
                      color: theme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildMotivationCard(AppThemeData theme) {
    final motivationalMessages = [
      "Every workout counts! 💪",
      "You're stronger than yesterday! 🔥",
      "Progress, not perfection! ⭐",
      "Your body can do it. It's your mind you need to convince! 🧠",
      "The only bad workout is the one you didn't do! 🏃‍♀️",
      "Believe in yourself and you're halfway there! ✨",
    ];
    
    final randomMessage = motivationalMessages[DateTime.now().day % motivationalMessages.length];
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.successColor.withOpacity(0.1),
            theme.primaryColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(theme.borderRadius),
        border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.emoji_events,
            color: theme.primaryColor,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            'Daily Motivation',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            randomMessage,
            style: TextStyle(
              fontSize: 16,
              color: theme.primaryColor,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return '${difference}d ago';
    return '${date.month}/${date.day}';
  }

  void _showAddActivityDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: AppThemeManager.themeData.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _buildAddActivityForm(),
      ),
    );
  }

  Widget _buildAddActivityForm() {
    final theme = AppThemeManager.themeData;
    
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Log Workout',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Activity name
                  TextFormField(
                    controller: _activityNameController,
                    decoration: InputDecoration(
                      labelText: 'Activity Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(theme.borderRadius),
                      ),
                      filled: true,
                      fillColor: theme.surfaceColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Workout type
                  DropdownButtonFormField<WorkoutType>(
                    value: _selectedWorkoutType,
                    decoration: InputDecoration(
                      labelText: 'Workout Type',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(theme.borderRadius),
                      ),
                      filled: true,
                      fillColor: theme.surfaceColor,
                    ),
                    items: WorkoutType.values.map((type) => DropdownMenuItem(
                      value: type,
                      child: Row(
                        children: [
                          Icon(
                            _getWorkoutIcon(type),
                            color: _getWorkoutColor(type),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(_getWorkoutDisplayName(type)),
                        ],
                      ),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedWorkoutType = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Duration and intensity
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _durationController,
                          decoration: InputDecoration(
                            labelText: 'Duration (minutes)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(theme.borderRadius),
                            ),
                            filled: true,
                            fillColor: theme.surfaceColor,
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<ActivityIntensity>(
                          value: _selectedIntensity,
                          decoration: InputDecoration(
                            labelText: 'Intensity',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(theme.borderRadius),
                            ),
                            filled: true,
                            fillColor: theme.surfaceColor,
                          ),
                          items: ActivityIntensity.values.map((intensity) => DropdownMenuItem(
                            value: intensity,
                            child: Text(_getIntensityDisplayName(intensity)),
                          )).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedIntensity = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Energy level slider
                  Text(
                    'Energy Level: $_energyLevel/10',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: theme.textPrimary,
                    ),
                  ),
                  Slider(
                    value: _energyLevel.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    activeColor: theme.primaryColor,
                    onChanged: (value) {
                      setState(() {
                        _energyLevel = value.round();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Notes
                  TextFormField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      labelText: 'Notes (optional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(theme.borderRadius),
                      ),
                      filled: true,
                      fillColor: theme.surfaceColor,
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Add button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _addActivity(),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(theme.borderRadius),
                ),
              ),
              child: const Text(
                'Log Activity',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addActivity() {
    if (_activityNameController.text.isEmpty || _durationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in activity name and duration')),
      );
      return;
    }

    final activity = FitnessActivity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _activityNameController.text,
      type: _selectedWorkoutType,
      durationMinutes: int.tryParse(_durationController.text) ?? 0,
      intensity: _selectedIntensity,
      date: DateTime.now(),
      caloriesBurned: int.tryParse(_caloriesController.text),
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      energyLevel: _energyLevel,
    );

    setState(() {
      widget.activities.insert(0, activity);
    });

    // Clear form
    _activityNameController.clear();
    _durationController.clear();
    _caloriesController.clear();
    _notesController.clear();
    _energyLevel = 5;

    Navigator.pop(context);
    
    FeedbackSystem.celebrateSuccess(context, 'Great workout! Keep up the momentum! 💪');
  }

  void _showAddGoalDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitness goal feature coming soon!')),
    );
  }

  IconData _getWorkoutIcon(WorkoutType type) {
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

  Color _getWorkoutColor(WorkoutType type) {
    switch (type) {
      case WorkoutType.cardio:
        return const Color(0xFFE91E63);
      case WorkoutType.strength:
        return const Color(0xFF3F51B5);
      case WorkoutType.flexibility:
        return const Color(0xFF4CAF50);
      case WorkoutType.sports:
        return const Color(0xFFFF9800);
      case WorkoutType.walking:
        return const Color(0xFF2196F3);
      case WorkoutType.running:
        return const Color(0xFFF44336);
      case WorkoutType.cycling:
        return const Color(0xFF9C27B0);
      case WorkoutType.swimming:
        return const Color(0xFF00BCD4);
      case WorkoutType.yoga:
        return const Color(0xFF8BC34A);
      case WorkoutType.other:
        return const Color(0xFF9E9E9E);
    }
  }

  String _getWorkoutDisplayName(WorkoutType type) {
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

  String _getIntensityDisplayName(ActivityIntensity intensity) {
    switch (intensity) {
      case ActivityIntensity.light:
        return 'Light';
      case ActivityIntensity.moderate:
        return 'Moderate';
      case ActivityIntensity.vigorous:
        return 'Vigorous';
    }
  }
} 