import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/models/habit_model.dart';
import '../../data/repositories/api_habit_repository.dart';
import '../../data/repositories/fake_habit_repository.dart';
import '../../domain/repositories/habit_repository.dart';

final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  if (ApiClient.isConfigured) {
    return ApiHabitRepository();
  }
  return FakeHabitRepository();
});

class HabitsNotifier extends AsyncNotifier<List<HabitModel>> {
  @override
  Future<List<HabitModel>> build() {
    return ref.watch(habitRepositoryProvider).getHabits();
  }

  Future<void> addHabit(HabitModel habit) async {
    state = await AsyncValue.guard(() async {
      await ref.read(habitRepositoryProvider).createHabit(habit);
      return ref.read(habitRepositoryProvider).getHabits();
    });
  }

  Future<void> toggleHabitCompletion(HabitModel habit) async {
    state = await AsyncValue.guard(() async {
      final done = !habit.done;
      final newStreak = done ? habit.streak + 1 : (habit.streak - 1).clamp(0, 999999);
      final updated = habit.copyWith(done: done, streak: newStreak);
      await ref.read(habitRepositoryProvider).updateHabit(updated);
      return ref.read(habitRepositoryProvider).getHabits();
    });
  }

  Future<void> deleteHabit(String id) async {
    state = await AsyncValue.guard(() async {
      await ref.read(habitRepositoryProvider).deleteHabit(id);
      return ref.read(habitRepositoryProvider).getHabits();
    });
  }
}

final habitsListProvider = AsyncNotifierProvider<HabitsNotifier, List<HabitModel>>(
  HabitsNotifier.new,
);
