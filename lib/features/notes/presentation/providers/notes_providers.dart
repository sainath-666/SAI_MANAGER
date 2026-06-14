import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/repositories/api_note_repository.dart';
import '../../data/repositories/fake_note_repository.dart';
import '../../domain/repositories/note_repository.dart';

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

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  if (ApiClient.isConfigured) {
    return ApiNoteRepository();
  }
  return FakeNoteRepository();
});

class NotesNotifier extends AsyncNotifier<List<NoteModel>> {
  @override
  Future<List<NoteModel>> build() {
    return ref.watch(noteRepositoryProvider).getNotes();
  }

  Future<void> addNote(NoteModel note) async {
    state = await AsyncValue.guard(() async {
      await ref.read(noteRepositoryProvider).createNote(note);
      return ref.read(noteRepositoryProvider).getNotes();
    });
  }

  Future<void> togglePin(String id) async {
    state = await AsyncValue.guard(() async {
      final notes = state.value ?? [];
      final note = notes.firstWhere((n) => n.id == id);
      final updated = note.copyWith(isPinned: !note.isPinned);
      await ref.read(noteRepositoryProvider).updateNote(updated);
      return ref.read(noteRepositoryProvider).getNotes();
    });
  }

  Future<void> deleteNote(String id) async {
    state = await AsyncValue.guard(() async {
      await ref.read(noteRepositoryProvider).deleteNote(id);
      return ref.read(noteRepositoryProvider).getNotes();
    });
  }
}

final notesListProvider = AsyncNotifierProvider<NotesNotifier, List<NoteModel>>(
  NotesNotifier.new,
);
