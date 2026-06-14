import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/calendar_event.dart';
import '../../data/repositories/api_calendar_repository.dart';
import '../../data/repositories/fake_calendar_repository.dart';
import '../../domain/repositories/calendar_repository.dart';

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

final calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
  final isAuth = ref.watch(isAuthenticatedProvider);
  if (isAuth) {
    return ApiCalendarRepository();
  }
  return FakeCalendarRepository();
});

class CalendarEventsNotifier extends AsyncNotifier<List<CalendarEvent>> {
  @override
  Future<List<CalendarEvent>> build() {
    return ref.watch(calendarRepositoryProvider).getEvents();
  }

  Future<void> addEvent(CalendarEvent event) async {
    state = await AsyncValue.guard(() async {
      await ref.read(calendarRepositoryProvider).createEvent(event);
      return ref.read(calendarRepositoryProvider).getEvents();
    });
  }

  Future<void> deleteEvent(String id) async {
    state = await AsyncValue.guard(() async {
      await ref.read(calendarRepositoryProvider).deleteEvent(id);
      return ref.read(calendarRepositoryProvider).getEvents();
    });
  }
}

final calendarEventsProvider = AsyncNotifierProvider<CalendarEventsNotifier, List<CalendarEvent>>(
  CalendarEventsNotifier.new,
);
