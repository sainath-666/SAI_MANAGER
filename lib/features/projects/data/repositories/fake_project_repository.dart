import '../../../../mock/projects_mock.dart';
import '../../domain/repositories/project_repository.dart';
import '../models/project_model.dart';

class FakeProjectRepository implements ProjectRepository {
  final List<ProjectModel> _projects = List.from(
    mockProjectsJson.map((json) => ProjectModel.fromJson(json)),
  );

  @override
  Future<List<ProjectModel>> getProjects() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.from(_projects);
  }

  @override
  Future<ProjectModel> createProject(ProjectModel project) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _projects.insert(0, project);
    return project;
  }

  @override
  Future<void> updateProject(ProjectModel project) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _projects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      _projects[index] = project;
    }
  }

  @override
  Future<void> deleteProject(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _projects.removeWhere((p) => p.id == id);
  }
}
