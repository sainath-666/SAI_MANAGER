import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/color_palette.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/responsive_builder.dart';
import '../../../tasks/presentation/providers/task_providers.dart';
import '../../../projects/presentation/providers/project_providers.dart';
import '../../../finance/data/models/finance_summary.dart';
import '../../../finance/presentation/providers/finance_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksListProvider);
    final projectsAsync = ref.watch(projectsListProvider);
    final financeAsync = ref.watch(financeSummaryProvider);
    final isDesktop = ResponsiveBuilder.isDesktop(context);

    final tasks = tasksAsync.valueOrNull;
    final projects = projectsAsync.valueOrNull;
    final finance = financeAsync.valueOrNull;

    final Widget statsWidget;
    if (tasks == null || projects == null) {
      if (tasksAsync.isLoading || projectsAsync.isLoading) {
        statsWidget = const LinearProgressIndicator();
      } else {
        statsWidget = const SizedBox();
      }
    } else {
      final pendingTasks = tasks.where((t) => !t.isCompleted).length;
      final activeProjects = projects.where((p) => p.status != 'Completed').length;
      
      if (finance == null) {
        if (financeAsync.isLoading) {
          statsWidget = const LinearProgressIndicator();
        } else {
          statsWidget = _buildStatsGrid(
            context,
            pendingTasks,
            activeProjects,
            const FinanceSummary(
              totalBalance: 0,
              monthlyIncome: 0,
              monthlyExpenses: 0,
              weeklyData: [0, 0, 0, 0, 0, 0, 0],
            ),
          );
        }
      } else {
        statsWidget = _buildStatsGrid(
          context,
          pendingTasks,
          activeProjects,
          finance,
        );
      }
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(context),
            const SizedBox(height: 24),

            // Dynamic Stats Grid
            statsWidget,
            const SizedBox(height: 24),

            // Responsive Middle row (Charts & Task Summaries)
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: _buildFinanceChartCard(context, financeAsync),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 4,
                    child: _buildRecentTasksCard(context, ref),
                  ),
                ],
              )
            else ...[
              _buildFinanceChartCard(context, financeAsync),
              const SizedBox(height: 16),
              _buildRecentTasksCard(context, ref),
            ],
            const SizedBox(height: 16),

            // Bottom Grid: Project Progress Trackers
            _buildProjectsOverview(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now());
    final statusBadge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.shieldCheck, color: AppColors.primary, size: 16),
          const SizedBox(width: 6),
          Text(
            'API Ready',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );

    return Wrap(
      spacing: 16,
      runSpacing: 12,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: ResponsiveBuilder.isDesktop(context)
              ? 420
              : MediaQuery.sizeOf(context).width - 48,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome Back, Sai',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                formattedDate,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        statusBadge,
      ],
    );
  }

  Widget _buildStatsGrid(
    BuildContext context,
    int pendingTasks,
    int activeProjects,
    FinanceSummary finance,
  ) {
    final isDesktop = ResponsiveBuilder.isDesktop(context);
    final isTablet = ResponsiveBuilder.isTablet(context);

    final card1 = SizedBox(
      height: 110,
      child: _buildStatCard(
        context,
        icon: LucideIcons.dollarSign,
        iconColor: AppColors.primary,
        title: 'Total Balance',
        value: '\$${finance.totalBalance.toStringAsFixed(0)}',
        subtitle: 'Synced ledger',
      ),
    );
    final card2 = SizedBox(
      height: 110,
      child: _buildStatCard(
        context,
        icon: LucideIcons.listTodo,
        iconColor: AppColors.secondary,
        title: 'Pending Tasks',
        value: pendingTasks.toString(),
        subtitle: 'Active priorities',
      ),
    );
    final card3 = SizedBox(
      height: 110,
      child: _buildStatCard(
        context,
        icon: LucideIcons.folderOpen,
        iconColor: AppColors.accent,
        title: 'Active Projects',
        value: activeProjects.toString(),
        subtitle: 'Milestones tracked',
      ),
    );
    final card4 = SizedBox(
      height: 110,
      child: _buildStatCard(
        context,
        icon: LucideIcons.award,
        iconColor: AppColors.warning,
        title: 'Monthly Expenses',
        value: '\$${finance.monthlyExpenses.toStringAsFixed(0)}',
        subtitle: 'Current ledger',
      ),
    );

    if (isDesktop) {
      return Row(
        children: [
          Expanded(child: card1),
          const SizedBox(width: 16),
          Expanded(child: card2),
          const SizedBox(width: 16),
          Expanded(child: card3),
          const SizedBox(width: 16),
          Expanded(child: card4),
        ],
      );
    } else if (isTablet) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: card1),
              const SizedBox(width: 16),
              Expanded(child: card2),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: card3),
              const SizedBox(width: 16),
              Expanded(child: card4),
            ],
          ),
        ],
      );
    } else {
      return Column(
        children: [
          card1,
          const SizedBox(height: 16),
          card2,
          const SizedBox(height: 16),
          card3,
          const SizedBox(height: 16),
          card4,
        ],
      );
    }
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceChartCard(
    BuildContext context,
    AsyncValue<FinanceSummary> financeAsync,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final weeklyData = financeAsync.valueOrNull?.weeklyData ?? const [0, 0, 0, 0, 0, 0, 0];
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Weekly Expense Trend',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Icon(LucideIcons.trendingUp, color: AppColors.primary, size: 18),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Visualized expenses from cashbook ledger.',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                        if (value >= 0 && value < 7) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              days[value.toInt()],
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: 22,
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      weeklyData.length,
                      (index) => FlSpot(index.toDouble(), weeklyData[index]),
                    ),
                    isCurved: true,
                    barWidth: 3,
                    color: AppColors.primary,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTasksCard(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksListProvider);

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Tasks',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          tasksAsync.when(
            data: (tasks) {
              final pending = tasks.where((t) => !t.isCompleted).take(3).toList();
              if (pending.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text('All tasks completed!'),
                );
              }
              return Column(
                children: pending.map((task) {
                  return Padding(
                    key: ValueKey(task.id),
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Checkbox(
                          value: task.isCompleted,
                          onChanged: (_) {
                            ref.read(tasksListProvider.notifier).toggleTaskCompletion(task);
                          },
                          activeColor: AppColors.primary,
                        ),
                        Expanded(
                          child: Text(
                            task.title,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            task.category,
                            style: const TextStyle(color: AppColors.accent, fontSize: 8, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsOverview(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ongoing Projects Progress',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          projectsAsync.when(
            data: (projects) {
              final active = projects.where((p) => p.status != 'Completed').take(3).toList();
              if (active.isEmpty) {
                return const Text('No active projects.');
              }
              return Column(
                children: active.map((proj) {
                  return Padding(
                    key: ValueKey(proj.id),
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              proj.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Text(
                              '${(proj.progress * 100).toInt()}%',
                              style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: proj.progress,
                            minHeight: 5,
                            backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => const SizedBox(),
          ),
        ],
      ),
    );
  }
}
