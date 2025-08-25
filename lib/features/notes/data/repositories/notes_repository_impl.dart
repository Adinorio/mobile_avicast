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
  Future<void> saveNote(Note note) async {
    await _localStorageService.saveNote(note);
  }
  
  // Delete note
  Future<void> deleteNote(String noteId) async {
    await _localStorageService.deleteNote(noteId);
  }
  
  // Create new note
  Future<void> createNote({
    required String title,
    required String content,
    required String type,
    List<String> tags = const [],
    String? siteId,
  }) async {
    await _localStorageService.createNote(
      title: title,
      content: content,
      type: type,
      tags: tags,
      siteId: siteId,
    );
  }
  
  // Update existing note
  Future<void> updateNote(Note note) async {
    await _localStorageService.updateNote(note);
  }
  
  // Get unsynced notes for future sync
  Future<List<Note>> getUnsyncedNotes() async {
    return await _localStorageService.getUnsyncedNotes();
  }
  
  // Mark note as synced (for future API integration)
  Future<void> markNoteAsSynced(String noteId) async {
    await _localStorageService.markNoteAsSynced(noteId);
  }
} 