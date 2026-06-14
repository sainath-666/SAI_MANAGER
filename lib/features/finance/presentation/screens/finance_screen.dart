import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/color_palette.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/responsive_builder.dart';
import '../../data/models/finance_summary.dart';
import '../../data/models/transaction_model.dart';
import '../providers/finance_providers.dart';

class FinanceScreen extends ConsumerWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(financeSummaryProvider);
    final transactionsAsync = ref.watch(transactionsListProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTransactionDialog(context, ref),
        backgroundColor: AppColors.primary,
        icon: const Icon(LucideIcons.plus, size: 20),
        label: const Text('Add Transaction', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(context),
            const SizedBox(height: 24),

            // Stats row/grid
            summaryAsync.when(
              data: (summary) => _buildSummaryCards(context, summary),
              loading: () => const LinearProgressIndicator(),
              error: (e, s) => const SizedBox(),
            ),
            const SizedBox(height: 24),

            // Transactions list
            transactionsAsync.when(
              data: (transactions) => _buildTransactionsCard(context, ref, transactions),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Text('Error: $e'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const Icon(LucideIcons.dollarSign, color: AppColors.primary, size: 28),
        const SizedBox(width: 12),
        Text(
          'Finance Ledger',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(BuildContext context, FinanceSummary summary) {
    final isDesktop = ResponsiveBuilder.isDesktop(context);
    final isTablet = ResponsiveBuilder.isTablet(context);

    final card1 = SizedBox(
      height: 110,
      child: _buildStatCard(
        context,
        icon: LucideIcons.wallet,
        iconColor: AppColors.primary,
        title: 'Total Balance',
        value: '\$${summary.totalBalance.toStringAsFixed(2)}',
        subtitle: 'Cash ledger sync',
      ),
    );
    final card2 = SizedBox(
      height: 110,
      child: _buildStatCard(
        context,
        icon: LucideIcons.trendingUp,
        iconColor: AppColors.secondary,
        title: 'Monthly Income',
        value: '\$${summary.monthlyIncome.toStringAsFixed(2)}',
        subtitle: 'Milestone rewards',
      ),
    );
    final card3 = SizedBox(
      height: 110,
      child: _buildStatCard(
        context,
        icon: LucideIcons.trendingDown,
        iconColor: AppColors.error,
        title: 'Monthly Expenses',
        value: '\$${summary.monthlyExpenses.toStringAsFixed(2)}',
        subtitle: 'AWS & operation fees',
      ),
    );

    if (isDesktop) {
      return Row(
        children: [
          Expanded(child: card1),
          const SizedBox(width: 16),
          Expanded(child: card2),
          const SizedBox(width: 16),
          Expanded(child: card3),
        ],
      );
    } else if (isTablet) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: card1),
              const SizedBox(width: 16),
              Expanded(child: card2),
            ],
          ),
          const SizedBox(height: 16),
          card3,
        ],
      );
    } else {
      return Column(
        children: [
          card1,
          const SizedBox(height: 16),
          card2,
          const SizedBox(height: 16),
          card3,
        ],
      );
    }
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsCard(
    BuildContext context,
    WidgetRef ref,
    List<TransactionModel> transactions,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Transaction Ledger History',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          if (transactions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  'No transactions recorded.',
                  style: TextStyle(color: AppColors.darkTextMuted),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final tx = transactions[index];
                final isIncome = tx.type == 'income';
                final formattedDate = DateFormat('MMM d, yyyy').format(tx.date);

                return Padding(
                  key: ValueKey(tx.id),
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkBg.withOpacity(0.3) : AppColors.lightBg.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder.withOpacity(0.5) : AppColors.lightBorder.withOpacity(0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Icon Type
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: (isIncome ? AppColors.secondary : AppColors.error).withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isIncome ? LucideIcons.arrowUpRight : LucideIcons.arrowDownLeft,
                            color: isIncome ? AppColors.secondary : AppColors.error,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Title & Metadata
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tx.title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    formattedDate,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _buildTinyBadge(tx.category, AppColors.accent),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Amount & Delete
                        Row(
                          children: [
                            Text(
                              '${isIncome ? '+' : '-'}\$${tx.amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                color: isIncome ? AppColors.secondary : AppColors.error,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(LucideIcons.trash2, size: 16, color: AppColors.error),
                              onPressed: () {
                                ref.read(transactionsListProvider.notifier).deleteTransaction(tx.id);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTinyBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.2), width: 0.5),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(color: color, fontSize: 7, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showAddTransactionDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String type = 'expense';
    String category = 'Office Work';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'Record New Transaction',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 400,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: 'Transaction Title'),
                      ),
                      const SizedBox(height: 12),
                      // Amount
                      TextField(
                        controller: amountController,
                        decoration: const InputDecoration(labelText: 'Amount (\$)'),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                      const SizedBox(height: 16),
                      // Dropdown: Type
                      DropdownButtonFormField<String>(
                        initialValue: type,
                        decoration: const InputDecoration(labelText: 'Transaction Type'),
                        items: const [
                          DropdownMenuItem(value: 'income', child: Text('Income (+)')),
                          DropdownMenuItem(value: 'expense', child: Text('Expense (-)')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => type = val);
                        },
                      ),
                      const SizedBox(height: 16),
                      // Dropdown: Category
                      DropdownButtonFormField<String>(
                        initialValue: category,
                        decoration: const InputDecoration(labelText: 'Category'),
                        items: ['Office Work', 'Freelance', 'Learning', 'Personal', 'General']
                            .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => category = val);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final amount = double.tryParse(amountController.text);
                    if (titleController.text.isNotEmpty && amount != null && amount > 0) {
                      final tx = TransactionModel(
                        id: const Uuid().v4(),
                        title: titleController.text,
                        amount: amount,
                        type: type,
                        category: category,
                        date: DateTime.now(),
                      );
                      ref.read(transactionsListProvider.notifier).addTransaction(tx);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
