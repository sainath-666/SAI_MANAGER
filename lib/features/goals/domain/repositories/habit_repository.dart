import '../../data/models/habit_model.dart';

abstract class HabitRepository {
  Future<List<HabitModel>> getHabits();
  Future<HabitModel> createHabit(HabitModel habit);
  Future<HabitModel> updateHabit(HabitModel habit);
  Future<void> deleteHabit(String id);
}
