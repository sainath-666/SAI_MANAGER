import '../../../../core/network/api_client.dart';
import '../../domain/repositories/task_repository.dart';
import '../models/task_model.dart';

class ApiTaskRepository implements TaskRepository {
  final ApiClient _apiClient;

  ApiTaskRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  @override
  Future<List<TaskModel>> getTasks() async {
    final data = await _apiClient.get('/tasks');
    final tasks = data['tasks'] as List<dynamic>;
    return tasks
        .map((json) => TaskModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<TaskModel> createTask(TaskModel task) async {
    final data = await _apiClient.post('/tasks', _toApiJson(task));
    return TaskModel.fromJson(data['task'] as Map<String, dynamic>);
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    await _apiClient.patch('/tasks/${task.id}', _toApiJson(task));
  }

  @override
  Future<void> deleteTask(String id) async {
    await _apiClient.delete('/tasks/$id');
  }

  Map<String, dynamic> _toApiJson(TaskModel task) {
    return {
      'title': task.title,
      'description': task.description,
      'status': task.isCompleted ? 'done' : 'todo',
      'priority': task.priority.toLowerCase(),
      'category': task.category,
      'dueDate': _dateOnly(task.dueDate),
    };
  }

  String _dateOnly(DateTime date) {
    return date.toIso8601String().split('T').first;
  }
}
