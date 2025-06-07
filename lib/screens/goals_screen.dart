import 'package:flutter/material.dart';
import '../models/models.dart';

class GoalsScreen extends StatefulWidget {
  final List<Goal> goals;

  const GoalsScreen({super.key, required this.goals});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  bool _showCompleted = false;
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _checklistController = TextEditingController();
  
  GoalType _selectedType = GoalType.financial;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 30));
  List<String> _checklistItems = [];

  @override
  void dispose() {
    _titleController.dispose();
    _targetAmountController.dispose();
    _checklistController.dispose();
    super.dispose();
  }

  List<Goal> get _activeGoals => widget.goals.where((goal) => !goal.isCompleted).toList();
  List<Goal> get _completedGoals => widget.goals.where((goal) => goal.isCompleted).toList();

  void _addGoal() {
    if (_formKey.currentState!.validate()) {
      final goal = Goal(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        type: _selectedType,
        targetDate: _selectedDate,
        createdDate: DateTime.now(),
        targetAmount: _selectedType == GoalType.financial ? double.tryParse(_targetAmountController.text) : null,
        currentAmount: _selectedType == GoalType.financial ? 0.0 : null,
        checklist: _selectedType == GoalType.life ? List.from(_checklistItems) : null,
        checklistCompletion: _selectedType == GoalType.life 
            ? Map.fromEntries(_checklistItems.map((item) => MapEntry(item, false)))
            : null,
      );

      setState(() {
        widget.goals.add(goal);
      });

      _clearForm();
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Goal created successfully!'),
          backgroundColor: Color(0xFFFFC107),
        ),
      );
    }
  }

  void _clearForm() {
    _titleController.clear();
    _targetAmountController.clear();
    _checklistController.clear();
    _checklistItems.clear();
    _selectedType = GoalType.financial;
    _selectedDate = DateTime.now().add(const Duration(days: 30));
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _addChecklistItem() {
    if (_checklistController.text.isNotEmpty) {
      setState(() {
        _checklistItems.add(_checklistController.text);
        _checklistController.clear();
      });
    }
  }

  void _removeChecklistItem(int index) {
    setState(() {
      _checklistItems.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFFFC107); // Golden Amber
    final backgroundColor = primaryColor.withOpacity(0.05);
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Goals',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
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
            // Active Goals Section
            if (_activeGoals.isEmpty)
              _buildEmptyState(primaryColor)
            else
              ...[
                const Text(
                  'Active Goals',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ..._activeGoals.map((goal) => GoalCard(
                  goal: goal,
                  onTap: () => _showGoalDetails(goal),
                )),
              ],
            
            const SizedBox(height: 24),
            
            // Completed Goals Section
            if (_completedGoals.isNotEmpty) ...[
              InkWell(
                onTap: () => setState(() => _showCompleted = !_showCompleted),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _showCompleted ? Icons.expand_less : Icons.expand_more,
                        color: primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Completed Goals (${_completedGoals.length})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_showCompleted) ...[
                const SizedBox(height: 16),
                ..._completedGoals.map((goal) => GoalCard(
                  goal: goal,
                  onTap: () => _showGoalDetails(goal),
                )),
              ],
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddGoalDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Goal'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.black87,
      ),
    );
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
              Icons.track_changes,
              size: 64,
              color: primaryColor.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Goals Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first goal to start tracking your progress',
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

  void _showGoalDetails(Goal goal) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Goal details for: ${goal.title}')),
    );
  }

  void _showAddGoalDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _buildAddGoalForm(),
      ),
    );
  }

  Widget _buildAddGoalForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create New Goal',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              
              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Goal Title',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a goal title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Goal Type
              const Text('Goal Type', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<GoalType>(
                      title: const Text('💰 Financial'),
                      value: GoalType.financial,
                      groupValue: _selectedType,
                      onChanged: (value) => setState(() => _selectedType = value!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<GoalType>(
                      title: const Text('🎯 Life Goal'),
                      value: GoalType.life,
                      groupValue: _selectedType,
                      onChanged: (value) => setState(() => _selectedType = value!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Conditional Fields
              if (_selectedType == GoalType.financial) ...[
                TextFormField(
                  controller: _targetAmountController,
                  decoration: const InputDecoration(
                    labelText: 'Target Amount',
                    prefixText: '\$ ',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a target amount';
                    }
                    if (double.tryParse(value) == null || double.parse(value) <= 0) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                ),
              ] else ...[
                const Text('Checklist Items', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _checklistController,
                        decoration: const InputDecoration(
                          labelText: 'Add checklist item',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onFieldSubmitted: (_) => _addChecklistItem(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _addChecklistItem,
                      icon: const Icon(Icons.add),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC107),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_checklistItems.isNotEmpty) ...[
                  Container(
                    constraints: const BoxConstraints(maxHeight: 150),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _checklistItems.length,
                      itemBuilder: (context, index) => ListTile(
                        dense: true,
                        leading: const Icon(Icons.check_box_outline_blank),
                        title: Text(_checklistItems[index]),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeChecklistItem(index),
                        ),
                      ),
                    ),
                  ),
                ],
                if (_selectedType == GoalType.life && _checklistItems.isEmpty)
                  const Text(
                    'Add at least one checklist item',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
              ],
              const SizedBox(height: 16),
              
              // Target Date
              InkWell(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: 12),
                      Text(
                        'Target Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Create Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_selectedType == GoalType.life && _checklistItems.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please add at least one checklist item')),
                      );
                      return;
                    }
                    _addGoal();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC107),
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Create Goal',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

// Goal Card Widget
class GoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback? onTap;

  const GoalCard({
    super.key,
    required this.goal,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFFFC107);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
            border: goal.isOverdue
                ? Border.all(color: Colors.red.withOpacity(0.3), width: 2)
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Goal Type Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      goal.typeIcon,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Title
                  Expanded(
                    child: Text(
                      goal.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        decoration: goal.isCompleted 
                            ? TextDecoration.lineThrough 
                            : null,
                        color: goal.isCompleted 
                            ? Colors.grey[600] 
                            : Colors.black87,
                      ),
                    ),
                  ),
                  
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: goal.isCompleted 
                          ? Colors.green.withOpacity(0.1)
                          : goal.isOverdue 
                              ? Colors.red.withOpacity(0.1)
                              : primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      goal.statusText,
                      style: TextStyle(
                        color: goal.isCompleted 
                            ? Colors.green
                            : goal.isOverdue 
                                ? Colors.red
                                : primaryColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Progress Section
              if (goal.type == GoalType.financial) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${(goal.currentAmount ?? 0).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      'of \$${(goal.targetAmount ?? 0).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${goal.checklistCompletion?.values.where((completed) => completed).length ?? 0} completed',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      'of ${goal.checklist?.length ?? 0} tasks',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 8),
              
              // Progress Bar
              LinearProgressIndicator(
                value: goal.progress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  goal.isCompleted 
                      ? Colors.green 
                      : goal.progress < 0.3 
                          ? Colors.red 
                          : goal.progress < 0.7 
                              ? Colors.orange 
                              : Colors.green,
                ),
                minHeight: 6,
              ),
              
              const SizedBox(height: 12),
              
              // Footer Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(goal.progress * 100).toInt()}% complete',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 14,
                        color: goal.isOverdue ? Colors.red : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        goal.isOverdue 
                            ? 'Overdue'
                            : goal.daysRemaining == 0
                                ? 'Due today'
                                : '${goal.daysRemaining} days left',
                        style: TextStyle(
                          fontSize: 12,
                          color: goal.isOverdue ? Colors.red : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 