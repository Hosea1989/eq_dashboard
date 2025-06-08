import 'package:flutter/material.dart';
import 'dart:math' as math;

enum DebtType {
  creditCard,
  studentLoan,
  autoLoan,
  mortgage,
  personalLoan,
  medicalDebt,
  other
}

enum PayoffStrategy {
  snowball, // Smallest balance first
  avalanche, // Highest interest first
  custom
}

class Debt {
  final String id;
  final String name;
  final DebtType type;
  final double balance;
  final double originalBalance;
  final double interestRate;
  final double minimumPayment;
  final DateTime? dueDate;
  final bool isActive;
  final DateTime createdDate;
  final List<DebtPayment> payments;

  Debt({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.originalBalance,
    required this.interestRate,
    required this.minimumPayment,
    this.dueDate,
    this.isActive = true,
    required this.createdDate,
    List<DebtPayment>? payments,
  }) : payments = payments ?? [];

  Debt copyWith({
    String? id,
    String? name,
    DebtType? type,
    double? balance,
    double? originalBalance,
    double? interestRate,
    double? minimumPayment,
    DateTime? dueDate,
    bool? isActive,
    DateTime? createdDate,
    List<DebtPayment>? payments,
  }) {
    return Debt(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      originalBalance: originalBalance ?? this.originalBalance,
      interestRate: interestRate ?? this.interestRate,
      minimumPayment: minimumPayment ?? this.minimumPayment,
      dueDate: dueDate ?? this.dueDate,
      isActive: isActive ?? this.isActive,
      createdDate: createdDate ?? this.createdDate,
      payments: payments ?? this.payments,
    );
  }

  double get progressPercentage {
    if (originalBalance <= 0) return 0.0;
    return ((originalBalance - balance) / originalBalance).clamp(0.0, 1.0);
  }

  double get totalPaid {
    return originalBalance - balance;
  }

  String get typeDisplayName {
    switch (type) {
      case DebtType.creditCard:
        return 'Credit Card';
      case DebtType.studentLoan:
        return 'Student Loan';
      case DebtType.autoLoan:
        return 'Auto Loan';
      case DebtType.mortgage:
        return 'Mortgage';
      case DebtType.personalLoan:
        return 'Personal Loan';
      case DebtType.medicalDebt:
        return 'Medical Debt';
      case DebtType.other:
        return 'Other';
    }
  }

  Color get typeColor {
    switch (type) {
      case DebtType.creditCard:
        return const Color(0xFFE91E63); // Pink
      case DebtType.studentLoan:
        return const Color(0xFF3F51B5); // Indigo
      case DebtType.autoLoan:
        return const Color(0xFF2196F3); // Blue
      case DebtType.mortgage:
        return const Color(0xFF4CAF50); // Green
      case DebtType.personalLoan:
        return const Color(0xFFFF9800); // Orange
      case DebtType.medicalDebt:
        return const Color(0xFFF44336); // Red
      case DebtType.other:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  String get priorityReason {
    if (interestRate > 20) return 'High interest rate';
    if (balance < 1000) return 'Small balance - quick win';
    if (type == DebtType.creditCard) return 'Credit card debt affects credit utilization';
    return 'Standard debt';
  }

  int get daysUntilDue {
    if (dueDate == null) return 999;
    return dueDate!.difference(DateTime.now()).inDays;
  }

  bool get isOverdue {
    if (dueDate == null) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  // Calculate months to payoff with minimum payments
  int get monthsToPayoffMinimum {
    if (minimumPayment <= 0 || interestRate <= 0) return 999;
    
    double monthlyRate = interestRate / 100 / 12;
    double numerator = -1 * (balance / minimumPayment);
    double denominator = 1 - (1 + monthlyRate);
    
    if (denominator >= 0) return 999; // Will never pay off
    
    return (math.log(1 + numerator * monthlyRate) / math.log(1 + monthlyRate)).ceil();
  }

  // Calculate total interest paid with minimum payments
  double get totalInterestMinimum {
    int months = monthsToPayoffMinimum;
    if (months >= 999) return double.infinity;
    return (minimumPayment * months) - balance;
  }
}

class DebtPayment {
  final String id;
  final String debtId;
  final double amount;
  final DateTime date;
  final String? note;
  final bool isExtraPayment;

  DebtPayment({
    required this.id,
    required this.debtId,
    required this.amount,
    required this.date,
    this.note,
    this.isExtraPayment = false,
  });

  DebtPayment copyWith({
    String? id,
    String? debtId,
    double? amount,
    DateTime? date,
    String? note,
    bool? isExtraPayment,
  }) {
    return DebtPayment(
      id: id ?? this.id,
      debtId: debtId ?? this.debtId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      note: note ?? this.note,
      isExtraPayment: isExtraPayment ?? this.isExtraPayment,
    );
  }
}

class DebtPayoffPlan {
  final PayoffStrategy strategy;
  final double extraMonthlyPayment;
  final List<DebtPayoffStep> steps;
  final int totalMonths;
  final double totalInterest;
  final double totalPaid;

  DebtPayoffPlan({
    required this.strategy,
    required this.extraMonthlyPayment,
    required this.steps,
    required this.totalMonths,
    required this.totalInterest,
    required this.totalPaid,
  });

  String get strategyDescription {
    switch (strategy) {
      case PayoffStrategy.snowball:
        return 'Pay minimums on all debts, then attack smallest balance first. Great for motivation!';
      case PayoffStrategy.avalanche:
        return 'Pay minimums on all debts, then attack highest interest rate first. Saves the most money!';
      case PayoffStrategy.custom:
        return 'Custom payoff order based on your priorities.';
    }
  }

  String get timeToFreedom {
    int years = totalMonths ~/ 12;
    int months = totalMonths % 12;
    
    if (years > 0 && months > 0) {
      return '$years years, $months months';
    } else if (years > 0) {
      return '$years years';
    } else {
      return '$months months';
    }
  }
}

class DebtPayoffStep {
  final String debtId;
  final String debtName;
  final int order;
  final int monthsToPayoff;
  final double totalPayments;
  final double interestPaid;

  DebtPayoffStep({
    required this.debtId,
    required this.debtName,
    required this.order,
    required this.monthsToPayoff,
    required this.totalPayments,
    required this.interestPaid,
  });
} 