import 'package:flutter/material.dart';
import '../models/credit_score.dart';
import '../models/debt.dart';
import '../utils/theme_manager.dart';
import '../utils/feedback_system.dart';

class CreditRepairScreen extends StatefulWidget {
  final List<CreditScore> creditScores;
  final List<CreditGoal> creditGoals;
  final List<Debt> debts;

  const CreditRepairScreen({
    super.key,
    required this.creditScores,
    required this.creditGoals,
    required this.debts,
  });

  @override
  State<CreditRepairScreen> createState() => _CreditRepairScreenState();
}

class _CreditRepairScreenState extends State<CreditRepairScreen> {
  final _scoreController = TextEditingController();
  final _providerController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _scoreController.dispose();
    _providerController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  CreditScore? get _latestScore {
    if (widget.creditScores.isEmpty) return null;
    return widget.creditScores.reduce((a, b) => a.date.isAfter(b.date) ? a : b);
  }

  int get _scoreImprovement {
    if (widget.creditScores.length < 2) return 0;
    final sorted = List<CreditScore>.from(widget.creditScores)
      ..sort((a, b) => a.date.compareTo(b.date));
    return sorted.last.score - sorted.first.score;
  }

  double get _totalDebt {
    return widget.debts.fold(0.0, (sum, debt) => sum + debt.balance);
  }

  double get _creditUtilization {
    final creditCardDebts = widget.debts.where((debt) => debt.type == DebtType.creditCard);
    if (creditCardDebts.isEmpty) return 0.0;
    
    double totalBalance = creditCardDebts.fold(0.0, (sum, debt) => sum + debt.balance);
    // Assuming credit limit is roughly 2x current balance for calculation
    double estimatedLimit = totalBalance * 2;
    return estimatedLimit > 0 ? (totalBalance / estimatedLimit) * 100 : 0.0;
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
            // Current Credit Score Card
            _buildCurrentScoreCard(theme),
            const SizedBox(height: 20),
            
            // Credit Score Progress
            if (widget.creditScores.length > 1) ...[
              _buildScoreProgressCard(theme),
              const SizedBox(height: 20),
            ],
            
            // Credit Health Overview
            _buildCreditHealthCard(theme),
            const SizedBox(height: 20),
            
            // Action Items
            _buildActionItemsCard(theme),
            const SizedBox(height: 20),
            
            // Debt Overview
            if (widget.debts.isNotEmpty) ...[
              _buildDebtOverviewCard(theme),
              const SizedBox(height: 20),
            ],
            
            // Credit Goals
            _buildCreditGoalsCard(theme),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreditTipsDialog(),
        icon: const Icon(Icons.lightbulb),
        label: const Text('Credit Tips'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildCurrentScoreCard(AppThemeData theme) {
    final latestScore = _latestScore;
    
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
          if (latestScore != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Credit Score',
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${latestScore.score}',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: latestScore.rangeColor,
                      ),
                    ),
                    Text(
                      latestScore.creditRange,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: latestScore.rangeColor,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: latestScore.rangeColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.trending_up,
                    color: latestScore.rangeColor,
                    size: 32,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Score improvement indicator
            if (_scoreImprovement != 0) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _scoreImprovement > 0 
                      ? theme.successColor.withOpacity(0.1)
                      : theme.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _scoreImprovement > 0 ? Icons.arrow_upward : Icons.arrow_downward,
                      color: _scoreImprovement > 0 ? theme.successColor : theme.errorColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_scoreImprovement > 0 ? '+' : ''}$_scoreImprovement points since you started',
                      style: TextStyle(
                        color: _scoreImprovement > 0 ? theme.successColor : theme.errorColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Improvement tip
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.primaryColor.withOpacity(0.2)),
              ),
              child: Text(
                latestScore.improvementTip,
                style: TextStyle(
                  color: theme.primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ] else ...[
            // No score yet
            Column(
              children: [
                Icon(
                  Icons.credit_score,
                  size: 64,
                  color: theme.textSecondary,
                ),
                const SizedBox(height: 16),
                Text(
                  'No Credit Score Yet',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add your first credit score to start tracking your progress',
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _showAddScoreDialog(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Add Credit Score'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScoreProgressCard(AppThemeData theme) {
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
            'Score Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          // Simple progress visualization
          Container(
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: widget.creditScores.take(6).map((score) {
                final height = (score.score / 850) * 80; // Max height 80
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 30,
                      height: height,
                      decoration: BoxDecoration(
                        color: score.rangeColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${score.score}',
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.textSecondary,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditHealthCard(AppThemeData theme) {
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
            'Credit Health Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          // Credit Utilization
          _buildHealthMetric(
            'Credit Utilization',
            '${_creditUtilization.toStringAsFixed(1)}%',
            _creditUtilization < 10 ? theme.successColor :
            _creditUtilization < 30 ? theme.warningColor : theme.errorColor,
            _creditUtilization < 10 ? 'Excellent' :
            _creditUtilization < 30 ? 'Good' : 'Needs Improvement',
            theme,
          ),
          
          const SizedBox(height: 12),
          
          // Total Debt
          _buildHealthMetric(
            'Total Debt',
            '\$${_totalDebt.toStringAsFixed(0)}',
            _totalDebt < 10000 ? theme.successColor :
            _totalDebt < 50000 ? theme.warningColor : theme.errorColor,
            _totalDebt < 10000 ? 'Low' :
            _totalDebt < 50000 ? 'Moderate' : 'High',
            theme,
          ),
          
          const SizedBox(height: 12),
          
          // Active Debts
          _buildHealthMetric(
            'Active Debts',
            '${widget.debts.length}',
            widget.debts.length < 3 ? theme.successColor :
            widget.debts.length < 6 ? theme.warningColor : theme.errorColor,
            widget.debts.length < 3 ? 'Good' :
            widget.debts.length < 6 ? 'Moderate' : 'Many',
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildHealthMetric(String title, String value, Color color, String status, AppThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: theme.textSecondary,
                fontSize: 14,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionItemsCard(AppThemeData theme) {
    final actions = _getActionItems();
    
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
            'Action Items',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
                      ...actions.map((action) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: action['priority'] == 'high' ? theme.errorColor :
                           action['priority'] == 'medium' ? theme.warningColor : theme.successColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    action['text'] ?? '',
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  List<Map<String, String>> _getActionItems() {
    List<Map<String, String>> actions = [];
    
    if (_creditUtilization > 30) {
      actions.add({
        'text': 'Pay down credit card balances to under 30% utilization',
        'priority': 'high',
      });
    }
    
    if (_creditUtilization > 10) {
      actions.add({
        'text': 'Aim for under 10% credit utilization for optimal scores',
        'priority': 'medium',
      });
    }
    
    if (widget.debts.any((debt) => debt.isOverdue)) {
      actions.add({
        'text': 'Make overdue payments immediately',
        'priority': 'high',
      });
    }
    
    if (widget.creditScores.isEmpty) {
      actions.add({
        'text': 'Check your credit score to establish a baseline',
        'priority': 'high',
      });
    }
    
    if (widget.debts.length > 5) {
      actions.add({
        'text': 'Consider debt consolidation to simplify payments',
        'priority': 'medium',
      });
    }
    
    actions.add({
      'text': 'Set up automatic payments to avoid late fees',
      'priority': 'low',
    });
    
    return actions;
  }

  Widget _buildDebtOverviewCard(AppThemeData theme) {
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
                'Debt Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to debt management screen
                },
                child: Text(
                  'Manage',
                  style: TextStyle(color: theme.primaryColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          ...widget.debts.take(3).map((debt) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: debt.typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: debt.typeColor.withOpacity(0.3)),
                  ),
                  child: Center(
                    child: Text(
                      debt.name[0].toUpperCase(),
                      style: TextStyle(
                        color: debt.typeColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        debt.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: theme.textPrimary,
                        ),
                      ),
                      Text(
                        '${debt.typeDisplayName} • ${debt.interestRate.toStringAsFixed(1)}% APR',
                        style: TextStyle(
                          color: theme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                
                Text(
                  '\$${debt.balance.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.textPrimary,
                  ),
                ),
              ],
            ),
          )).toList(),
          
          if (widget.debts.length > 3) ...[
            const SizedBox(height: 8),
            Text(
              'And ${widget.debts.length - 3} more debts...',
              style: TextStyle(
                color: theme.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCreditGoalsCard(AppThemeData theme) {
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
                'Credit Goals',
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
          
          if (widget.creditGoals.isEmpty) ...[
            Text(
              'No credit goals set yet. Add a goal to track your progress!',
              style: TextStyle(
                color: theme.textSecondary,
                fontSize: 14,
              ),
            ),
          ] else ...[
            ...widget.creditGoals.take(3).map((goal) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: goal.isCompleted 
                      ? theme.successColor.withOpacity(0.1)
                      : theme.primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: goal.isCompleted 
                        ? theme.successColor.withOpacity(0.3)
                        : theme.primaryColor.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      goal.isCompleted ? Icons.check_circle : Icons.track_changes,
                      color: goal.isCompleted ? theme.successColor : theme.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reach ${goal.targetScore} credit score',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: theme.textPrimary,
                            ),
                          ),
                          Text(
                            goal.isCompleted 
                                ? 'Completed!'
                                : '${goal.daysUntilTarget()} days remaining',
                            style: TextStyle(
                              color: goal.isCompleted ? theme.successColor : theme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
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

  void _showAddScoreDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: AppThemeManager.themeData.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _buildAddScoreForm(),
      ),
    );
  }

  Widget _buildAddScoreForm() {
    final theme = AppThemeManager.themeData;
    
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add Credit Score',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          
          // Score input
          TextFormField(
            controller: _scoreController,
            decoration: InputDecoration(
              labelText: 'Credit Score (300-850)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(theme.borderRadius),
              ),
              filled: true,
              fillColor: theme.surfaceColor,
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          
          // Provider input
          TextFormField(
            controller: _providerController,
            decoration: InputDecoration(
              labelText: 'Provider (e.g., FICO, VantageScore)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(theme.borderRadius),
              ),
              filled: true,
              fillColor: theme.surfaceColor,
            ),
          ),
          const SizedBox(height: 16),
          
          // Notes input
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
            maxLines: 2,
          ),
          const SizedBox(height: 24),
          
          // Add button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _addCreditScore(),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(theme.borderRadius),
                ),
              ),
              child: const Text(
                'Add Score',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addCreditScore() {
    final score = int.tryParse(_scoreController.text);
    if (score == null || score < 300 || score > 850) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid credit score (300-850)')),
      );
      return;
    }

    final creditScore = CreditScore(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      score: score,
      provider: _providerController.text.isEmpty ? 'FICO' : _providerController.text,
      date: DateTime.now(),
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    setState(() {
      widget.creditScores.add(creditScore);
    });

    _scoreController.clear();
    _providerController.clear();
    _notesController.clear();

    Navigator.pop(context);
    
    // Check for achievements
    if (widget.creditScores.length == 1) {
      FeedbackSystem.showAchievement(context, AchievementType.firstExpense);
    }
    
    FeedbackSystem.celebrateSuccess(context, 'Credit score added! Keep tracking your progress.');
  }

  void _showAddGoalDialog() {
    // Implementation for adding credit goals
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Credit goal feature coming soon!')),
    );
  }

  void _showCreditTipsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Credit Improvement Tips'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTip('💳', 'Keep credit utilization under 30%', 'Ideally under 10% for best scores'),
              _buildTip('📅', 'Pay all bills on time', 'Payment history is 35% of your score'),
              _buildTip('📊', 'Don\'t close old credit cards', 'Length of credit history matters'),
              _buildTip('🎯', 'Limit new credit applications', 'Too many inquiries can hurt your score'),
              _buildTip('🔍', 'Monitor your credit report', 'Check for errors and dispute them'),
              _buildTip('💰', 'Pay down debt strategically', 'Focus on high-interest debt first'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(String emoji, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 