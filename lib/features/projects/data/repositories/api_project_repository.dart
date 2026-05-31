import '../../../../core/network/api_client.dart';
import '../../domain/repositories/project_repository.dart';
import '../models/project_model.dart';

class ApiProjectRepository implements ProjectRepository {
  final ApiClient _apiClient;

  ApiProjectRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  @override
  Future<List<ProjectModel>> getProjects() async {
    final data = await _apiClient.get('/projects');
    final projects = data['projects'] as List<dynamic>;
    return projects
        .map((json) => ProjectModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ProjectModel> createProject(ProjectModel project) async {
    final data = await _apiClient.post('/projects', _toApiJson(project));
    return ProjectModel.fromJson(data['project'] as Map<String, dynamic>);
  }

  @override
  Future<void> updateProject(ProjectModel project) async {
    await _apiClient.patch('/projects/${project.id}', _toApiJson(project));
  }

  @override
  Future<void> deleteProject(String id) async {
    await _apiClient.delete('/projects/$id');
  }

  Map<String, dynamic> _toApiJson(ProjectModel project) {
    return {
      'name': project.name,
      'description': project.description,
      'category': project.category,
      'status': project.status,
      'tasksCount': project.tasksCount,
      'completedTasksCount': project.completedTasksCount,
      'dueDate': project.dueDate.toIso8601String().split('T').first,
    };
  }
}
