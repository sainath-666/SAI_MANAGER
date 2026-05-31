import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/widgets/module_placeholder.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholder(
      title: 'Notes',
      icon: LucideIcons.fileText,
      description: 'Quick notes, Markdown documents, brainstorming boards, and bookmarks.',
    );
  }
}
