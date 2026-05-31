import '../../data/models/project_model.dart';

abstract class ProjectRepository {
  Future<List<ProjectModel>> getProjects();
  Future<ProjectModel> createProject(ProjectModel project);
  Future<void> updateProject(ProjectModel project);
  Future<void> deleteProject(String id);
}
