import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/api_task_repository.dart';
import '../../data/repositories/fake_task_repository.dart';
import '../../domain/repositories/task_repository.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  if (ApiClient.isConfigured) {
    return ApiTaskRepository();
  }

  return FakeTaskRepository();
});

class TasksNotifier extends AsyncNotifier<List<TaskModel>> {
  @override
  Future<List<TaskModel>> build() {
    return ref.watch(taskRepositoryProvider).getTasks();
  }

  Future<void> addTask(TaskModel task) async {
    state = await AsyncValue.guard(() async {
      await ref.read(taskRepositoryProvider).createTask(task);
      return ref.read(taskRepositoryProvider).getTasks();
    });
  }

  Future<void> toggleTaskCompletion(TaskModel task) async {
    state = await AsyncValue.guard(() async {
      final updated = task.copyWith(isCompleted: !task.isCompleted);
      await ref.read(taskRepositoryProvider).updateTask(updated);
      return ref.read(taskRepositoryProvider).getTasks();
    });
  }

  Future<void> deleteTask(String id) async {
    state = await AsyncValue.guard(() async {
      await ref.read(taskRepositoryProvider).deleteTask(id);
      return ref.read(taskRepositoryProvider).getTasks();
    });
  }
}

final tasksListProvider = AsyncNotifierProvider<TasksNotifier, List<TaskModel>>(
  TasksNotifier.new,
);
