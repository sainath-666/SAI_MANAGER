import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/color_palette.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/responsive_builder.dart';
import '../../../tasks/presentation/providers/task_providers.dart';
import '../../../tasks/data/models/task_model.dart';
import '../../../projects/presentation/providers/project_providers.dart';
import '../../../projects/data/models/project_model.dart';

class CompletedScreen extends ConsumerWidget {
  const CompletedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksListProvider);
    final projectsAsync = ref.watch(projectsListProvider);

    return Scaffold(
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
                  final completedTasks = tasks.where((t) => t.isCompleted).toList();
                  final completedProjects = projects.where((p) => p.status == 'Completed').toList();
                  return _buildArchiveContent(context, ref, completedTasks, completedProjects);
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
        const Icon(LucideIcons.checkSquare, color: AppColors.primary, size: 28),
        const SizedBox(width: 12),
        Text(
          'Completed Archives',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildArchiveContent(
    BuildContext context,
    WidgetRef ref,
    List<TaskModel> tasks,
    List<ProjectModel> projects,
  ) {
    final isDesktop = ResponsiveBuilder.isDesktop(context);
    final totalAchievements = tasks.length + projects.length;

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
              child: const Icon(LucideIcons.trophy, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Lifetime Accomplishments',
                    style: TextStyle(fontSize: 12, color: AppColors.darkTextSecondary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    totalAchievements.toString(),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${projects.length} completed projects, ${tasks.length} resolved milestones',
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
        summaryCard,
        const SizedBox(height: 24),

        if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildCompletedTasksList(context, ref, tasks)),
              const SizedBox(width: 24),
              Expanded(flex: 2, child: _buildCompletedProjectsList(context, projects)),
            ],
          )
        else ...[
          _buildCompletedTasksList(context, ref, tasks),
          const SizedBox(height: 24),
          _buildCompletedProjectsList(context, projects),
        ],
      ],
    );
  }

  Widget _buildCompletedTasksList(BuildContext context, WidgetRef ref, List<TaskModel> tasks) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resolved Tasks History',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          if (tasks.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text('No resolved tasks in history.', style: TextStyle(color: AppColors.darkTextMuted)),
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
                          value: true,
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
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  decoration: TextDecoration.lineThrough,
                                  color: AppColors.darkTextMuted,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  _buildTinyBadge(task.category, AppColors.secondary),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Due ${DateFormat('MMM d').format(task.dueDate)}',
                                    style: const TextStyle(fontSize: 10, color: AppColors.darkTextMuted),
                                  ),
                                ],
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

  Widget _buildCompletedProjectsList(BuildContext context, List<ProjectModel> projects) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Completed Projects',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          if (projects.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text('No completed projects.', style: TextStyle(color: AppColors.darkTextMuted)),
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
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.check, color: AppColors.primary, size: 16),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              project.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            _buildTinyBadge(project.category, AppColors.accent),
                          ],
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

  Widget _buildTinyBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.2), width: 0.5),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(color: color, fontSize: 7, fontWeight: FontWeight.bold),
      ),
    );
  }
}
