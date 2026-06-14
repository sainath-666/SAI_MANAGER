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
import '../../data/models/calendar_event.dart';
import '../providers/calendar_providers.dart';

enum CalendarViewType { month, schedule }

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _currentMonth = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  CalendarViewType _viewType = CalendarViewType.month;

  @override
  Widget build(BuildContext context) {
    final events = ref.watch(calendarEventsProvider);
    final tasksAsync = ref.watch(tasksListProvider);
    final tasks = tasksAsync.valueOrNull ?? [];

    final isDesktop = ResponsiveBuilder.isDesktop(context);

    // Filter events and tasks for the selected day
    final dayEvents = events.where((e) => _isSameDay(e.date, _selectedDate)).toList();
    final dayTasks = tasks.where((t) => _isSameDay(t.dueDate, _selectedDate)).toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEventDialog(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(LucideIcons.plus, size: 20),
        label: const Text('Add Event', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Calendar Toolbar Header
            _buildToolbar(context),
            const SizedBox(height: 24),

            if (_viewType == CalendarViewType.month) ...[
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Calendar grid card takes more space on desktop
                    Expanded(
                      flex: 3,
                      child: _buildMonthCalendarCard(context, events, tasks),
                    ),
                    const SizedBox(width: 24),
                    // Selected Day Agenda Panel
                    Expanded(
                      flex: 2,
                      child: _buildAgendaPanel(context, dayEvents, dayTasks),
                    ),
                  ],
                )
              else ...[
                _buildMonthCalendarCard(context, events, tasks),
                const SizedBox(height: 24),
                _buildAgendaPanel(context, dayEvents, dayTasks),
              ],
            ] else ...[
              // Schedule View
              _buildScheduleView(context, events, tasks),
            ],
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildToolbar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formattedMonth = DateFormat('MMMM yyyy').format(_currentMonth);

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Navigation & Month Title Row
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.calendar, color: AppColors.primary, size: 28),
            const SizedBox(width: 12),
            Text(
              formattedMonth,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(width: 16),
            // Today Button
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _currentMonth = DateTime.now();
                  _selectedDate = DateTime.now();
                });
              },
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('Today', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),
            // Navigation Back/Next
            IconButton(
              icon: const Icon(LucideIcons.chevronLeft, size: 20),
              onPressed: () {
                setState(() {
                  _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
                });
              },
            ),
            IconButton(
              icon: const Icon(LucideIcons.chevronRight, size: 20),
              onPressed: () {
                setState(() {
                  _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
                });
              },
            ),
          ],
        ),
        // Toggle view types (Month vs Agenda/Schedule List)
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildViewTypeButton(CalendarViewType.month, 'Month'),
              _buildViewTypeButton(CalendarViewType.schedule, 'Schedule'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildViewTypeButton(CalendarViewType type, String label) {
    final isSelected = _viewType == type;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        setState(() {
          _viewType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildMonthCalendarCard(
    BuildContext context,
    List<CalendarEvent> events,
    List<TaskModel> tasks,
  ) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Week days headers: M, T, W, T, F, S, S
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'].map((day) {
              return Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      day,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        color: AppColors.primary,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const Divider(height: 12),
          // Days grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 42, // 6 rows * 7 days
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (context, index) {
              final date = _getDateForGridIndex(index);
              final isCurrentMonth = date.month == _currentMonth.month;
              final isSelected = _isSameDay(date, _selectedDate);
              final isToday = _isSameDay(date, DateTime.now());

              final dayEvents = events.where((e) => _isSameDay(e.date, date)).toList();
              final dayTasks = tasks.where((t) => _isSameDay(t.dueDate, date)).toList();

              return _buildCalendarDayCell(
                context,
                date: date,
                isCurrentMonth: isCurrentMonth,
                isSelected: isSelected,
                isToday: isToday,
                dayEvents: dayEvents,
                dayTasks: dayTasks,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarDayCell(
    BuildContext context, {
    required DateTime date,
    required bool isCurrentMonth,
    required bool isSelected,
    required bool isToday,
    required List<CalendarEvent> dayEvents,
    required List<TaskModel> dayTasks,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color textColor;
    if (isToday) {
      textColor = Colors.white;
    } else if (isSelected) {
      textColor = AppColors.primary;
    } else if (isCurrentMonth) {
      textColor = isDark ? Colors.white : AppColors.darkBg;
    } else {
      textColor = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isToday
              ? AppColors.primary
              : (isSelected
                  ? AppColors.primary.withOpacity(0.12)
                  : Colors.transparent),
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 1.5)
              : Border.all(
                  color: isDark ? AppColors.darkBorder.withOpacity(0.3) : AppColors.lightBorder.withOpacity(0.3),
                  width: 0.5,
                ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              date.day.toString(),
              style: TextStyle(
                fontWeight: (isToday || isSelected) ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
                color: textColor,
              ),
            ),
            const SizedBox(height: 6),
            // Indicators Row
            if (dayEvents.isNotEmpty || dayTasks.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Event indicators
                  ...dayEvents.take(3).map((event) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1.5),
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: event.color,
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                  // Task indicators (represented by an accent secondary color dot)
                  if (dayTasks.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1.5),
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgendaPanel(
    BuildContext context,
    List<CalendarEvent> dayEvents,
    List<TaskModel> dayTasks,
  ) {
    final formattedDay = DateFormat('EEEE, MMMM d').format(_selectedDate);

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formattedDay,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
              Icon(LucideIcons.calendarDays, color: AppColors.primary, size: 18),
            ],
          ),
          const SizedBox(height: 16),
          if (dayEvents.isEmpty && dayTasks.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 36),
              child: Center(
                child: Column(
                  children: [
                    Icon(LucideIcons.smile, color: AppColors.primary, size: 36),
                    const SizedBox(height: 12),
                    Text(
                      'No events scheduled',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Relax or schedule an item below.',
                      style: TextStyle(fontSize: 11, color: AppColors.darkTextMuted),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            // Events list
            if (dayEvents.isNotEmpty) ...[
              const Text(
                'EVENTS',
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 0.5),
              ),
              const SizedBox(height: 8),
              ...dayEvents.map((event) => _buildEventTile(context, event)),
              const SizedBox(height: 16),
            ],

            // Tasks due list
            if (dayTasks.isNotEmpty) ...[
              const Text(
                'TASKS DUE',
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.secondary, letterSpacing: 0.5),
              ),
              const SizedBox(height: 8),
              ...dayTasks.map((task) => _buildTaskAgendaTile(context, task)),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildEventTile(BuildContext context, CalendarEvent event) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final startStr = event.startTime.format(context);
    final endStr = event.endTime.format(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBg.withOpacity(0.5) : AppColors.lightBg.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border(
          left: BorderSide(color: event.color, width: 4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      LucideIcons.clock,
                      size: 10,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$startStr - $endStr',
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildTinyBadge(event.category, event.color),
                  ],
                ),
                if (event.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    event.description,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(LucideIcons.trash2, size: 14, color: AppColors.error),
            onPressed: () {
              ref.read(calendarEventsProvider.notifier).deleteEvent(event.id);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTaskAgendaTile(BuildContext context, TaskModel task) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBg.withOpacity(0.3) : AppColors.lightBg.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppColors.darkBorder.withOpacity(0.5) : AppColors.lightBorder.withOpacity(0.5),
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: task.isCompleted,
            activeColor: AppColors.secondary,
            onChanged: (_) {
              ref.read(tasksListProvider.notifier).toggleTaskCompletion(task);
            },
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                    color: task.isCompleted
                        ? (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)
                        : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    _buildTinyBadge(task.category, AppColors.secondary),
                    const SizedBox(width: 8),
                    _buildTinyBadge(task.priority, task.priority.toLowerCase() == 'high' ? AppColors.error : AppColors.warning),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTinyBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.2), width: 0.5),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(color: color, fontSize: 7, fontWeight: FontWeight.w900),
      ),
    );
  }

  // --- SCHEDULE / AGENDA VIEW ---

  Widget _buildScheduleView(
    BuildContext context,
    List<CalendarEvent> events,
    List<TaskModel> tasks,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Collate next 30 days of schedule
    final scheduleDays = <DateTime>[];
    final now = DateTime.now();
    for (int i = 0; i < 30; i++) {
      scheduleDays.add(DateTime(now.year, now.month, now.day + i));
    }

    final activeScheduleDays = scheduleDays.where((day) {
      final dayEvents = events.any((e) => _isSameDay(e.date, day));
      final dayTasks = tasks.any((t) => _isSameDay(t.dueDate, day));
      return dayEvents || dayTasks;
    }).toList();

    if (activeScheduleDays.isEmpty) {
      return GlassCard(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              const Icon(LucideIcons.calendarX, size: 48, color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                'Your schedule is clear!',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text('No events or tasks are scheduled for the next 30 days.'),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activeScheduleDays.length,
      itemBuilder: (context, index) {
        final day = activeScheduleDays[index];
        final dayEvents = events.where((e) => _isSameDay(e.date, day)).toList();
        final dayTasks = tasks.where((t) => _isSameDay(t.dueDate, day)).toList();

        final dateStr = DateFormat('EEEE, MMM d').format(day);
        final isToday = _isSameDay(day, DateTime.now());

        return Padding(
          key: ValueKey(day.millisecondsSinceEpoch),
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date divider
              Row(
                children: [
                  Text(
                    dateStr,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isToday ? AppColors.primary : (isDark ? Colors.white : AppColors.darkBg),
                    ),
                  ),
                  if (isToday) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'TODAY',
                        style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  const SizedBox(width: 12),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 12),
              // Agenda widgets
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Column(
                  children: [
                    ...dayEvents.map((e) => _buildEventTile(context, e)),
                    ...dayTasks.map((t) => _buildTaskAgendaTile(context, t)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- ACTIONS & DIALOGS ---

  void _showAddEventDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String category = 'Office Work';
    Color selectedColor = calendarColors[4]; // Default to Basil (Green)
    TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 10, minute: 0);
    DateTime eventDate = _selectedDate;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'Schedule New Event',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 420,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Event Title',
                          hintText: 'e.g. Sync session',
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Description
                      TextField(
                        controller: descController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),

                      // Category Dropdown
                      DropdownButtonFormField<String>(
                        initialValue: category,
                        decoration: const InputDecoration(labelText: 'Category'),
                        items: ['Office Work', 'Freelance', 'Learning', 'Personal', 'General']
                            .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => category = val);
                        },
                      ),
                      const SizedBox(height: 16),

                      // Color selector grid
                      const Text(
                        'Event Color Tag',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 48,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: calendarColors.length,
                          itemBuilder: (context, index) {
                            final color = calendarColors[index];
                            final isColorSelected = selectedColor == color;
                            return GestureDetector(
                              onTap: () => setState(() => selectedColor = color),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: isColorSelected
                                      ? Border.all(color: Colors.white, width: 2.5)
                                      : null,
                                  boxShadow: isColorSelected
                                      ? [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 4)]
                                      : null,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Date Picker Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Date: ${DateFormat('MMM d, yyyy').format(eventDate)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextButton.icon(
                            icon: const Icon(LucideIcons.calendar, size: 16),
                            label: const Text('Change'),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: eventDate,
                                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (picked != null) {
                                setState(() => eventDate = picked);
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Time range Pickers
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Start: ${startTime.format(context)}', style: const TextStyle(fontSize: 12)),
                                TextButton(
                                  onPressed: () async {
                                    final time = await showTimePicker(
                                      context: context,
                                      initialTime: startTime,
                                    );
                                    if (time != null) {
                                      setState(() => startTime = time);
                                    }
                                  },
                                  child: const Text('Set'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('End: ${endTime.format(context)}', style: const TextStyle(fontSize: 12)),
                                TextButton(
                                  onPressed: () async {
                                    final time = await showTimePicker(
                                      context: context,
                                      initialTime: endTime,
                                    );
                                    if (time != null) {
                                      setState(() => endTime = time);
                                    }
                                  },
                                  child: const Text('Set'),
                                ),
                              ],
                            ),
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
                      final newEvent = CalendarEvent(
                        id: const Uuid().v4(),
                        title: titleController.text,
                        description: descController.text,
                        date: eventDate,
                        startTime: startTime,
                        endTime: endTime,
                        color: selectedColor,
                        category: category,
                      );
                      ref.read(calendarEventsProvider.notifier).addEvent(newEvent);
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

  // --- MATH & DATE HELPERS ---

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  DateTime _getDateForGridIndex(int index) {
    // Determine the calendar grid days for a 6-row layout
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final daysInPrevMonth = DateTime(_currentMonth.year, _currentMonth.month, 0).day;
    int startingOffset = firstDayOfMonth.weekday - 1; // 0 for Monday

    if (index < startingOffset) {
      // Previous month padding days
      return DateTime(
        _currentMonth.year,
        _currentMonth.month - 1,
        daysInPrevMonth - startingOffset + index + 1,
      );
    } else {
      final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
      final currentMonthDay = index - startingOffset + 1;
      if (currentMonthDay <= daysInMonth) {
        // Current month days
        return DateTime(_currentMonth.year, _currentMonth.month, currentMonthDay);
      } else {
        // Next month padding days
        return DateTime(_currentMonth.year, _currentMonth.month + 1, currentMonthDay - daysInMonth);
      }
    }
  }
}
