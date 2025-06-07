import '../models/expense.dart';

class ExpenseTemplate {
  final String name;
  final String category;
  final double amount;
  final String note;
  final String icon;

  const ExpenseTemplate({
    required this.name,
    required this.category,
    required this.amount,
    required this.note,
    required this.icon,
  });

  Expense toExpense() {
    return Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      category: category,
      note: note,
      date: DateTime.now(),
    );
  }
}

class ExpenseTemplates {
  static const List<ExpenseTemplate> templates = [
    // Food Templates
    ExpenseTemplate(
      name: 'Coffee',
      category: 'Food',
      amount: 5.0,
      note: 'Coffee break',
      icon: '☕',
    ),
    ExpenseTemplate(
      name: 'Lunch',
      category: 'Food',
      amount: 12.0,
      note: 'Lunch meal',
      icon: '🍽️',
    ),
    ExpenseTemplate(
      name: 'Groceries',
      category: 'Food',
      amount: 50.0,
      note: 'Weekly groceries',
      icon: '🛒',
    ),
    ExpenseTemplate(
      name: 'Snack',
      category: 'Food',
      amount: 3.0,
      note: 'Quick snack',
      icon: '🍿',
    ),
    
    // Transport Templates
    ExpenseTemplate(
      name: 'Bus Fare',
      category: 'Transport',
      amount: 2.5,
      note: 'Public transport',
      icon: '🚌',
    ),
    ExpenseTemplate(
      name: 'Gas',
      category: 'Transport',
      amount: 40.0,
      note: 'Fuel for car',
      icon: '⛽',
    ),
    ExpenseTemplate(
      name: 'Parking',
      category: 'Transport',
      amount: 5.0,
      note: 'Parking fee',
      icon: '🅿️',
    ),
    ExpenseTemplate(
      name: 'Taxi/Uber',
      category: 'Transport',
      amount: 15.0,
      note: 'Ride share',
      icon: '🚗',
    ),
    
    // Entertainment Templates
    ExpenseTemplate(
      name: 'Movie',
      category: 'Entertainment',
      amount: 15.0,
      note: 'Cinema ticket',
      icon: '🎬',
    ),
    ExpenseTemplate(
      name: 'Streaming',
      category: 'Entertainment',
      amount: 10.0,
      note: 'Monthly subscription',
      icon: '📺',
    ),
    ExpenseTemplate(
      name: 'Book',
      category: 'Entertainment',
      amount: 20.0,
      note: 'New book',
      icon: '📚',
    ),
    
    // Bills Templates
    ExpenseTemplate(
      name: 'Phone Bill',
      category: 'Bills',
      amount: 50.0,
      note: 'Monthly phone bill',
      icon: '📱',
    ),
    ExpenseTemplate(
      name: 'Internet',
      category: 'Bills',
      amount: 60.0,
      note: 'Monthly internet',
      icon: '🌐',
    ),
    ExpenseTemplate(
      name: 'Electricity',
      category: 'Bills',
      amount: 80.0,
      note: 'Monthly electricity',
      icon: '⚡',
    ),
    
    // Health Templates
    ExpenseTemplate(
      name: 'Pharmacy',
      category: 'Health',
      amount: 25.0,
      note: 'Medication',
      icon: '💊',
    ),
    ExpenseTemplate(
      name: 'Doctor Visit',
      category: 'Health',
      amount: 100.0,
      note: 'Medical consultation',
      icon: '👩‍⚕️',
    ),
    
    // Shopping Templates
    ExpenseTemplate(
      name: 'Clothes',
      category: 'Shopping',
      amount: 30.0,
      note: 'Clothing item',
      icon: '👕',
    ),
    ExpenseTemplate(
      name: 'Household',
      category: 'Shopping',
      amount: 20.0,
      note: 'Household items',
      icon: '🏠',
    ),
  ];

  static List<ExpenseTemplate> getTemplatesByCategory(String category) {
    return templates.where((template) => template.category == category).toList();
  }

  static List<ExpenseTemplate> getMostUsed() {
    // Return the most commonly used templates
    return [
      templates[0], // Coffee
      templates[1], // Lunch
      templates[2], // Groceries
      templates[4], // Bus Fare
      templates[7], // Taxi/Uber
      templates[8], // Movie
    ];
  }
} 