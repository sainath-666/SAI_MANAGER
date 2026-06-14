import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../domain/repositories/calendar_repository.dart';
import '../../data/models/calendar_event.dart';

class FakeCalendarRepository implements CalendarRepository {
  late final List<CalendarEvent> _events;

  FakeCalendarRepository() {
    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));
    final yesterday = today.subtract(const Duration(days: 1));

    _events = [
      CalendarEvent(
        id: const Uuid().v4(),
        title: 'Project Kickoff Meeting',
        description: 'Review project specifications, deliverables, and assign tasks to stakeholders.',
        date: today,
        startTime: const TimeOfDay(hour: 10, minute: 0),
        endTime: const TimeOfDay(hour: 11, minute: 30),
        color: const Color(0xFF0B8043),
        category: 'Office Work',
      ),
      CalendarEvent(
        id: const Uuid().v4(),
        title: 'Finance Review & Ledger Sync',
        description: 'Sync income ledger with cashbook API and analyze expenses trends.',
        date: today,
        startTime: const TimeOfDay(hour: 14, minute: 0),
        endTime: const TimeOfDay(hour: 15, minute: 0),
        color: const Color(0xFFD50000),
        category: 'Finance',
      ),
      CalendarEvent(
        id: const Uuid().v4(),
        title: 'Client Demo & Feedback Session',
        description: 'Demonstrate active prototypes of Personal Operating System app to the product owner.',
        date: tomorrow,
        startTime: const TimeOfDay(hour: 11, minute: 0),
        endTime: const TimeOfDay(hour: 12, minute: 0),
        color: const Color(0xFF039BE5),
        category: 'Freelance',
      ),
      CalendarEvent(
        id: const Uuid().v4(),
        title: 'Clean Architecture Study Group',
        description: 'Discuss entity isolation, interfaces, and boundary layers in Flutter.',
        date: yesterday,
        startTime: const TimeOfDay(hour: 17, minute: 0),
        endTime: const TimeOfDay(hour: 18, minute: 30),
        color: const Color(0xFF8E24AA),
        category: 'Learning',
      ),
    ];
  }

  @override
  Future<List<CalendarEvent>> getEvents() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_events);
  }

  @override
  Future<CalendarEvent> createEvent(CalendarEvent event) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _events.add(event);
    return event;
  }

  @override
  Future<CalendarEvent> updateEvent(CalendarEvent event) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _events.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      _events[index] = event;
    }
    return event;
  }

  @override
  Future<void> deleteEvent(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _events.removeWhere((e) => e.id == id);
  }
}
