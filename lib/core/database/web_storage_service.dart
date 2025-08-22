import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WebStorageService {
  static final WebStorageService _instance = WebStorageService._internal();
  static WebStorageService get instance => _instance;
  
  WebStorageService._internal();

  // Check if running on web
  bool get isWeb => kIsWeb;

  // Generic storage methods
  Future<void> setString(String key, String value) async {
    if (isWeb) {
      // For web, use localStorage
      // Note: This is a simplified approach. In production, you might want to use IndexedDB
      // For now, we'll use SharedPreferences which works on web
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    }
  }

  Future<String?> getString(String key) async {
    if (isWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    }
    return null;
  }

  Future<void> setStringList(String key, List<String> value) async {
    if (isWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(key, value);
    }
  }

  Future<List<String>> getStringList(String key) async {
    if (isWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(key) ?? [];
    }
    return [];
  }

  Future<void> remove(String key) async {
    if (isWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    }
  }

  Future<void> clear() async {
    if (isWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    }
  }

  // Sites storage
  Future<void> saveSites(List<Map<String, dynamic>> sites) async {
    final sitesJson = sites.map((site) => jsonEncode(site)).toList();
    await setStringList('web_sites', sitesJson);
  }

  Future<List<Map<String, dynamic>>> getSites() async {
    final sitesJson = await getStringList('web_sites');
    return sitesJson
        .map((json) => jsonDecode(json) as Map<String, dynamic>)
        .toList();
  }

  // Bird counts storage
  Future<void> saveBirdCounts(List<Map<String, dynamic>> birdCounts) async {
    final countsJson = birdCounts.map((count) => jsonEncode(count)).toList();
    await setStringList('web_bird_counts', countsJson);
  }

  Future<List<Map<String, dynamic>>> getBirdCounts() async {
    final countsJson = await getStringList('web_bird_counts');
    return countsJson
        .map((json) => jsonDecode(json) as Map<String, dynamic>)
        .toList();
  }

  // Notes storage
  Future<void> saveNotes(List<Map<String, dynamic>> notes) async {
    final notesJson = notes.map((note) => jsonEncode(note)).toList();
    await setStringList('web_notes', notesJson);
  }

  Future<List<Map<String, dynamic>>> getNotes() async {
    final notesJson = await getStringList('web_notes');
    return notesJson
        .map((json) => jsonDecode(json) as Map<String, dynamic>)
        .toList();
  }

  // Photos storage
  Future<void> savePhotos(List<Map<String, dynamic>> photos) async {
    final photosJson = photos.map((photo) => jsonEncode(photo)).toList();
    await setStringList('web_photos', photosJson);
  }

  Future<List<Map<String, dynamic>>> getPhotos() async {
    final photosJson = await getStringList('web_photos');
    return photosJson
        .map((json) => jsonDecode(json) as Map<String, dynamic>)
        .toList();
  }
} 