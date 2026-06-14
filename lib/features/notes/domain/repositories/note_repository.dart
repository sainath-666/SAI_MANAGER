import '../../presentation/providers/notes_providers.dart';

abstract class NoteRepository {
  Future<List<NoteModel>> getNotes();
  Future<NoteModel> createNote(NoteModel note);
  Future<NoteModel> updateNote(NoteModel note);
  Future<void> deleteNote(String id);
}
