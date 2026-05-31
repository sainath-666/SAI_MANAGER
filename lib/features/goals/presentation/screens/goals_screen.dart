import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/widgets/module_placeholder.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholder(
      title: 'Goals & Habits',
      icon: LucideIcons.award,
      description: 'Define long-term OKRs, manage daily habits, check streak status, and track monthly progress.',
    );
  }
}
