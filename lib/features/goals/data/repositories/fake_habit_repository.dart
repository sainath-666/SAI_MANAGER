import '../../domain/repositories/habit_repository.dart';
import '../../data/models/habit_model.dart';

class FakeHabitRepository implements HabitRepository {
  final List<HabitModel> _habits = [
    HabitModel(id: 'h-1', title: '30-Minute Gym Conditioning', streak: 12, done: true),
    HabitModel(id: 'h-2', title: 'Drink 3L Water', streak: 8, done: false),
    HabitModel(id: 'h-3', title: 'Write Code/API Review', streak: 25, done: true),
    HabitModel(id: 'h-4', title: 'Read Technical Article', streak: 3, done: false),
  ];

  @override
  Future<List<HabitModel>> getHabits() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_habits);
  }

  @override
  Future<HabitModel> createHabit(HabitModel habit) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _habits.add(habit);
    return habit;
  }

  @override
  Future<HabitModel> updateHabit(HabitModel habit) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _habits.indexWhere((h) => h.id == habit.id);
    if (index != -1) {
      _habits[index] = habit;
    }
    return habit;
  }

  @override
  Future<void> deleteHabit(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _habits.removeWhere((h) => h.id == id);
  }
}
