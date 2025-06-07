import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../utils/theme_manager.dart';
import '../utils/expense_templates.dart';
import '../utils/feedback_system.dart';

class BudgetScreen extends StatefulWidget {
  final List<Expense> expenses;
  final Function(Expense) onExpenseAdded;

  const BudgetScreen({
    super.key,
    required this.expenses,
    required this.onExpenseAdded,
  });

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  
  String _selectedCategory = 'Food';
  DateTime _selectedDate = DateTime.now();
  MoodTag? _selectedMood;
  
  // Budget settings - can be customized
  double _monthlyBudget = 1000.0;
  final Map<String, double> _categoryBudgets = {
    'Food': 300.0,
    'Transport': 150.0,
    'Bills': 200.0,
    'Entertainment': 100.0,
    'Shopping': 150.0,
    'Health': 100.0,
    'Other': 100.0,
  };
  
  final List<String> _categories = [
    'Food',
    'Transport',
    'Bills',
    'Entertainment',
    'Shopping',
    'Health',
    'Other'
  ];

  bool _showQuickAdd = true;
  bool _showMoodTracking = true;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _addExpense({ExpenseTemplate? template}) {
    if (template != null) {
      // Quick add from template
      final expense = Expense(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: template.amount,
        category: template.category,
        note: template.note,
        date: DateTime.now(),
        moodTag: _selectedMood,
      );

      widget.onExpenseAdded(expense);
      
      // Check for achievements
      _checkAchievements(expense);
      
      FeedbackSystem.celebrateSuccess(context, 'Added ${template.name} - \$${template.amount}');
      
      // Reset mood after adding
      setState(() {
        _selectedMood = null;
      });
    } else if (_formKey.currentState!.validate()) {
      // Manual add
      final expense = Expense(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: double.parse(_amountController.text),
        category: _selectedCategory,
        note: _noteController.text,
        date: _selectedDate,
        moodTag: _selectedMood,
      );

      widget.onExpenseAdded(expense);
      
      // Check for achievements
      _checkAchievements(expense);

      _amountController.clear();
      _noteController.clear();
      _selectedDate = DateTime.now();
      _selectedMood = null;
      
      Navigator.pop(context);
      
      FeedbackSystem.celebrateSuccess(context, 'Expense added successfully!');
    }
  }

  void _checkAchievements(Expense expense) {
    // First expense achievement
    if (widget.expenses.length == 1) {
      FeedbackSystem.showAchievement(context, AchievementType.firstExpense);
    }
    
    // Mood tracking achievement
    if (expense.moodTag != null && _getMoodTrackingCount() >= 5) {
      FeedbackSystem.showAchievement(context, AchievementType.moodTracking);
    }
    
    // Budget staying achievement
    if (_remainingBudget > 0) {
      FeedbackSystem.showAchievement(context, AchievementType.budgetStayed);
    }
  }

  int _getMoodTrackingCount() {
    return widget.expenses.where((e) => e.moodTag != null).length;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  double get _totalExpenses {
    return widget.expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double get _monthlyExpenses {
    final now = DateTime.now();
    final thisMonth = widget.expenses.where((expense) =>
        expense.date.year == now.year && expense.date.month == now.month);
    return thisMonth.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double get _remainingBudget {
    return _monthlyBudget - _monthlyExpenses;
  }

  double get _budgetUsedPercentage {
    if (_monthlyBudget <= 0) return 0.0;
    return (_monthlyExpenses / _monthlyBudget).clamp(0.0, 1.0);
  }

  Color get _budgetColor {
    final percentage = _budgetUsedPercentage;
    if (percentage < 0.5) return Colors.green;
    if (percentage < 0.9) return Colors.orange;
    return Colors.red;
  }

  double get _dailySpendingLimit {
    if (_monthlyBudget <= 0) return 0.0;
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysRemaining = daysInMonth - now.day + 1;
    if (daysRemaining <= 0) return 0;
    return _remainingBudget / daysRemaining;
  }

  Map<String, double> get _categoryExpenses {
    final now = DateTime.now();
    final thisMonth = widget.expenses.where((expense) =>
        expense.date.year == now.year && expense.date.month == now.month);
    
    Map<String, double> categoryTotals = {};
    for (String category in _categories) {
      categoryTotals[category] = 0.0;
    }
    
    for (var expense in thisMonth) {
      categoryTotals[expense.category] = 
          (categoryTotals[expense.category] ?? 0.0) + expense.amount;
    }
    
    return categoryTotals;
  }

  String get _budgetInsight {
    if (_monthlyBudget <= 0) {
      return "Set up your monthly budget to start tracking your spending progress.";
    }
    
    final percentage = _budgetUsedPercentage;
    if (percentage < 0.5) {
      return "Great job! You're staying within budget this month.";
    } else if (percentage < 0.9) {
      return "You've used ${(percentage * 100).toInt()}% of your monthly budget. Watch your spending!";
    } else if (percentage < 1.0) {
      return "Warning: You're close to exceeding your monthly budget!";
    } else {
      return "You've exceeded your monthly budget by \$${(_monthlyExpenses - _monthlyBudget).toStringAsFixed(2)}";
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2E7D32); // Bank Green
    final backgroundColor = primaryColor.withOpacity(0.05);
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Budget',
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
            // Budget Overview
            _buildBudgetOverview(primaryColor),
            const SizedBox(height: 16),
            
            // Daily Spending Limit
            _buildDailySpendingLimit(primaryColor),
            const SizedBox(height: 16),
            
            // Category Breakdown
            _buildCategoryBreakdown(),
            const SizedBox(height: 16),
            
            // Insight Section
            _buildInsightSection(primaryColor),
            const SizedBox(height: 16),
            
            // Recent Transactions
            _buildRecentTransactions(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddExpenseDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildBudgetOverview(Color primaryColor) {
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
          const Text(
            'Monthly Budget',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            _monthlyBudget > 0 
                ? '\$${_monthlyExpenses.toStringAsFixed(2)} / \$${_monthlyBudget.toStringAsFixed(2)}'
                : 'Spent: \$${_monthlyExpenses.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _monthlyBudget > 0 
                ? 'Remaining: \$${_remainingBudget.toStringAsFixed(2)}'
                : 'No budget set',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: _budgetUsedPercentage,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(_budgetColor),
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Text(
            '${(_budgetUsedPercentage * 100).toInt()}% used',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDailySpendingLimit(Color primaryColor) {
    return Container(
      width: double.infinity,
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
          Icon(Icons.today, color: primaryColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily Spending Limit',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Text(
                  _monthlyBudget <= 0
                      ? 'Set a monthly budget to see daily spending recommendations'
                      : _dailySpendingLimit > 0
                          ? 'You can spend \$${_dailySpendingLimit.toStringAsFixed(2)}/day for the rest of the month'
                          : 'Budget exceeded for this month',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown() {
    final categoryExpenses = _categoryExpenses;
    
    return Container(
      width: double.infinity,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Category Breakdown',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...categoryExpenses.entries.map((entry) {
            final category = entry.key;
            final spent = entry.value;
            final budget = _categoryBudgets[category] ?? 0.0;
            final percentage = budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        category,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '\$${spent.toStringAsFixed(2)} / \$${budget.toStringAsFixed(2)}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      percentage < 0.5 ? Colors.green :
                      percentage < 0.9 ? Colors.orange : Colors.red,
                    ),
                    minHeight: 6,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(percentage * 100).toInt()}% used',
                    style: TextStyle(color: Colors.grey[500], fontSize: 10),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildInsightSection(Color primaryColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _budgetColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _budgetColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            _budgetUsedPercentage < 0.9 ? Icons.lightbulb : Icons.warning,
            color: _budgetColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _budgetInsight,
              style: TextStyle(
                color: _budgetColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
    final recentExpenses = widget.expenses.take(5).toList();
    
    return Container(
      width: double.infinity,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Transactions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (recentExpenses.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.receipt_long, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      'No transactions yet',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            )
          else
            ...recentExpenses.map((expense) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _getCategoryColor(expense.category),
                    radius: 16,
                    child: Icon(
                      _getCategoryIcon(expense.category),
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '\$${expense.amount.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          expense.category,
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                        if (expense.note.isNotEmpty)
                          Text(
                            expense.note,
                            style: TextStyle(color: Colors.grey[500], fontSize: 11),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    '${expense.date.day}/${expense.date.month}',
                    style: TextStyle(color: Colors.grey[500], fontSize: 11),
                  ),
                ],
              ),
            )).toList(),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food': return Colors.orange;
      case 'Transport': return Colors.blue;
      case 'Bills': return Colors.red;
      case 'Entertainment': return Colors.purple;
      case 'Shopping': return Colors.pink;
      case 'Health': return Colors.green;
      default: return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food': return Icons.restaurant;
      case 'Transport': return Icons.directions_car;
      case 'Bills': return Icons.receipt;
      case 'Entertainment': return Icons.movie;
      case 'Shopping': return Icons.shopping_bag;
      case 'Health': return Icons.local_hospital;
      default: return Icons.category;
    }
  }

  void _showAddExpenseDialog(BuildContext context) {
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
        child: _buildAddExpenseForm(),
      ),
    );
  }

  Widget _buildAddExpenseForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add New Expense',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                if (double.parse(value) <= 0) {
                  return 'Amount must be greater than 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedCategory = value!),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            
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
                      'Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addExpense,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Add Expense',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 