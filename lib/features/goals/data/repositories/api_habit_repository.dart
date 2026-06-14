import '../../../../core/network/api_client.dart';
import '../../domain/repositories/habit_repository.dart';
import '../../data/models/habit_model.dart';

class ApiHabitRepository implements HabitRepository {
  final ApiClient _apiClient;

  ApiHabitRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  @override
  Future<List<HabitModel>> getHabits() async {
    final data = await _apiClient.get('/habits');
    final habits = data['habits'] as List<dynamic>;
    return habits
        .map((json) => HabitModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<HabitModel> createHabit(HabitModel habit) async {
    final data = await _apiClient.post('/habits', _toApiJson(habit));
    return HabitModel.fromJson(data['habit'] as Map<String, dynamic>);
  }

  @override
  Future<HabitModel> updateHabit(HabitModel habit) async {
    final data = await _apiClient.patch('/habits/${habit.id}', _toApiJson(habit));
    return HabitModel.fromJson(data['habit'] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteHabit(String id) async {
    await _apiClient.delete('/habits/$id');
  }

  Map<String, dynamic> _toApiJson(HabitModel habit) {
    return {
      'title': habit.title,
      'streak': habit.streak,
      'isCompleted': habit.done,
    };
  }
}
