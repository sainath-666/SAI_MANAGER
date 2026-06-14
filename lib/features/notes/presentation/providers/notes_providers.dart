import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../mock/notes_mock.dart';

class NoteModel {
  final String id;
  final String title;
  final String content;
  final DateTime updatedAt;
  final String category;
  final bool isPinned;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.updatedAt,
    required this.category,
    required this.isPinned,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      category: json['category'] as String,
      isPinned: json['isPinned'] as bool? ?? false,
    );
  }

  NoteModel copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? updatedAt,
    String? category,
    bool? isPinned,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      updatedAt: updatedAt ?? this.updatedAt,
      category: category ?? this.category,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}

class NotesNotifier extends StateNotifier<List<NoteModel>> {
  NotesNotifier() : super([]) {
    _loadMockNotes();
  }

  void _loadMockNotes() {
    state = mockNotesJson.map((json) => NoteModel.fromJson(json)).toList();
  }

  void addNote(NoteModel note) {
    state = [note, ...state];
  }

  void togglePin(String id) {
    state = state.map((n) {
      if (n.id == id) {
        return n.copyWith(isPinned: !n.isPinned);
      }
      return n;
    }).toList();
  }

  void deleteNote(String id) {
    state = state.where((n) => n.id != id).toList();
  }
}

final notesListProvider = StateNotifierProvider<NotesNotifier, List<NoteModel>>((ref) {
  return NotesNotifier();
});
