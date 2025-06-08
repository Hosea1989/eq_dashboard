import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../models/credit_score.dart';
import '../models/debt.dart';
import '../models/fitness.dart';
import '../utils/theme_manager.dart';
import 'dashboard_screen.dart';
import 'budget_screen.dart';
import 'goals_screen.dart';
import 'habits_screen.dart';
import 'journal_screen.dart';
import 'credit_repair_screen.dart';
import 'fitness_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 2; // Start with Dashboard
  String _currentPageTitle = 'Dashboard';
  
  // Shared data across screens
  final List<Expense> _expenses = [];
  final List<Goal> _goals = [];
  final List<Habit> _habits = [];
  final List<JournalEntry> _journalEntries = [];
  final List<CreditScore> _creditScores = [];
  final List<CreditGoal> _creditGoals = [];
  final List<Debt> _debts = [];
  final List<FitnessActivity> _fitnessActivities = [];
  final List<FitnessGoal> _fitnessGoals = [];

  @override
  void initState() {
    super.initState();
    _initializeSampleData();
  }

  void _initializeSampleData() {
    // Add sample credit scores to show progress
    _creditScores.addAll([
      CreditScore(
        id: '1',
        score: 580,
        provider: 'FICO',
        date: DateTime.now().subtract(const Duration(days: 180)),
        notes: 'Starting point - need improvement',
      ),
      CreditScore(
        id: '2',
        score: 620,
        provider: 'FICO',
        date: DateTime.now().subtract(const Duration(days: 90)),
        notes: 'Paid down some debt',
      ),
      CreditScore(
        id: '3',
        score: 650,
        provider: 'FICO',
        date: DateTime.now().subtract(const Duration(days: 30)),
        notes: 'Consistent payments helping',
      ),
    ]);

    // Add sample credit goals
    _creditGoals.addAll([
      CreditGoal(
        id: '1',
        targetScore: 700,
        targetDate: DateTime.now().add(const Duration(days: 365)),
        description: 'Reach good credit range',
        createdDate: DateTime.now().subtract(const Duration(days: 180)),
      ),
      CreditGoal(
        id: '2',
        targetScore: 750,
        targetDate: DateTime.now().add(const Duration(days: 730)),
        description: 'Qualify for best rates',
        createdDate: DateTime.now().subtract(const Duration(days: 180)),
      ),
    ]);

    // Add sample debts
    _debts.addAll([
      Debt(
        id: '1',
        name: 'Chase Freedom Card',
        type: DebtType.creditCard,
        balance: 3500.0,
        originalBalance: 5000.0,
        interestRate: 24.99,
        minimumPayment: 105.0,
        dueDate: DateTime.now().add(const Duration(days: 15)),
        createdDate: DateTime.now().subtract(const Duration(days: 365)),
      ),
      Debt(
        id: '2',
        name: 'Capital One Card',
        type: DebtType.creditCard,
        balance: 1200.0,
        originalBalance: 2000.0,
        interestRate: 19.99,
        minimumPayment: 35.0,
        dueDate: DateTime.now().add(const Duration(days: 20)),
        createdDate: DateTime.now().subtract(const Duration(days: 300)),
      ),
      Debt(
        id: '3',
        name: 'Student Loan',
        type: DebtType.studentLoan,
        balance: 15000.0,
        originalBalance: 20000.0,
        interestRate: 6.5,
        minimumPayment: 180.0,
        dueDate: DateTime.now().add(const Duration(days: 10)),
        createdDate: DateTime.now().subtract(const Duration(days: 1095)),
      ),
      Debt(
        id: '4',
        name: 'Car Loan',
        type: DebtType.autoLoan,
        balance: 8500.0,
        originalBalance: 12000.0,
        interestRate: 4.5,
        minimumPayment: 285.0,
        dueDate: DateTime.now().add(const Duration(days: 25)),
        createdDate: DateTime.now().subtract(const Duration(days: 730)),
             ),
     ]);

    // Add sample fitness activities
    _fitnessActivities.addAll([
      FitnessActivity(
        id: '1',
        name: 'Morning Walk',
        type: WorkoutType.walking,
        durationMinutes: 30,
        intensity: ActivityIntensity.light,
        date: DateTime.now().subtract(const Duration(days: 1)),
        energyLevel: 7,
        notes: 'Beautiful morning, felt great!',
      ),
      FitnessActivity(
        id: '2',
        name: 'Gym Session',
        type: WorkoutType.strength,
        durationMinutes: 45,
        intensity: ActivityIntensity.vigorous,
        date: DateTime.now().subtract(const Duration(days: 2)),
        energyLevel: 8,
        caloriesBurned: 350,
      ),
      FitnessActivity(
        id: '3',
        name: 'Yoga Flow',
        type: WorkoutType.yoga,
        durationMinutes: 25,
        intensity: ActivityIntensity.light,
        date: DateTime.now().subtract(const Duration(days: 3)),
        energyLevel: 6,
        notes: 'Relaxing session before bed',
      ),
    ]);

    // Add sample fitness goals
    _fitnessGoals.addAll([
      FitnessGoal(
        id: '1',
        title: 'Weekly Workout Goal',
        description: 'Exercise 4 times per week',
        type: FitnessGoalType.weeklyWorkouts,
        targetValue: 4,
        currentValue: 2,
        targetDate: DateTime.now().add(const Duration(days: 4)),
        createdDate: DateTime.now().subtract(const Duration(days: 3)),
      ),
      FitnessGoal(
        id: '2',
        title: 'Monthly Activity',
        description: 'Get 600 minutes of exercise this month',
        type: FitnessGoalType.monthlyMinutes,
        targetValue: 600,
        currentValue: 180,
        targetDate: DateTime.now().add(const Duration(days: 25)),
        createdDate: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ]);
   }

  List<Widget> get _screens => [
    BudgetScreen(
      expenses: _expenses,
      onExpenseAdded: (expense) {
        setState(() {
          _expenses.insert(0, expense);
        });
      },
    ),
    CreditRepairScreen(
      creditScores: _creditScores,
      creditGoals: _creditGoals,
      debts: _debts,
    ),
    DashboardScreen(
      expenses: _expenses,
      goals: _goals,
      habits: _habits,
      journalEntries: _journalEntries,
    ),
    FitnessScreen(
      activities: _fitnessActivities,
      fitnessGoals: _fitnessGoals,
    ),
    GoalsScreen(goals: _goals),
    HabitsScreen(habits: _habits),
    JournalScreen(journalEntries: _journalEntries),
  ];

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: CupertinoIcons.money_dollar_circle,
      label: 'Budget',
      description: 'Track your daily expenses and spending',
    ),
    NavigationItem(
      icon: CupertinoIcons.creditcard,
      label: 'Credit',
      description: 'Improve your credit score and manage debt',
    ),
    NavigationItem(
      icon: CupertinoIcons.square_grid_2x2,
      label: 'Dashboard',
      description: 'Overview of your financial wellness',
    ),
    NavigationItem(
      icon: CupertinoIcons.heart,
      label: 'Fitness',
      description: 'Track workouts and physical wellness',
    ),
    NavigationItem(
      icon: CupertinoIcons.flag,
      label: 'Goals',
      description: 'Set and track financial targets',
    ),
    NavigationItem(
      icon: CupertinoIcons.checkmark_circle,
      label: 'Habits',
      description: 'Build healthy financial routines',
    ),
    NavigationItem(
      icon: CupertinoIcons.book,
      label: 'Journal',
      description: 'Reflect on your financial journey',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeManager.themeData;
    
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: theme.primaryColor,
        activeColor: CupertinoColors.white,
        inactiveColor: CupertinoColors.white.withOpacity(0.6),
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _currentPageTitle = _navigationItems[index].label;
          });
        },
        items: _navigationItems.map((item) => BottomNavigationBarItem(
          icon: Icon(item.icon, size: 20),
          label: item.label,
        )).toList(),
      ),
      tabBuilder: (context, index) {
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            backgroundColor: theme.primaryColor,
            middle: Text(
              _currentPageTitle,
              style: const TextStyle(
                color: CupertinoColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => _showActionSheet(context),
              child: const Icon(
                CupertinoIcons.ellipsis_circle,
                color: CupertinoColors.white,
                size: 24,
              ),
            ),
          ),
          child: SafeArea(
            child: _screens[index],
          ),
        );
      },
    );
  }



  void _showActionSheet(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Equilibrium Dashboard'),
        message: const Text('Choose an option'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _showThemeSelector(context);
            },
            child: const Text('Change Theme'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _showSettings(context);
            },
            child: const Text('Settings'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _showThemeSelector(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Select Theme'),
        content: const Text('Choose your preferred theme'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Low Stim'),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('High Contrast'),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Soft Colors'),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Standard'),
          ),
        ],
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Settings'),
        content: const Text('Settings coming soon!'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
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