import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/widgets/module_placeholder.dart';

class DevWorkspaceScreen extends StatelessWidget {
  const DevWorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholder(
      title: 'Developer Workspace',
      icon: LucideIcons.code,
      description: 'API testing console, JSON formatting tools, base64 converters, and developer workspace integration logs.',
    );
  }
}
