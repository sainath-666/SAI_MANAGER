import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/project_model.dart';
import '../../data/repositories/api_project_repository.dart';
import '../../data/repositories/fake_project_repository.dart';
import '../../domain/repositories/project_repository.dart';

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  final isAuth = ref.watch(isAuthenticatedProvider);
  if (isAuth) {
    return ApiProjectRepository();
  }
  return FakeProjectRepository();
});

class ProjectsNotifier extends AsyncNotifier<List<ProjectModel>> {
  @override
  Future<List<ProjectModel>> build() {
    return ref.watch(projectRepositoryProvider).getProjects();
  }

  Future<void> addProject(ProjectModel project) async {
    state = await AsyncValue.guard(() async {
      await ref.read(projectRepositoryProvider).createProject(project);
      return ref.read(projectRepositoryProvider).getProjects();
    });
  }

  Future<void> updateProject(ProjectModel project) async {
    state = await AsyncValue.guard(() async {
      await ref.read(projectRepositoryProvider).updateProject(project);
      return ref.read(projectRepositoryProvider).getProjects();
    });
  }

  Future<void> deleteProject(String id) async {
    state = await AsyncValue.guard(() async {
      await ref.read(projectRepositoryProvider).deleteProject(id);
      return ref.read(projectRepositoryProvider).getProjects();
    });
  }
}

final projectsListProvider = AsyncNotifierProvider<ProjectsNotifier, List<ProjectModel>>(
  ProjectsNotifier.new,
);
