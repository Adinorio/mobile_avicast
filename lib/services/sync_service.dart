import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_avicast/services/local_storage_service.dart';
import 'package:mobile_avicast/providers/sync_provider.dart';

class SyncService {
  static const Duration _timeout = Duration(seconds: 30);
  final LocalStorageService _localStorage = LocalStorageService();

  /// Download new data from the server
  Future<int> downloadNewData() async {
    try {
      final serverUrl = await _getServerUrl();
      if (serverUrl == null) return 0;

      int totalDownloaded = 0;

      // Download users data
      totalDownloaded += await _downloadUsers(serverUrl);
      
      // Download locations data
      totalDownloaded += await _downloadLocations(serverUrl);
      
      // Download fauna data
      totalDownloaded += await _downloadFauna(serverUrl);
      
      // Download analytics data
      totalDownloaded += await _downloadAnalytics(serverUrl);

      return totalDownloaded;
    } catch (e) {
      print('Download error: $e');
      return 0;
    }
  }

  /// Upload pending data to the server
  Future<int> uploadPendingData() async {
    try {
      final serverUrl = await _getServerUrl();
      if (serverUrl == null) return 0;

      final syncQueue = await _localStorage.getSyncQueue();
      int totalUploaded = 0;

      for (final item in syncQueue) {
        try {
          final success = await _uploadSyncItem(serverUrl, item);
          if (success) {
            await _localStorage.removeFromSyncQueue(item.id);
            totalUploaded++;
          }
        } catch (e) {
          print('Failed to upload item ${item.id}: $e');
        }
      }

      return totalUploaded;
    } catch (e) {
      print('Upload error: $e');
      return 0;
    }
  }

  /// Download users data
  Future<int> _downloadUsers(String serverUrl) async {
    try {
      final url = Uri.parse('$serverUrl/api/users/');
      final token = await _localStorage.getAuthToken();
      
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Token $token',
          'Accept': 'application/json',
        },
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final users = data['results'] ?? data;
        
        for (final userData in users) {
          await _localStorage.storeData('user_${userData['employee_id']}', userData);
        }
        
        return users.length;
      }
      
      return 0;
    } catch (e) {
      print('Download users error: $e');
      return 0;
    }
  }

  /// Download locations data
  Future<int> _downloadLocations(String serverUrl) async {
    try {
      final url = Uri.parse('$serverUrl/api/locations/');
      final token = await _localStorage.getAuthToken();
      
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Token $token',
          'Accept': 'application/json',
        },
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final locations = data['results'] ?? data;
        
        for (final locationData in locations) {
          await _localStorage.storeData('location_${locationData['id']}', locationData);
        }
        
        return locations.length;
      }
      
      return 0;
    } catch (e) {
      print('Download locations error: $e');
      return 0;
    }
  }

  /// Download fauna data
  Future<int> _downloadFauna(String serverUrl) async {
    try {
      final url = Uri.parse('$serverUrl/api/fauna/');
      final token = await _localStorage.getAuthToken();
      
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Token $token',
          'Accept': 'application/json',
        },
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final fauna = data['results'] ?? data;
        
        for (final faunaData in fauna) {
          await _localStorage.storeData('fauna_${faunaData['id']}', faunaData);
        }
        
        return fauna.length;
      }
      
      return 0;
    } catch (e) {
      print('Download fauna error: $e');
      return 0;
    }
  }

  /// Download analytics data
  Future<int> _downloadAnalytics(String serverUrl) async {
    try {
      final url = Uri.parse('$serverUrl/api/analytics/');
      final token = await _localStorage.getAuthToken();
      
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Token $token',
          'Accept': 'application/json',
        },
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final analytics = data['results'] ?? data;
        
        for (final analyticsData in analytics) {
          await _localStorage.storeData('analytics_${analyticsData['id']}', analyticsData);
        }
        
        return analytics.length;
      }
      
      return 0;
    } catch (e) {
      print('Download analytics error: $e');
      return 0;
    }
  }

  /// Upload a single sync item
  Future<bool> _uploadSyncItem(String serverUrl, SyncItem item) async {
    try {
      final token = await _localStorage.getAuthToken();
      final url = Uri.parse('$serverUrl/api/sync/');
      
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'type': item.type,
          'action': item.action.toString(),
          'data': item.data,
          'timestamp': item.timestamp.toIso8601String(),
        }),
      ).timeout(_timeout);

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Upload sync item error: $e');
      return false;
    }
  }

  /// Get the server URL from storage
  Future<String?> _getServerUrl() async {
    final data = await _localStorage.getData('server_url');
    return data?['url'];
  }

  /// Set the server URL
  Future<void> setServerUrl(String url) async {
    await _localStorage.storeData('server_url', {'url': url});
  }

  /// Check if server is reachable
  Future<bool> isServerReachable() async {
    try {
      final serverUrl = await _getServerUrl();
      if (serverUrl == null) return false;

      final url = Uri.parse('$serverUrl/api/health/');
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Get sync statistics
  Future<Map<String, dynamic>> getSyncStats() async {
    try {
      final serverUrl = await _getServerUrl();
      if (serverUrl == null) return {};

      final url = Uri.parse('$serverUrl/api/sync/stats/');
      final token = await _localStorage.getAuthToken();
      
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Token $token',
          'Accept': 'application/json',
        },
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      
      return {};
    } catch (e) {
      print('Get sync stats error: $e');
      return {};
    }
  }

  /// Force sync all data
  Future<bool> forceSync() async {
    try {
      // First download all data
      final downloadCount = await downloadNewData();
      
      // Then upload all pending data
      final uploadCount = await uploadPendingData();
      
      // Update sync timestamp
      await _localStorage.setLastSyncTime(DateTime.now().toIso8601String());
      
      print('Force sync completed: $downloadCount downloaded, $uploadCount uploaded');
      return true;
    } catch (e) {
      print('Force sync error: $e');
      return false;
    }
  }

  /// Clear all local data
  Future<void> clearLocalData() async {
    try {
      // Clear all stored data except user and sync queue
      final keys = [
        'location_',
        'fauna_',
        'analytics_',
        'server_url',
      ];
      
      for (final key in keys) {
        await _localStorage.removeData(key);
      }
      
      print('Local data cleared');
    } catch (e) {
      print('Clear local data error: $e');
    }
  }
} 