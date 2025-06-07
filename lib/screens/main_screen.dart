import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/theme_manager.dart';
import 'dashboard_screen.dart';
import 'budget_screen.dart';
import 'goals_screen.dart';
import 'habits_screen.dart';
import 'journal_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 2; // Start with Dashboard (center)
  
  // Shared data across screens
  final List<Expense> _expenses = [];
  final List<Goal> _goals = [];
  final List<Habit> _habits = [];
  final List<JournalEntry> _journalEntries = [];

  List<Widget> get _screens => [
    BudgetScreen(
      expenses: _expenses,
      onExpenseAdded: (expense) {
        setState(() {
          _expenses.insert(0, expense);
        });
      },
    ),
    GoalsScreen(goals: _goals),
    DashboardScreen(
      expenses: _expenses,
      goals: _goals,
      habits: _habits,
      journalEntries: _journalEntries,
    ),
    HabitsScreen(habits: _habits),
    JournalScreen(journalEntries: _journalEntries),
  ];

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.account_balance_wallet,
      label: 'Budget',
      description: 'Track expenses',
    ),
    NavigationItem(
      icon: Icons.track_changes,
      label: 'Goals',
      description: 'Set targets',
    ),
    NavigationItem(
      icon: Icons.dashboard,
      label: 'Dashboard',
      description: 'Overview',
    ),
    NavigationItem(
      icon: Icons.psychology,
      label: 'Habits',
      description: 'Build routines',
    ),
    NavigationItem(
      icon: Icons.book,
      label: 'Journal',
      description: 'Reflect',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeManager.themeData;
    
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          border: Border(
            top: BorderSide(
              color: theme.borderColor,
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _navigationItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = _currentIndex == index;
                
                return _buildNavigationItem(
                  item: item,
                  isSelected: isSelected,
                  onTap: () => setState(() => _currentIndex = index),
                  theme: theme,
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationItem({
    required NavigationItem item,
    required bool isSelected,
    required VoidCallback onTap,
    required AppThemeData theme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(theme.borderRadius),
          border: isSelected 
              ? Border.all(color: theme.primaryColor.withOpacity(0.3))
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              color: isSelected ? theme.primaryColor : theme.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                color: isSelected ? theme.primaryColor : theme.textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: 2),
              Text(
                item.description,
                style: TextStyle(
                  color: theme.primaryColor.withOpacity(0.7),
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String label;
  final String description;

  const NavigationItem({
    required this.icon,
    required this.label,
    required this.description,
  });
} 