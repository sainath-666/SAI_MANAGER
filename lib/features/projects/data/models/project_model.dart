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
    return ProjectModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      progress: (json['progress'] as num).toDouble(),
      status: json['status'] as String,
      tasksCount: json['tasksCount'] as int,
      completedTasksCount: json['completedTasksCount'] as int,
      dueDate: DateTime.parse(json['dueDate'] as String),
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
