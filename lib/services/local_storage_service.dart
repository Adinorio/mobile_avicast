import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_avicast/models/user.dart';
import 'package:mobile_avicast/providers/sync_provider.dart';

class LocalStorageService {
  static const String _userKey = 'stored_user';
  static const String _authTokenKey = 'auth_token';
  static const String _lastSyncKey = 'last_sync_time';
  static const String _syncQueueKey = 'sync_queue';
  static const String _pendingUploadsKey = 'pending_uploads';
  static const String _pendingDownloadsKey = 'pending_downloads';

  // User Management
  Future<void> storeUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<User?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      try {
        return User.fromJson(jsonDecode(userJson));
      } catch (e) {
        // If user data is corrupted, remove it
        await prefs.remove(_userKey);
        return null;
      }
    }
    return null;
  }

  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_authTokenKey);
  }

  // Authentication Token
  Future<void> storeAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenKey, token);
  }

  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey);
  }

  // Sync Management
  Future<void> setLastSyncTime(String timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSyncKey, timestamp);
  }

  Future<String?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastSyncKey);
  }

  // Sync Queue Management
  Future<void> addToSyncQueue(SyncItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final queue = await getSyncQueue();
    queue.add(item);
    await _saveSyncQueue(queue);
  }

  Future<void> removeFromSyncQueue(String itemId) async {
    final prefs = await SharedPreferences.getInstance();
    final queue = await getSyncQueue();
    queue.removeWhere((item) => item.id == itemId);
    await _saveSyncQueue(queue);
  }

  Future<List<SyncItem>> getSyncQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final queueJson = prefs.getStringList(_syncQueueKey) ?? [];
    return queueJson.map((itemJson) {
      try {
        return SyncItem.fromJson(jsonDecode(itemJson));
      } catch (e) {
        return null;
      }
    }).whereType<SyncItem>().toList();
  }

  Future<void> _saveSyncQueue(List<SyncItem> queue) async {
    final prefs = await SharedPreferences.getInstance();
    final queueJson = queue.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList(_syncQueueKey, queueJson);
  }

  Future<void> clearSyncQueue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_syncQueueKey);
  }

  // Pending Items Count
  Future<void> setPendingUploadCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_pendingUploadsKey, count);
  }

  Future<int> getPendingUploadCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_pendingUploadsKey) ?? 0;
  }

  Future<void> setPendingDownloadCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_pendingDownloadsKey, count);
  }

  Future<int> getPendingDownloadCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_pendingDownloadsKey) ?? 0;
  }

  // Generic Data Storage
  Future<void> storeData(String key, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(data));
  }

  Future<Map<String, dynamic>?> getData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final dataJson = prefs.getString(key);
    if (dataJson != null) {
      try {
        return jsonDecode(dataJson);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<void> removeData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  // Clear All Data
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
} 