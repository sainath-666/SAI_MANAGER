import '../../../../core/network/api_client.dart';
import '../../domain/repositories/note_repository.dart';
import '../../presentation/providers/notes_providers.dart';

class ApiNoteRepository implements NoteRepository {
  final ApiClient _apiClient;

  ApiNoteRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  @override
  Future<List<NoteModel>> getNotes() async {
    final data = await _apiClient.get('/notes');
    final notes = data['notes'] as List<dynamic>;
    return notes
        .map((json) => NoteModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<NoteModel> createNote(NoteModel note) async {
    final data = await _apiClient.post('/notes', _toApiJson(note));
    return NoteModel.fromJson(data['note'] as Map<String, dynamic>);
  }

  @override
  Future<NoteModel> updateNote(NoteModel note) async {
    final data = await _apiClient.patch('/notes/${note.id}', _toApiJson(note));
    return NoteModel.fromJson(data['note'] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteNote(String id) async {
    await _apiClient.delete('/notes/$id');
  }

  Map<String, dynamic> _toApiJson(NoteModel note) {
    return {
      'title': note.title,
      'content': note.content,
      'category': note.category,
      'isPinned': note.isPinned,
    };
  }
}
