import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/widgets/module_placeholder.dart';

class OfficeScreen extends StatelessWidget {
  const OfficeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholder(
      title: 'Office Work',
      icon: LucideIcons.briefcase,
      description: 'Manage employer tasks, daily stand-up logs, meetings, and work-related assets.',
    );
  }
}
