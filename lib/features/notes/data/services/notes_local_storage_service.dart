import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/user_context_service.dart';

class Note {
  final String id;
  final String title;
  final String content;
  final String type;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;
  final bool isSynced;
  final DateTime? syncedAt;
  final String? siteId;
  final String? photoPath;
  final String? audioPath;
  final String? drawingPath;
  final String? filePath;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
    this.isSynced = false,
    this.syncedAt,
    this.siteId,
    this.photoPath,
    this.audioPath,
    this.drawingPath,
    this.filePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'tags': tags,
      'isSynced': isSynced,
      'syncedAt': syncedAt?.toIso8601String(),
      'siteId': siteId,
      'photoPath': photoPath,
      'audioPath': audioPath,
      'drawingPath': drawingPath,
      'filePath': filePath,
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      type: json['type'] ?? 'general',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      tags: List<String>.from(json['tags'] ?? []),
      isSynced: json['isSynced'] ?? false,
      syncedAt: json['syncedAt'] != null ? DateTime.parse(json['syncedAt']) : null,
      siteId: json['siteId'],
      photoPath: json['photoPath'],
      audioPath: json['audioPath'],
      drawingPath: json['drawingPath'],
      filePath: json['filePath'],
    );
  }

  Note copyWith({
    String? id,
    String? title,
    String? content,
    String? type,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    bool? isSynced,
    DateTime? syncedAt,
    String? siteId,
    String? photoPath,
    String? audioPath,
    String? drawingPath,
    String? filePath,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      isSynced: isSynced ?? this.isSynced,
      syncedAt: syncedAt ?? this.syncedAt,
      siteId: siteId ?? this.siteId,
      photoPath: photoPath ?? this.photoPath,
      audioPath: audioPath ?? this.audioPath,
      drawingPath: drawingPath ?? this.drawingPath,
      filePath: filePath ?? this.filePath,
    );
  }
}

class NotesLocalStorageService {
  static const String _notesKey = 'avicast_notes';

  static final NotesLocalStorageService _instance = NotesLocalStorageService._internal();
  factory NotesLocalStorageService() => _instance;
  NotesLocalStorageService._internal();

  static NotesLocalStorageService get instance => _instance;

  Future<String> get _notesKeyForUser async {
    final userId = await UserContextService.instance.getCurrentUserId();
    if (userId == null) throw Exception('No user logged in');
    return '${_notesKey}_$userId';
  }
  
  // Get all notes from local storage for current user
  Future<List<Note>> getAllNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notesKey = await _notesKeyForUser;
      final notesJson = prefs.getStringList(notesKey) ?? [];
      
      return notesJson
          .map((noteString) => Note.fromJson(jsonDecode(noteString)))
          .toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt)); // Sort by most recent
    } catch (e) {
      print('Error loading notes: $e');
      return [];
    }
  }
  
  // Save a note to local storage for current user
  Future<void> saveNote(Note note) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notesKey = await _notesKeyForUser;
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
      
      await prefs.setStringList(notesKey, notesJson);
    } catch (e) {
      print('Error saving note: $e');
      throw Exception('Failed to save note: $e');
    }
  }
  
  // Delete a note from local storage for current user
  Future<void> deleteNote(String noteId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notesKey = await _notesKeyForUser;
      final notes = await getAllNotes();
      
      notes.removeWhere((note) => note.id == noteId);
      
      final notesJson = notes.map((n) => jsonEncode(n.toJson())).toList();
      await prefs.setStringList(notesKey, notesJson);
    } catch (e) {
      print('Error deleting note: $e');
      throw Exception('Failed to delete note: $e');
    }
  }

  // Create a new note for current user
  Future<void> createNote({
    required String title,
    required String content,
    required String type,
    List<String> tags = const [],
    String? siteId,
  }) async {
    final note = Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      type: type,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      tags: tags,
      isSynced: false,
      siteId: siteId,
    );
    await saveNote(note);
  }

  // Update an existing note for current user
  Future<void> updateNote(Note note) async {
    final updatedNote = note.copyWith(
      updatedAt: DateTime.now(),
      isSynced: false,
    );
    await saveNote(updatedNote);
  }
  
  // Get notes by site ID for current user
  Future<List<Note>> getNotesBySite(String siteId) async {
    final allNotes = await getAllNotes();
    return allNotes.where((note) => note.siteId == siteId).toList();
  }
  
  // Search notes by title or content for current user
  Future<List<Note>> searchNotes(String query) async {
    final allNotes = await getAllNotes();
    final lowercaseQuery = query.toLowerCase();
    
    return allNotes.where((note) =>
      note.title.toLowerCase().contains(lowercaseQuery) ||
      note.content.toLowerCase().contains(lowercaseQuery) ||
      note.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery))
    ).toList();
  }
  
  // Get unsynced notes for sync for current user
  Future<List<Note>> getUnsyncedNotes() async {
    final allNotes = await getAllNotes();
    return allNotes.where((note) => !note.isSynced).toList();
  }
  
  // Mark note as synced for current user
  Future<void> markNoteAsSynced(String noteId) async {
    try {
      final notes = await getAllNotes();
      final noteIndex = notes.indexWhere((note) => note.id == noteId);
      
      if (noteIndex >= 0) {
        notes[noteIndex] = notes[noteIndex].copyWith(isSynced: true);
        final notesJson = notes.map((n) => jsonEncode(n.toJson())).toList();
        
        final prefs = await SharedPreferences.getInstance();
        final notesKey = await _notesKeyForUser;
        await prefs.setStringList(notesKey, notesJson);
      }
    } catch (e) {
      print('Error marking note as synced: $e');
      throw Exception('Failed to mark note as synced: $e');
    }
  }

  // Clear all notes for current user
  Future<void> clearUserNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notesKey = await _notesKeyForUser;
      await prefs.remove(notesKey);
    } catch (e) {
      print('Error clearing user notes: $e');
      throw Exception('Failed to clear user notes: $e');
    }
  }
} 