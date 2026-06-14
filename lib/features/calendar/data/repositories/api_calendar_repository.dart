import '../../../../core/network/api_client.dart';
import '../../domain/repositories/calendar_repository.dart';
import '../../data/models/calendar_event.dart';

class ApiCalendarRepository implements CalendarRepository {
  final ApiClient _apiClient;

  ApiCalendarRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  @override
  Future<List<CalendarEvent>> getEvents() async {
    final data = await _apiClient.get('/calendar');
    final events = data['events'] as List<dynamic>;
    return events
        .map((json) => CalendarEvent.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<CalendarEvent> createEvent(CalendarEvent event) async {
    final data = await _apiClient.post('/calendar', _toApiJson(event));
    return CalendarEvent.fromJson(data['event'] as Map<String, dynamic>);
  }

  @override
  Future<CalendarEvent> updateEvent(CalendarEvent event) async {
    final data = await _apiClient.patch('/calendar/${event.id}', _toApiJson(event));
    return CalendarEvent.fromJson(data['event'] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteEvent(String id) async {
    await _apiClient.delete('/calendar/$id');
  }

  Map<String, dynamic> _toApiJson(CalendarEvent event) {
    final dateStr = event.date.toIso8601String().split('T').first;
    final startStr = '${event.startTime.hour.toString().padLeft(2, '0')}:${event.startTime.minute.toString().padLeft(2, '0')}';
    final endStr = '${event.endTime.hour.toString().padLeft(2, '0')}:${event.endTime.minute.toString().padLeft(2, '0')}';
    final colorHex = '#${event.color.value.toRadixString(16).padLeft(8, '0')}';

    return {
      'title': event.title,
      'description': event.description,
      'date': dateStr,
      'startTime': startStr,
      'endTime': endStr,
      'colorHex': colorHex,
      'category': event.category,
    };
  }
}
