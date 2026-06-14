class HabitModel {
  final String id;
  final String title;
  final int streak;
  final bool done;

  HabitModel({
    required this.id,
    required this.title,
    required this.streak,
    required this.done,
  });

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    return HabitModel(
      id: json['id'] as String,
      title: json['title'] as String,
      streak: json['streak'] as int? ?? 0,
      done: json['done'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'streak': streak,
      'done': done,
    };
  }

  HabitModel copyWith({
    String? id,
    String? title,
    int? streak,
    bool? done,
  }) {
    return HabitModel(
      id: id ?? this.id,
      title: title ?? this.title,
      streak: streak ?? this.streak,
      done: done ?? this.done,
    );
  }
}
