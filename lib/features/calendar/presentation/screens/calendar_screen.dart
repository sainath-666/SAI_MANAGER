import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/widgets/module_placeholder.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholder(
      title: 'Calendar',
      icon: LucideIcons.calendar,
      description: 'Schedule events, set reminders, sync tasks, and visualize weekly schedules.',
    );
  }
}
