import 'package:flutter/material.dart';
import '../models/debt.dart';
import '../utils/theme_manager.dart';
import '../utils/feedback_system.dart';

class DebtManagementScreen extends StatefulWidget {
  final List<Debt> debts;

  const DebtManagementScreen({
    super.key,
    required this.debts,
  });

  @override
  State<DebtManagementScreen> createState() => _DebtManagementScreenState();
}

class _DebtManagementScreenState extends State<DebtManagementScreen> {
  PayoffStrategy _selectedStrategy = PayoffStrategy.snowball;
  double _extraMonthlyPayment = 0.0;
  final _extraPaymentController = TextEditingController();

  @override
  void dispose() {
    _extraPaymentController.dispose();
    super.dispose();
  }

  double get _totalDebt {
    return widget.debts.fold(0.0, (sum, debt) => sum + debt.balance);
  }

  double get _totalMinimumPayments {
    return widget.debts.fold(0.0, (sum, debt) => sum + debt.minimumPayment);
  }

  List<Debt> get _sortedDebts {
    final activeDebts = widget.debts.where((debt) => debt.isActive && debt.balance > 0).toList();
    
    switch (_selectedStrategy) {
      case PayoffStrategy.snowball:
        activeDebts.sort((a, b) => a.balance.compareTo(b.balance));
        break;
      case PayoffStrategy.avalanche:
        activeDebts.sort((a, b) => b.interestRate.compareTo(a.interestRate));
        break;
      case PayoffStrategy.custom:
        // Keep current order for custom
        break;
    }
    
    return activeDebts;
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeManager.themeData;
    
    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Debt Management',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: theme.primaryColor,
        elevation: theme.elevation,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showAddDebtDialog(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Debt Overview Card
            _buildDebtOverviewCard(theme),
            const SizedBox(height: 20),
            
            // Strategy Selection
            _buildStrategySelectionCard(theme),
            const SizedBox(height: 20),
            
            // Extra Payment Input
            _buildExtraPaymentCard(theme),
            const SizedBox(height: 20),
            
            // Debt List
            _buildDebtListCard(theme),
            const SizedBox(height: 20),
            
            // Payoff Timeline (if extra payment is set)
            if (_extraMonthlyPayment > 0) ...[
              _buildPayoffTimelineCard(theme),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPaymentDialog(),
        icon: const Icon(Icons.payment),
        label: const Text('Make Payment'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildDebtOverviewCard(AppThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(theme.borderRadius),
        border: Border.all(color: theme.borderColor, width: 1),
        boxShadow: theme.useGradients ? [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.1),
            blurRadius: theme.elevation * 2,
            offset: const Offset(0, 2),
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
                  Text(
                    'Total Debt',
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${_totalDebt.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: theme.errorColor,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Min. Payments',
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${_totalMinimumPayments.toStringAsFixed(0)}/mo',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(
                child: _buildOverviewStat(
                  'Active Debts',
                  '${widget.debts.where((d) => d.isActive).length}',
                  theme,
                ),
              ),
              Expanded(
                child: _buildOverviewStat(
                  'Avg. Interest',
                  '${_calculateAverageInterest().toStringAsFixed(1)}%',
                  theme,
                ),
              ),
              Expanded(
                child: _buildOverviewStat(
                  'Overdue',
                  '${widget.debts.where((d) => d.isOverdue).length}',
                  theme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewStat(String label, String value, AppThemeData theme) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
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

  double _calculateAverageInterest() {
    if (widget.debts.isEmpty) return 0.0;
    final totalInterest = widget.debts.fold(0.0, (sum, debt) => sum + debt.interestRate);
    return totalInterest / widget.debts.length;
  }

  Widget _buildStrategySelectionCard(AppThemeData theme) {
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
            'Payoff Strategy',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          // Strategy options
          ...PayoffStrategy.values.map((strategy) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: RadioListTile<PayoffStrategy>(
              title: Text(
                _getStrategyTitle(strategy),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: theme.textPrimary,
                ),
              ),
              subtitle: Text(
                _getStrategyDescription(strategy),
                style: TextStyle(
                  color: theme.textSecondary,
                  fontSize: 12,
                ),
              ),
              value: strategy,
              groupValue: _selectedStrategy,
              onChanged: (value) {
                setState(() {
                  _selectedStrategy = value!;
                });
              },
              activeColor: theme.primaryColor,
              contentPadding: EdgeInsets.zero,
            ),
          )).toList(),
        ],
      ),
    );
  }

  String _getStrategyTitle(PayoffStrategy strategy) {
    switch (strategy) {
      case PayoffStrategy.snowball:
        return 'Debt Snowball';
      case PayoffStrategy.avalanche:
        return 'Debt Avalanche';
      case PayoffStrategy.custom:
        return 'Custom Order';
    }
  }

  String _getStrategyDescription(PayoffStrategy strategy) {
    switch (strategy) {
      case PayoffStrategy.snowball:
        return 'Pay smallest balances first for quick wins and motivation';
      case PayoffStrategy.avalanche:
        return 'Pay highest interest rates first to save the most money';
      case PayoffStrategy.custom:
        return 'Choose your own order based on personal priorities';
    }
  }

  Widget _buildExtraPaymentCard(AppThemeData theme) {
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
            'Extra Monthly Payment',
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
                child: TextFormField(
                  controller: _extraPaymentController,
                  decoration: InputDecoration(
                    labelText: 'Extra Amount (\$)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(theme.borderRadius),
                    ),
                    filled: true,
                    fillColor: theme.surfaceColor,
                    prefixText: '\$',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _extraMonthlyPayment = double.tryParse(value) ?? 0.0;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _extraMonthlyPayment = double.tryParse(_extraPaymentController.text) ?? 0.0;
                  });
                  if (_extraMonthlyPayment > 0) {
                    FeedbackSystem.celebrateSuccess(
                      context, 
                      'Great! Extra payments will accelerate your debt freedom!'
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Update'),
              ),
            ],
          ),
          
          if (_extraMonthlyPayment > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.successColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.trending_up,
                    color: theme.successColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Extra \$${_extraMonthlyPayment.toStringAsFixed(0)}/month will save you thousands!',
                    style: TextStyle(
                      color: theme.successColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDebtListCard(AppThemeData theme) {
    final sortedDebts = _sortedDebts;
    
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
            'Your Debts (${_getStrategyTitle(_selectedStrategy)} Order)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          if (sortedDebts.isEmpty) ...[
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.celebration,
                    size: 64,
                    color: theme.successColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Debt Free! 🎉',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.successColor,
                    ),
                  ),
                  Text(
                    'Congratulations on paying off all your debts!',
                    style: TextStyle(
                      color: theme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            ...sortedDebts.asMap().entries.map((entry) {
              final index = entry.key;
              final debt = entry.value;
              final isNext = index == 0 && _extraMonthlyPayment > 0;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isNext 
                        ? theme.primaryColor.withOpacity(0.05)
                        : theme.surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isNext 
                          ? theme.primaryColor.withOpacity(0.3)
                          : theme.borderColor,
                      width: isNext ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Priority indicator
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: isNext ? theme.primaryColor : debt.typeColor,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          
                          // Debt info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      debt.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: theme.textPrimary,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      '\$${debt.balance.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: theme.textPrimary,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${debt.typeDisplayName} • ${debt.interestRate.toStringAsFixed(1)}% APR',
                                      style: TextStyle(
                                        color: theme.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      'Min: \$${debt.minimumPayment.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        color: theme.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Progress bar
                      LinearProgressIndicator(
                        value: debt.progressPercentage,
                        backgroundColor: theme.borderColor,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isNext ? theme.primaryColor : debt.typeColor,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${(debt.progressPercentage * 100).toStringAsFixed(1)}% paid off',
                            style: TextStyle(
                              color: theme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          if (isNext) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.primaryColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'FOCUS HERE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      
                      if (debt.isOverdue) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.errorColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: theme.errorColor.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning,
                                color: theme.errorColor,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Payment overdue!',
                                style: TextStyle(
                                  color: theme.errorColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildPayoffTimelineCard(AppThemeData theme) {
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
            'Debt Freedom Timeline',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          // Simplified timeline calculation
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.successColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.successColor.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Debt Free In',
                          style: TextStyle(
                            color: theme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          _calculatePayoffTime(),
                          style: TextStyle(
                            color: theme.successColor,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Interest Saved',
                          style: TextStyle(
                            color: theme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '\$${_calculateInterestSaved().toStringAsFixed(0)}',
                          style: TextStyle(
                            color: theme.successColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'With your extra \$${_extraMonthlyPayment.toStringAsFixed(0)}/month payment!',
                  style: TextStyle(
                    color: theme.successColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _calculatePayoffTime() {
    // Simplified calculation - in a real app, you'd want more sophisticated math
    if (_extraMonthlyPayment <= 0) return 'Set extra payment';
    
    double totalPayment = _totalMinimumPayments + _extraMonthlyPayment;
    double avgInterestRate = _calculateAverageInterest() / 100 / 12;
    
    if (totalPayment <= 0) return 'N/A';
    
    // Rough estimate
    int months = (_totalDebt / totalPayment * 1.2).ceil(); // Factor in interest
    int years = months ~/ 12;
    int remainingMonths = months % 12;
    
    if (years > 0 && remainingMonths > 0) {
      return '$years years, $remainingMonths months';
    } else if (years > 0) {
      return '$years years';
    } else {
      return '$remainingMonths months';
    }
  }

  double _calculateInterestSaved() {
    // Simplified calculation
    return _extraMonthlyPayment * 24; // Rough estimate
  }

  void _showAddDebtDialog() {
    // Implementation for adding new debt
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add debt feature coming soon!')),
    );
  }

  void _showPaymentDialog() {
    // Implementation for making payments
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment feature coming soon!')),
    );
  }
} 