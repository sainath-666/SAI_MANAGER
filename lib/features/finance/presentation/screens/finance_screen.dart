import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/widgets/module_placeholder.dart';

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholder(
      title: 'Finance',
      icon: LucideIcons.dollarSign,
      description: 'Track income, freelance invoices, monthly expenses, budgets, and investments.',
    );
  }
}
