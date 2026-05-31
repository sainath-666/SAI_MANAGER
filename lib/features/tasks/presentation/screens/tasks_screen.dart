import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/color_palette.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../data/models/task_model.dart';
import '../providers/task_providers.dart';

final taskFilterProvider = StateProvider<String>((ref) => 'All');

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksListProvider);
    final currentFilter = ref.watch(taskFilterProvider);

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
                          LucideIcons.listTodo,
                          color: AppColors.primary,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Tasks Workspace',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage, organize, and track personal and professional milestones.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddTaskDialog(context, ref),
                  icon: const Icon(LucideIcons.plus, size: 16),
                  label: const Text('Add Task'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Filters Tabs Row
            Row(
              children: ['All', 'Pending', 'Completed'].map((filter) {
                final isSelected = currentFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val)
                        ref.read(taskFilterProvider.notifier).state = filter;
                    },
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.primary : null,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Tasks List Display
            tasksAsync.when(
              data: (tasks) {
                // Apply filter
                final filteredTasks = tasks.where((task) {
                  if (currentFilter == 'Pending') return !task.isCompleted;
                  if (currentFilter == 'Completed') return task.isCompleted;
                  return true;
                }).toList();

                if (filteredTasks.isEmpty) {
                  return GlassCard(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.checkCircle,
                            size: 48,
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No tasks found',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Enjoy your free time or add a new task above!',
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) {
                    final task = filteredTasks[index];
                    return _buildTaskTile(context, ref, task);
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

  Widget _buildTaskTile(BuildContext context, WidgetRef ref, TaskModel task) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCompleted = task.isCompleted;

    // Color based on Priority
    Color priorityColor = AppColors.darkTextMuted;
    if (task.priority.toLowerCase() == 'high') priorityColor = AppColors.error;
    if (task.priority.toLowerCase() == 'medium')
      priorityColor = AppColors.warning;
    if (task.priority.toLowerCase() == 'low') priorityColor = AppColors.info;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Checkbox
            Checkbox(
              value: isCompleted,
              onChanged: (_) {
                ref.read(tasksListProvider.notifier).toggleTaskCompletion(task);
              },
              activeColor: AppColors.primary,
            ),
            const SizedBox(width: 8),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      color: isCompleted
                          ? (isDark
                                ? AppColors.darkTextMuted
                                : AppColors.lightTextMuted)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    task.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Metadata row
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _buildChip(
                        context,
                        label: task.category,
                        color: AppColors.secondary,
                      ),
                      _buildChip(
                        context,
                        label: task.priority.toUpperCase(),
                        color: priorityColor,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
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
                            DateFormat('MMM d, yyyy').format(task.dueDate),
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.darkTextMuted
                                  : AppColors.lightTextMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Actions
            IconButton(
              icon: const Icon(
                LucideIcons.trash2,
                size: 18,
                color: AppColors.error,
              ),
              onPressed: () {
                ref.read(tasksListProvider.notifier).deleteTask(task.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(
    BuildContext context, {
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String category = 'Office Work';
    String priority = 'Medium';
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'Add New Task',
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
                        decoration: const InputDecoration(
                          labelText: 'Task Title',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
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
                            [
                                  'Office Work',
                                  'Freelance',
                                  'Finance',
                                  'Goals',
                                  'Learning',
                                  'Personal',
                                ]
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
                      // Dropdown: Priority
                      DropdownButtonFormField<String>(
                        initialValue: priority,
                        decoration: const InputDecoration(
                          labelText: 'Priority',
                        ),
                        items: ['Low', 'Medium', 'High']
                            .map(
                              (p) => DropdownMenuItem(value: p, child: Text(p)),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => priority = val);
                        },
                      ),
                      const SizedBox(height: 16),
                      // Date Selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Due Date: ${DateFormat('MMM d, yyyy').format(selectedDate)}',
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
                    if (titleController.text.isNotEmpty) {
                      final newTask = TaskModel(
                        id: const Uuid().v4(),
                        title: titleController.text,
                        description: descController.text,
                        dueDate: selectedDate,
                        category: category,
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
