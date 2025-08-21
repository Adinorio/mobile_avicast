import '../../domain/entities/note.dart';
import '../services/notes_local_storage_service.dart';

class NotesRepositoryImpl {
  final NotesLocalStorageService _localStorageService;
  
  NotesRepositoryImpl(this._localStorageService);
  
  // Get all notes
  Future<List<Note>> getAllNotes() async {
    return await _localStorageService.getAllNotes();
  }
  
  // Get notes by site
  Future<List<Note>> getNotesBySite(String siteId) async {
    return await _localStorageService.getNotesBySite(siteId);
  }
  
  // Search notes
  Future<List<Note>> searchNotes(String query) async {
    return await _localStorageService.searchNotes(query);
  }
  
  // Save note
  Future<bool> saveNote(Note note) async {
    return await _localStorageService.saveNote(note);
  }
  
  // Delete note
  Future<bool> deleteNote(String noteId) async {
    return await _localStorageService.deleteNote(noteId);
  }
  
  // Create new note
  Future<bool> createNote({
    required String title,
    required String content,
    List<String> tags = const [],
    String? siteId,
  }) async {
    final note = Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      tags: tags,
      isSynced: false,
      siteId: siteId,
    );
    
    return await _localStorageService.saveNote(note);
  }
  
  // Update existing note
  Future<bool> updateNote(Note note) async {
    final updatedNote = note.copyWith(
      updatedAt: DateTime.now(),
      isSynced: false,
    );
    
    return await _localStorageService.saveNote(updatedNote);
  }
  
  // Get unsynced notes for future sync
  Future<List<Note>> getUnsyncedNotes() async {
    return await _localStorageService.getUnsyncedNotes();
  }
  
  // Mark note as synced (for future API integration)
  Future<bool> markNoteAsSynced(String noteId) async {
    return await _localStorageService.markNoteAsSynced(noteId);
  }
} 