import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/widgets/module_placeholder.dart';

class LearningScreen extends StatelessWidget {
  const LearningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholder(
      title: 'Learning & Career',
      icon: LucideIcons.graduationCap,
      description: 'Track ongoing course certificates, reading lists, study flashcards, and skill matrices.',
    );
  }
}
