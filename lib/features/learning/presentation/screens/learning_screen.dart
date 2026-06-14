import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/color_palette.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/responsive_builder.dart';
import '../../../tasks/presentation/providers/task_providers.dart';
import '../../../tasks/data/models/task_model.dart';
import '../../../projects/presentation/providers/project_providers.dart';
import '../../../projects/data/models/project_model.dart';

class LearningScreen extends ConsumerStatefulWidget {
  const LearningScreen({super.key});

  @override
  ConsumerState<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends ConsumerState<LearningScreen> {
  // Timer state
  Timer? _timer;
  int _secondsRemaining = 25 * 60; // 25 minutes Pomodoro default
  bool _isRunning = false;

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() {
        _isRunning = false;
      });
    } else {
      setState(() {
        _isRunning = true;
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_secondsRemaining > 0) {
          setState(() {
            _secondsRemaining--;
          });
        } else {
          _timer?.cancel();
          setState(() {
            _isRunning = false;
            _secondsRemaining = 25 * 60;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pomodoro Session Completed! Take a break.')),
          );
        }
      });
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _secondsRemaining = 25 * 60;
    });
  }

  String _formatTime() {
    final minutes = _secondsRemaining ~/ 60;
    final seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  final learningTasks = tasks.where((t) => t.category == 'Learning').toList();
                  final learningProjects = projects.where((p) => p.category == 'Learning').toList();
                  return _buildLearningContent(context, learningTasks, learningProjects);
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
        const Icon(LucideIcons.graduationCap, color: AppColors.primary, size: 28),
        const SizedBox(width: 12),
        Text(
          'Learning & Study Deck',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildLearningContent(
    BuildContext context,
    List<TaskModel> tasks,
    List<ProjectModel> projects,
  ) {
    final isDesktop = ResponsiveBuilder.isDesktop(context);

    return Column(
      children: [
        if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildPomodoroCard(context)),
              const SizedBox(width: 24),
              Expanded(flex: 2, child: _buildStudyLogsCard(context)),
            ],
          )
        else ...[
          _buildPomodoroCard(context),
          const SizedBox(height: 24),
          _buildStudyLogsCard(context),
        ],
        const SizedBox(height: 24),

        if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildTopicList(context, tasks)),
              const SizedBox(width: 24),
              Expanded(flex: 2, child: _buildCertificationsList(context, projects)),
            ],
          )
        else ...[
          _buildTopicList(context, tasks),
          const SizedBox(height: 24),
          _buildCertificationsList(context, projects),
        ],
      ],
    );
  }

  Widget _buildPomodoroCard(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Focus Pomodoro Session',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Icon(LucideIcons.timer, color: AppColors.primary, size: 18),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                Text(
                  _formatTime(),
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: 2.0),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _toggleTimer,
                      icon: Icon(_isRunning ? LucideIcons.pause : LucideIcons.play, size: 16),
                      label: Text(_isRunning ? 'Pause' : 'Start'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: _resetTimer,
                      icon: const Icon(LucideIcons.rotateCcw, size: 16),
                      label: const Text('Reset'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudyLogsCard(BuildContext context) {
    return SizedBox(
      height: 185,
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly study hours log',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildBar(context, 'M', 2.0, 3.0),
                  _buildBar(context, 'T', 1.5, 3.0),
                  _buildBar(context, 'W', 4.0, 3.0),
                  _buildBar(context, 'T', 0.5, 3.0),
                  _buildBar(context, 'F', 3.0, 3.0),
                  _buildBar(context, 'S', 5.0, 3.0),
                  _buildBar(context, 'S', 1.0, 3.0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBar(BuildContext context, String day, double hours, double target) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ratio = (hours / target).clamp(0.0, 1.0);
    final isMet = hours >= target;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('${hours.toStringAsFixed(1)}h', style: const TextStyle(fontSize: 8, color: AppColors.darkTextMuted)),
        const SizedBox(height: 4),
        Container(
          width: 12,
          height: 70 * ratio,
          decoration: BoxDecoration(
            color: isMet ? AppColors.secondary : AppColors.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 6),
        Text(day, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.darkBg)),
      ],
    );
  }

  Widget _buildTopicList(BuildContext context, List<TaskModel> tasks) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Target Study Topics',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          if (tasks.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text('All study milestones achieved!', style: TextStyle(color: AppColors.darkTextMuted)),
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
                          child: Text(
                            task.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                              color: task.isCompleted ? AppColors.darkTextMuted : null,
                            ),
                          ),
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

  Widget _buildCertificationsList(BuildContext context, List<ProjectModel> projects) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ongoing Certifications / Tracks',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          if (projects.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text('No active learning tracks.', style: TextStyle(color: AppColors.darkTextMuted)),
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
}
