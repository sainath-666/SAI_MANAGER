import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/widgets/module_placeholder.dart';

class CompletedScreen extends StatelessWidget {
  const CompletedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholder(
      title: 'Completed Work',
      icon: LucideIcons.checkSquare,
      description: 'Historical archive of accomplishments, resolved project epics, and client-approved deliverables.',
    );
  }
}
