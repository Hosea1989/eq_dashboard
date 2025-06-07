import 'package:flutter/material.dart';
import '../models/models.dart';

class HabitsScreen extends StatefulWidget {
  final List<Habit> habits;

  const HabitsScreen({super.key, required this.habits});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  HabitFrequency _selectedFrequency = HabitFrequency.daily;
  HabitType _selectedType = HabitType.good;
  List<int> _selectedCustomDays = [];
  String? _selectedGoalId;
  
  final List<String> _weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  List<Habit> get _activeHabits => widget.habits.where((habit) => habit.isActive).toList();
  List<Habit> get _todaysHabits => _activeHabits.where((habit) => habit.isScheduledForToday).toList();
  
  int get _todaysCompletedCount => _todaysHabits.where((habit) => habit.isCompletedToday).length;
  
  double get _todaysCompletionRate => 
      _todaysHabits.isEmpty ? 0.0 : _todaysCompletedCount / _todaysHabits.length;

  void _toggleHabitCompletion(Habit habit) {
    final today = DateTime.now();
    final dateKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    
    setState(() {
      habit.completionHistory[dateKey] = !habit.isCompletedToday;
    });
  }

  void _addHabit() {
    if (_formKey.currentState!.validate()) {
      final habit = Habit(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        frequency: _selectedFrequency,
        type: _selectedType,
        customDays: _selectedFrequency == HabitFrequency.custom ? List.from(_selectedCustomDays) : null,
        linkedGoalId: _selectedGoalId,
        createdDate: DateTime.now(),
      );

      setState(() {
        widget.habits.add(habit);
      });

      _clearForm();
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Habit created successfully! 🎉'),
          backgroundColor: Color(0xFFFF7043),
        ),
      );
    }
  }

  void _clearForm() {
    _nameController.clear();
    _selectedFrequency = HabitFrequency.daily;
    _selectedType = HabitType.good;
    _selectedCustomDays.clear();
    _selectedGoalId = null;
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFFF7043); // Energy Orange
    final backgroundColor = primaryColor.withOpacity(0.05);
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Habits',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Today's Progress Overview
            _buildTodaysOverview(primaryColor),
            const SizedBox(height: 20),
            
            // Today's Habits
            if (_todaysHabits.isNotEmpty) ...[
              const Text(
                'Today\'s Habits',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ..._todaysHabits.map((habit) => HabitCard(
                habit: habit,
                onToggle: () => _toggleHabitCompletion(habit),
                showToday: true,
              )),
              const SizedBox(height: 24),
            ],
            
            // All Active Habits
            if (_activeHabits.isNotEmpty) ...[
              const Text(
                'All Habits',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ..._activeHabits.map((habit) => HabitCard(
                habit: habit,
                onToggle: () => _toggleHabitCompletion(habit),
                showToday: false,
              )),
            ] else
              _buildEmptyState(primaryColor),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddHabitDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Habit'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildTodaysOverview(Color primaryColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
                    'Today\'s Progress',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_todaysCompletedCount of ${_todaysHabits.length} completed',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              // Circular Progress
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  value: _todaysCompletionRate,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Motivational Message
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _getMotivationalMessage(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  String _getMotivationalMessage() {
    if (_todaysHabits.isEmpty) {
      return 'No habits scheduled for today. Take a rest! 😌';
    } else if (_todaysCompletionRate == 1.0) {
      return 'Amazing! You\'ve completed all your habits today! 🎉';
    } else if (_todaysCompletionRate >= 0.7) {
      return 'Great progress! You\'re almost there! 💪';
    } else if (_todaysCompletionRate >= 0.3) {
      return 'Keep going! Every small step counts! 🌟';
    } else {
      return 'Start with one habit. You\'ve got this! 🚀';
    }
  }

  Widget _buildEmptyState(Color primaryColor) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.psychology,
              size: 64,
              color: primaryColor.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Habits Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first habit to start building positive routines',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddHabitDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _buildAddHabitForm(),
      ),
    );
  }

  Widget _buildAddHabitForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create New Habit',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              
              // Habit Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Habit Name',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a habit name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Habit Type Selection
              const Text('Habit Type', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Column(
                children: [
                  RadioListTile<HabitType>(
                    title: Row(
                      children: [
                        const Icon(Icons.trending_up, color: Color(0xFF4CAF50), size: 20),
                        const SizedBox(width: 8),
                        const Text('Good Habit'),
                      ],
                    ),
                    subtitle: const Text('Building positive behaviors'),
                    value: HabitType.good,
                    groupValue: _selectedType,
                    onChanged: (value) => setState(() => _selectedType = value!),
                  ),
                  RadioListTile<HabitType>(
                    title: Row(
                      children: [
                        const Icon(Icons.trending_down, color: Color(0xFFFF5722), size: 20),
                        const SizedBox(width: 8),
                        const Text('Bad Habit'),
                      ],
                    ),
                    subtitle: const Text('Breaking negative behaviors'),
                    value: HabitType.bad,
                    groupValue: _selectedType,
                    onChanged: (value) => setState(() => _selectedType = value!),
                  ),
                ],
              ),
              
              // Habit Type Message
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _selectedType == HabitType.good 
                      ? const Color(0xFF4CAF50).withOpacity(0.1)
                      : const Color(0xFFFF5722).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _selectedType == HabitType.good 
                        ? const Color(0xFF4CAF50).withOpacity(0.3)
                        : const Color(0xFFFF5722).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _selectedType == HabitType.good ? Icons.lightbulb : Icons.info,
                      color: _selectedType == HabitType.good 
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFFF5722),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _selectedType == HabitType.good
                            ? 'Good habits typically take 21-66 days to form. Stay consistent! 🌱'
                            : 'Breaking bad habits takes time and patience. You\'ve got this! 💪',
                        style: TextStyle(
                          fontSize: 12,
                          color: _selectedType == HabitType.good 
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFFFF5722),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Frequency Selection
              const Text('Frequency', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Column(
                children: [
                  RadioListTile<HabitFrequency>(
                    title: const Text('Daily'),
                    value: HabitFrequency.daily,
                    groupValue: _selectedFrequency,
                    onChanged: (value) => setState(() => _selectedFrequency = value!),
                  ),
                  RadioListTile<HabitFrequency>(
                    title: const Text('Weekly (Mondays)'),
                    value: HabitFrequency.weekly,
                    groupValue: _selectedFrequency,
                    onChanged: (value) => setState(() => _selectedFrequency = value!),
                  ),
                  RadioListTile<HabitFrequency>(
                    title: const Text('Custom Days'),
                    value: HabitFrequency.custom,
                    groupValue: _selectedFrequency,
                    onChanged: (value) => setState(() => _selectedFrequency = value!),
                  ),
                ],
              ),
              
              // Custom Days Selection
              if (_selectedFrequency == HabitFrequency.custom) ...[
                const SizedBox(height: 8),
                const Text('Select Days', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: List.generate(7, (index) {
                    final dayNumber = index + 1;
                    final isSelected = _selectedCustomDays.contains(dayNumber);
                    
                    return FilterChip(
                      label: Text(_weekDays[index]),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedCustomDays.add(dayNumber);
                          } else {
                            _selectedCustomDays.remove(dayNumber);
                          }
                        });
                      },
                      selectedColor: const Color(0xFFFF7043).withOpacity(0.3),
                    );
                  }),
                ),
                if (_selectedFrequency == HabitFrequency.custom && _selectedCustomDays.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Please select at least one day',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
              ],
              
              const SizedBox(height: 16),
              
              // Link to Goal (Optional)
              const Text('Link to Goal (Optional)', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              const Text(
                'Goal linking will be available when you have created goals',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              
              const SizedBox(height: 24),
              
              // Create Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_selectedFrequency == HabitFrequency.custom && _selectedCustomDays.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select at least one day for custom frequency')),
                      );
                      return;
                    }
                    _addHabit();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedType == HabitType.good 
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFFF5722),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    _selectedType == HabitType.good 
                        ? 'Create Good Habit'
                        : 'Create Bad Habit to Break',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Habit Card Widget
class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback? onToggle;
  final bool showToday;

  const HabitCard({
    super.key,
    required this.habit,
    this.onToggle,
    this.showToday = false,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = habit.habitColor;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primaryColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                // Checkbox for today's completion
                if (showToday && habit.isScheduledForToday)
                  GestureDetector(
                    onTap: onToggle,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: habit.isCompletedToday ? primaryColor : Colors.transparent,
                        border: Border.all(
                          color: habit.isCompletedToday ? primaryColor : Colors.grey,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: habit.isCompletedToday
                          ? const Icon(Icons.check, color: Colors.white, size: 16)
                          : null,
                    ),
                  ),
                
                if (showToday && habit.isScheduledForToday) const SizedBox(width: 12),
                
                // Habit Name and Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              habit.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                decoration: (showToday && habit.isCompletedToday) 
                                    ? TextDecoration.lineThrough 
                                    : null,
                                color: (showToday && habit.isCompletedToday) 
                                    ? Colors.grey[600] 
                                    : Colors.black87,
                              ),
                            ),
                          ),
                          // Habit Type Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: primaryColor.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  habit.type == HabitType.good 
                                      ? Icons.trending_up 
                                      : Icons.trending_down,
                                  color: primaryColor,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  habit.typeText,
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        habit.frequencyText,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Streak Badge
                if (habit.currentStreak > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                        Text(
                          '${habit.currentStreak}',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Habit Message
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                habit.habitMessage,
                style: TextStyle(
                  fontSize: 11,
                  color: primaryColor,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Progress Section
            Row(
              children: [
                // Weekly completion rate
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'This Week',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(habit.weeklyCompletionRate * 100).toInt()}% complete',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 7-day heatmap
                Row(
                  children: habit.last7DaysCompletion.asMap().entries.map((entry) {
                    final index = entry.key;
                    final completed = entry.value;
                    
                    return Container(
                      margin: EdgeInsets.only(left: index > 0 ? 2 : 0),
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: completed 
                            ? primaryColor 
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Progress Bar
            LinearProgressIndicator(
              value: habit.weeklyCompletionRate,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                habit.weeklyCompletionRate >= 0.8 
                    ? Colors.green 
                    : habit.weeklyCompletionRate >= 0.5 
                        ? primaryColor 
                        : Colors.red,
              ),
              minHeight: 4,
            ),
            
            const SizedBox(height: 12),
            
            // Footer Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Streak info
                if (habit.currentStreak > 0)
                  Text(
                    habit.type == HabitType.good 
                        ? '${habit.currentStreak} day streak! 🎉'
                        : '${habit.currentStreak} days without! 💪',
                    style: TextStyle(
                      fontSize: 12,
                      color: primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else
                  Text(
                    habit.type == HabitType.good 
                        ? 'Start your streak today!'
                        : 'Start breaking this habit!',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                
                // Today's status
                if (showToday)
                  Text(
                    habit.isCompletedToday ? 'Completed ✅' : 'Pending',
                    style: TextStyle(
                      fontSize: 12,
                      color: habit.isCompletedToday ? Colors.green : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 