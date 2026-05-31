import '../../../../mock/tasks_mock.dart';
import '../../domain/repositories/task_repository.dart';
import '../models/task_model.dart';

class FakeTaskRepository implements TaskRepository {
  final List<TaskModel> _tasks = List.from(
    mockTasksJson.map((json) => TaskModel.fromJson(json)),
  );

  @override
  Future<List<TaskModel>> getTasks() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.from(_tasks);
  }

  @override
  Future<TaskModel> createTask(TaskModel task) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _tasks.insert(0, task);
    return task;
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _tasks.removeWhere((t) => t.id == id);
  }
}
