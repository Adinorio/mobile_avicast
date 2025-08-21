import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/note.dart';

class NotesLocalStorageService {
  static const String _notesKey = 'avicast_notes';
  
  // Get all notes from local storage
  Future<List<Note>> getAllNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notesJson = prefs.getStringList(_notesKey) ?? [];
      
      return notesJson
          .map((noteString) => Note.fromJson(jsonDecode(noteString)))
          .toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt)); // Sort by most recent
    } catch (e) {
      print('Error loading notes: $e');
      return [];
    }
  }
  
  // Save a note to local storage
  Future<bool> saveNote(Note note) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notes = await getAllNotes();
      
      // Update existing note or add new one
      final existingIndex = notes.indexWhere((n) => n.id == note.id);
      if (existingIndex >= 0) {
        notes[existingIndex] = note;
      } else {
        notes.add(note);
      }
      
      // Convert to JSON strings
      final notesJson = notes.map((n) => jsonEncode(n.toJson())).toList();
      
      return await prefs.setStringList(_notesKey, notesJson);
    } catch (e) {
      print('Error saving note: $e');
      return false;
    }
  }
  
  // Delete a note from local storage
  Future<bool> deleteNote(String noteId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notes = await getAllNotes();
      
      notes.removeWhere((note) => note.id == noteId);
      
      final notesJson = notes.map((n) => jsonEncode(n.toJson())).toList();
      return await prefs.setStringList(_notesKey, notesJson);
    } catch (e) {
      print('Error deleting note: $e');
      return false;
    }
  }
  
  // Get notes by site ID
  Future<List<Note>> getNotesBySite(String siteId) async {
    final allNotes = await getAllNotes();
    return allNotes.where((note) => note.siteId == siteId).toList();
  }
  
  // Search notes by title or content
  Future<List<Note>> searchNotes(String query) async {
    final allNotes = await getAllNotes();
    final lowercaseQuery = query.toLowerCase();
    
    return allNotes.where((note) =>
      note.title.toLowerCase().contains(lowercaseQuery) ||
      note.content.toLowerCase().contains(lowercaseQuery) ||
      note.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery))
    ).toList();
  }
  
  // Get unsynced notes for sync
  Future<List<Note>> getUnsyncedNotes() async {
    final allNotes = await getAllNotes();
    return allNotes.where((note) => !note.isSynced).toList();
  }
  
  // Mark note as synced
  Future<bool> markNoteAsSynced(String noteId) async {
    try {
      final notes = await getAllNotes();
      final noteIndex = notes.indexWhere((note) => note.id == noteId);
      
      if (noteIndex >= 0) {
        notes[noteIndex] = notes[noteIndex].copyWith(isSynced: true);
        final notesJson = notes.map((n) => jsonEncode(n.toJson())).toList();
        
        final prefs = await SharedPreferences.getInstance();
        return await prefs.setStringList(_notesKey, notesJson);
      }
      return false;
    } catch (e) {
      print('Error marking note as synced: $e');
      return false;
    }
  }
} 