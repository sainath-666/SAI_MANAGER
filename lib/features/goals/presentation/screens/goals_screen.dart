import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/color_palette.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/responsive_builder.dart';
import '../../../tasks/presentation/providers/task_providers.dart';
import '../../../tasks/data/models/task_model.dart';
import '../../../projects/presentation/providers/project_providers.dart';
import '../../../projects/data/models/project_model.dart';
import '../../data/models/habit_model.dart';
import '../providers/habit_providers.dart';

class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen> {
  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksListProvider);
    final projectsAsync = ref.watch(projectsListProvider);
    final habitsAsync = ref.watch(habitsListProvider);

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
                data: (projects) => habitsAsync.when(
                  data: (habits) {
                    final goalTasks = tasks.where((t) => t.category == 'Goals').toList();
                    final goalProjects = projects.where((p) => p.category == 'Goals').toList();
                    return _buildGoalsContent(context, goalTasks, goalProjects, habits);
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(child: Text('Error loading habits: $e')),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text('Error loading projects: $e')),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Error loading tasks: $e')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const Icon(LucideIcons.award, color: AppColors.primary, size: 28),
        const SizedBox(width: 12),
        Text(
          'Goals & Habits Desk',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildGoalsContent(
    BuildContext context,
    List<TaskModel> tasks,
    List<ProjectModel> projects,
    List<HabitModel> habits,
  ) {
    final isDesktop = ResponsiveBuilder.isDesktop(context);

    // Calculate goals stats
    final totalMilestones = tasks.length + projects.length;
    final completedMilestones = tasks.where((t) => t.isCompleted).length +
        projects.where((p) => p.status == 'Completed').length;
    final progressVal = totalMilestones == 0 ? 1.0 : (completedMilestones / totalMilestones);

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
              child: const Icon(LucideIcons.target, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Overall Goal Progression',
                    style: TextStyle(fontSize: 12, color: AppColors.darkTextSecondary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${(progressVal * 100).toInt()}%',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$completedMilestones of $totalMilestones objectives achieved',
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
      children: [
        summaryCard,
        const SizedBox(height: 24),
        if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildHabitsCard(context, habits)),
              const SizedBox(width: 24),
              Expanded(flex: 2, child: _buildGoalObjectives(context, tasks, projects)),
            ],
          )
        else ...[
          _buildHabitsCard(context, habits),
          const SizedBox(height: 24),
          _buildGoalObjectives(context, tasks, projects),
        ],
      ],
    );
  }

  Widget _buildHabitsCard(BuildContext context, List<HabitModel> habits) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daily Habits Streak Tracker',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(LucideIcons.plus, size: 18, color: AppColors.primary),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _showAddHabitDialog(context),
                    tooltip: 'Add Habit',
                  ),
                  const SizedBox(width: 12),
                  const Icon(LucideIcons.flame, color: AppColors.warning, size: 20),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (habits.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text('No habits configured.', style: TextStyle(color: AppColors.darkTextMuted)),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: habits.length,
              itemBuilder: (context, index) {
                final habit = habits[index];
                return Padding(
                  key: ValueKey(habit.id),
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
                          value: habit.done,
                          activeColor: AppColors.primary,
                          onChanged: (val) {
                            ref.read(habitsListProvider.notifier).toggleHabitCompletion(habit);
                          },
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            habit.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              decoration: habit.done ? TextDecoration.lineThrough : null,
                              color: habit.done ? AppColors.darkTextMuted : null,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(LucideIcons.flame, size: 16, color: AppColors.warning),
                            const SizedBox(width: 4),
                            Text(
                              '${habit.streak} days',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.warning),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(LucideIcons.trash2, size: 14, color: AppColors.error),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                ref.read(habitsListProvider.notifier).deleteHabit(habit.id);
                              },
                            ),
                          ],
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

  Widget _buildGoalObjectives(
    BuildContext context,
    List<TaskModel> tasks,
    List<ProjectModel> projects,
  ) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ongoing Objectives',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          if (tasks.isEmpty && projects.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text('No objectives registered.', style: TextStyle(color: AppColors.darkTextMuted)),
              ),
            )
          else ...[
            if (projects.isNotEmpty) ...[
              const Text(
                'PROJECT MILESTONES',
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 0.5),
              ),
              const SizedBox(height: 8),
              ...projects.map((proj) {
                return Padding(
                  key: ValueKey(proj.id),
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Icon(
                        proj.status == 'Completed' ? LucideIcons.checkCircle2 : LucideIcons.circle,
                        color: proj.status == 'Completed' ? AppColors.primary : AppColors.darkTextMuted,
                        size: 16,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          proj.name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            decoration: proj.status == 'Completed' ? TextDecoration.lineThrough : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
            if (tasks.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'TARGET GOALS',
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.secondary, letterSpacing: 0.5),
              ),
              const SizedBox(height: 8),
              ...tasks.map((task) {
                return Padding(
                  key: ValueKey(task.id),
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Icon(
                        task.isCompleted ? LucideIcons.checkCircle2 : LucideIcons.circle,
                        color: task.isCompleted ? AppColors.secondary : AppColors.darkTextMuted,
                        size: 16,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ],
      ),
    );
  }

  void _showAddHabitDialog(BuildContext context) {
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Track New Habit',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'Habit Title',
              hintText: 'e.g. Read 15 mins daily',
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
                  final newHabit = HabitModel(
                    id: const Uuid().v4(),
                    title: titleController.text,
                    streak: 0,
                    done: false,
                  );
                  ref.read(habitsListProvider.notifier).addHabit(newHabit);
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
