import '../../../../mock/notes_mock.dart';
import '../../domain/repositories/note_repository.dart';
import '../../presentation/providers/notes_providers.dart';

class FakeNoteRepository implements NoteRepository {
  final List<NoteModel> _notes = List.from(
    mockNotesJson.map((json) => NoteModel.fromJson(json)),
  );

  @override
  Future<List<NoteModel>> getNotes() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_notes);
  }

  @override
  Future<NoteModel> createNote(NoteModel note) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _notes.insert(0, note);
    return note;
  }

  @override
  Future<NoteModel> updateNote(NoteModel note) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note;
    }
    return note;
  }

  @override
  Future<void> deleteNote(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _notes.removeWhere((n) => n.id == id);
  }
}
