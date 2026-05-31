class ProjectModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final double progress;
  final String status;
  final int tasksCount;
  final int completedTasksCount;
  final DateTime dueDate;

  ProjectModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.progress,
    required this.status,
    required this.tasksCount,
    required this.completedTasksCount,
    required this.dueDate,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    final dueDateValue = json['dueDate'] ?? json['due_date'];
    final tasksCountValue = json['tasksCount'] ?? json['tasks_count'] ?? 0;
    final completedTasksCountValue =
        json['completedTasksCount'] ?? json['completed_tasks_count'] ?? 0;
    final progressValue = json['progress'] != null
        ? (json['progress'] as num).toDouble()
        : (tasksCountValue > 0
              ? completedTasksCountValue / tasksCountValue
              : 0.0);

    return ProjectModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      progress: progressValue,
      status: json['status'] as String,
      tasksCount: (tasksCountValue as num).toInt(),
      completedTasksCount: (completedTasksCountValue as num).toInt(),
      dueDate: dueDateValue != null
          ? DateTime.parse(dueDateValue as String)
          : DateTime.now().add(const Duration(days: 7)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'progress': progress,
      'status': status,
      'tasksCount': tasksCount,
      'completedTasksCount': completedTasksCount,
      'dueDate': dueDate.toIso8601String(),
    };
  }

  ProjectModel copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    double? progress,
    String? status,
    int? tasksCount,
    int? completedTasksCount,
    DateTime? dueDate,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      tasksCount: tasksCount ?? this.tasksCount,
      completedTasksCount: completedTasksCount ?? this.completedTasksCount,
      dueDate: dueDate ?? this.dueDate,
    );
  }
}
