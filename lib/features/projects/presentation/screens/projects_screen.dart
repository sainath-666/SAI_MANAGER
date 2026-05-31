import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/color_palette.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/responsive_builder.dart';
import '../../data/models/project_model.dart';
import '../providers/project_providers.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsListProvider);
    final isDesktop = ResponsiveBuilder.isDesktop(context);
    final isTablet = ResponsiveBuilder.isTablet(context);

    // Dynamic grid cross axis count
    final gridCount = isDesktop ? 3 : (isTablet ? 2 : 1);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.folderOpen,
                          color: AppColors.primary,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Projects Directory',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Monitor high-level goals, deliverables, and progress percentages.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddProjectDialog(context, ref),
                  icon: const Icon(LucideIcons.plus, size: 16),
                  label: const Text('New Project'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Grid content
            projectsAsync.when(
              data: (projects) {
                if (projects.isEmpty) {
                  return GlassCard(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.folder,
                            size: 48,
                            color: AppColors.secondary.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No projects registered',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Click New Project to start tracking a goal.',
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: projects.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: gridCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    mainAxisExtent: 220, // Keep card height consistent
                  ),
                  itemBuilder: (context, index) {
                    final project = projects[index];
                    return _buildProjectCard(context, ref, project);
                  },
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, stack) => Text('Error: $err'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectCard(
    BuildContext context,
    WidgetRef ref,
    ProjectModel project,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Status colors
    Color statusColor = AppColors.darkTextMuted;
    if (project.status == 'Planning') statusColor = AppColors.info;
    if (project.status == 'In Progress') statusColor = AppColors.secondary;
    if (project.status == 'Review') statusColor = AppColors.warning;
    if (project.status == 'Completed') statusColor = AppColors.primary;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row: Category & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBadge(project.category, AppColors.accent),
              _buildBadge(project.status, statusColor),
            ],
          ),
          const SizedBox(height: 12),
          // Project Title & Trash Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  project.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  LucideIcons.trash2,
                  size: 16,
                  color: AppColors.error,
                ),
                onPressed: () {
                  ref
                      .read(projectsListProvider.notifier)
                      .deleteProject(project.id);
                },
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Description
          Expanded(
            child: Text(
              project.description,
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 12),
          // Progress Percentage and Tasks Fraction
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tasks: ${project.completedTasksCount}/${project.tasksCount}',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              Text(
                '${(project.progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: project.progress,
              backgroundColor: isDark
                  ? AppColors.darkBorder
                  : AppColors.lightBorder,
              color: AppColors.primary,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          // Due Date Icon
          Row(
            children: [
              Icon(
                LucideIcons.calendar,
                size: 12,
                color: isDark
                    ? AppColors.darkTextMuted
                    : AppColors.lightTextMuted,
              ),
              const SizedBox(width: 4),
              Text(
                'Due ${DateFormat('MMM d, yyyy').format(project.dueDate)}',
                style: TextStyle(
                  fontSize: 10,
                  color: isDark
                      ? AppColors.darkTextMuted
                      : AppColors.lightTextMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showAddProjectDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    String category = 'Freelance';
    String status = 'In Progress';
    int tasksCount = 5;
    DateTime selectedDate = DateTime.now().add(const Duration(days: 30));

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'New Project Spec',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 400,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Project Name',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descController,
                        decoration: const InputDecoration(
                          labelText: 'Objectives / Goal',
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      // Dropdown: Category
                      DropdownButtonFormField<String>(
                        initialValue: category,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                        ),
                        items:
                            ['Office Work', 'Freelance', 'Learning', 'Personal']
                                .map(
                                  (cat) => DropdownMenuItem(
                                    value: cat,
                                    child: Text(cat),
                                  ),
                                )
                                .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => category = val);
                        },
                      ),
                      const SizedBox(height: 16),
                      // Dropdown: Status
                      DropdownButtonFormField<String>(
                        initialValue: status,
                        decoration: const InputDecoration(labelText: 'Status'),
                        items:
                            ['Planning', 'In Progress', 'Review', 'Completed']
                                .map(
                                  (st) => DropdownMenuItem(
                                    value: st,
                                    child: Text(st),
                                  ),
                                )
                                .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => status = val);
                        },
                      ),
                      const SizedBox(height: 16),
                      // Number: Total Tasks
                      TextFormField(
                        initialValue: tasksCount.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Target Tasks Count',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (val) {
                          final count = int.tryParse(val);
                          if (count != null) {
                            setState(() => tasksCount = count);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      // Date Selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Target Date: ${DateFormat('MMM d, yyyy').format(selectedDate)}',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          TextButton(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365),
                                ),
                              );
                              if (picked != null) {
                                setState(() => selectedDate = picked);
                              }
                            },
                            child: const Text('Select Date'),
                          ),
                        ],
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
                    if (nameController.text.isNotEmpty) {
                      final newProj = ProjectModel(
                        id: const Uuid().v4(),
                        name: nameController.text,
                        description: descController.text,
                        category: category,
                        progress: status == 'Completed'
                            ? 1.0
                            : (status == 'Planning' ? 0.0 : 0.25),
                        status: status,
                        tasksCount: tasksCount,
                        completedTasksCount: status == 'Completed'
                            ? tasksCount
                            : (status == 'Planning' ? 0 : 1),
                        dueDate: selectedDate,
                      );
                      ref
                          .read(projectsListProvider.notifier)
                          .addProject(newProj);
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
