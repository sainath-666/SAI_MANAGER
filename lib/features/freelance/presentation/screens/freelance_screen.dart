import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/color_palette.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/responsive_builder.dart';
import '../../../tasks/presentation/providers/task_providers.dart';
import '../../../tasks/data/models/task_model.dart';
import '../../../projects/presentation/providers/project_providers.dart';
import '../../../projects/data/models/project_model.dart';

class FreelanceScreen extends ConsumerWidget {
  const FreelanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksListProvider);
    final projectsAsync = ref.watch(projectsListProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddFreelanceTaskDialog(context, ref),
        backgroundColor: AppColors.primary,
        icon: const Icon(LucideIcons.plus, size: 20),
        label: const Text('New Client Task', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(context),
            const SizedBox(height: 24),

            tasksAsync.when(
              data: (tasks) => projectsAsync.when(
                data: (projects) {
                  final freelanceTasks = tasks.where((t) => t.category == 'Freelance').toList();
                  final freelanceProjects = projects.where((p) => p.category == 'Freelance').toList();
                  return _buildWorkspaceContent(context, ref, freelanceTasks, freelanceProjects);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Text('Error loading projects: $e'),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Text('Error loading tasks: $e'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const Icon(LucideIcons.laptop, color: AppColors.primary, size: 28),
        const SizedBox(width: 12),
        Text(
          'Freelance Console',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildWorkspaceContent(
    BuildContext context,
    WidgetRef ref,
    List<TaskModel> tasks,
    List<ProjectModel> projects,
  ) {
    final isDesktop = ResponsiveBuilder.isDesktop(context);
    final activeProjects = projects.where((p) => p.status != 'Completed').length;

    final summaryCard = SizedBox(
      height: 110,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(LucideIcons.dollarSign, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Active Contract Value',
                    style: TextStyle(fontSize: 12, color: AppColors.darkTextSecondary),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    '\$3,700.00',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Forecast from $activeProjects active contracts',
                    style: const TextStyle(fontSize: 10, color: AppColors.darkTextMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    final projectsCard = SizedBox(
      height: 110,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(LucideIcons.fileSpreadsheet, color: AppColors.secondary, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Client Deliverables',
                    style: TextStyle(fontSize: 12, color: AppColors.darkTextSecondary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tasks.where((t) => !t.isCompleted).length.toString(),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${tasks.length} total client milestones',
                    style: const TextStyle(fontSize: 10, color: AppColors.darkTextMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isDesktop)
          Row(
            children: [
              Expanded(child: summaryCard),
              const SizedBox(width: 16),
              Expanded(child: projectsCard),
            ],
          )
        else ...[
          summaryCard,
          const SizedBox(height: 16),
          projectsCard,
        ],
        const SizedBox(height: 24),

        if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildTasksList(context, ref, tasks)),
              const SizedBox(width: 24),
              Expanded(flex: 2, child: _buildProjectsList(context, projects)),
            ],
          )
        else ...[
          _buildTasksList(context, ref, tasks),
          const SizedBox(height: 24),
          _buildProjectsList(context, projects),
        ],
      ],
    );
  }

  Widget _buildTasksList(BuildContext context, WidgetRef ref, List<TaskModel> tasks) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Client Task List',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          if (tasks.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text('All client deliverables met!', style: TextStyle(color: AppColors.darkTextMuted)),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Padding(
                  key: ValueKey(task.id),
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkBg.withOpacity(0.3) : AppColors.lightBg.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder.withOpacity(0.5) : AppColors.lightBorder.withOpacity(0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: task.isCompleted,
                          activeColor: AppColors.primary,
                          onChanged: (_) {
                            ref.read(tasksListProvider.notifier).toggleTaskCompletion(task);
                          },
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                  color: task.isCompleted ? AppColors.darkTextMuted : null,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                task.description,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(LucideIcons.trash2, size: 16, color: AppColors.error),
                          onPressed: () {
                            ref.read(tasksListProvider.notifier).deleteTask(task.id);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildProjectsList(BuildContext context, List<ProjectModel> projects) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Client Contracts',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          if (projects.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text('No active client contracts.', style: TextStyle(color: AppColors.darkTextMuted)),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];
                return Padding(
                  key: ValueKey(project.id),
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              project.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${(project.progress * 100).toInt()}%',
                            style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: project.progress,
                          minHeight: 5,
                          backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  void _showAddFreelanceTaskDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String priority = 'Medium';
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'Add Client Milestone',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 400,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: 'Task Title'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descController,
                        decoration: const InputDecoration(labelText: 'Milestone Goals'),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: priority,
                        decoration: const InputDecoration(labelText: 'Priority'),
                        items: ['Low', 'Medium', 'High']
                            .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => priority = val);
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Due: ${DateFormat('MMM d, yyyy').format(selectedDate)}',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          TextButton(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
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
                    if (titleController.text.isNotEmpty) {
                      final newTask = TaskModel(
                        id: const Uuid().v4(),
                        title: titleController.text,
                        description: descController.text,
                        dueDate: selectedDate,
                        category: 'Freelance',
                        priority: priority,
                        isCompleted: false,
                      );
                      ref.read(tasksListProvider.notifier).addTask(newTask);
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
