import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/calendar_event.dart';

// List of Google Calendar style preset colors
final calendarColors = [
  const Color(0xFFD50000), // Tomato (Red)
  const Color(0xFFE67C73), // Flamingo (Light Red)
  const Color(0xFFF4511E), // Tangerine (Orange)
  const Color(0xFFF6BF26), // Banana (Yellow)
  const Color(0xFF0B8043), // Basil (Green)
  const Color(0xFF039BE5), // Peacock (Light Blue)
  const Color(0xFF3F51B5), // Blueberry (Blue)
  const Color(0xFF7986CB), // Lavender (Periwinkle)
  const Color(0xFF8E24AA), // Grape (Purple)
  const Color(0xFF616161), // Graphite (Gray)
];

class CalendarEventsNotifier extends StateNotifier<List<CalendarEvent>> {
  CalendarEventsNotifier() : super([]) {
    _loadMockEvents();
  }

  void _loadMockEvents() {
    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));
    final yesterday = today.subtract(const Duration(days: 1));

    state = [
      CalendarEvent(
        id: const Uuid().v4(),
        title: 'Project Kickoff Meeting',
        description: 'Review project specifications, deliverables, and assign tasks to stakeholders.',
        date: today,
        startTime: const TimeOfDay(hour: 10, minute: 0),
        endTime: const TimeOfDay(hour: 11, minute: 30),
        color: const Color(0xFF0B8043), // Basil (Green)
        category: 'Office Work',
      ),
      CalendarEvent(
        id: const Uuid().v4(),
        title: 'Finance Review & Ledger Sync',
        description: 'Sync income ledger with cashbook API and analyze expenses trends.',
        date: today,
        startTime: const TimeOfDay(hour: 14, minute: 0),
        endTime: const TimeOfDay(hour: 15, minute: 0),
        color: const Color(0xFFD50000), // Tomato (Red)
        category: 'Finance',
      ),
      CalendarEvent(
        id: const Uuid().v4(),
        title: 'Client Demo & Feedback Session',
        description: 'Demonstrate active prototypes of Personal Operating System app to the product owner.',
        date: tomorrow,
        startTime: const TimeOfDay(hour: 11, minute: 0),
        endTime: const TimeOfDay(hour: 12, minute: 0),
        color: const Color(0xFF039BE5), // Peacock (Blue)
        category: 'Freelance',
      ),
      CalendarEvent(
        id: const Uuid().v4(),
        title: 'Clean Architecture Study Group',
        description: 'Discuss entity isolation, interfaces, and boundary layers in Flutter.',
        date: yesterday,
        startTime: const TimeOfDay(hour: 17, minute: 0),
        endTime: const TimeOfDay(hour: 18, minute: 30),
        color: const Color(0xFF8E24AA), // Grape (Purple)
        category: 'Learning',
      ),
    ];
  }

  void addEvent(CalendarEvent event) {
    state = [...state, event];
  }

  void deleteEvent(String id) {
    state = state.where((e) => e.id != id).toList();
  }
}

final calendarEventsProvider = StateNotifierProvider<CalendarEventsNotifier, List<CalendarEvent>>((ref) {
  return CalendarEventsNotifier();
});
