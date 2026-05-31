import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/widgets/module_placeholder.dart';

class FreelanceScreen extends StatelessWidget {
  const FreelanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholder(
      title: 'Freelance Work',
      icon: LucideIcons.laptop,
      description: 'Track freelance contracts, client messages, billable hours, and active gig deliverables.',
    );
  }
}
