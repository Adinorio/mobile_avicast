import 'package:flutter/foundation.dart';
import 'package:mobile_avicast/services/sync_service.dart';
import 'package:mobile_avicast/services/local_storage_service.dart';
import 'package:mobile_avicast/models/user.dart';

class SyncProvider extends ChangeNotifier {
  bool _isSyncing = false;
  bool _isUploading = false;
  bool _isDownloading = false;
  int _pendingUploads = 0;
  int _pendingDownloads = 0;
  String? _lastSyncTime;
  String? _error;
  List<SyncItem> _syncQueue = [];

  // Getters
  bool get isSyncing => _isSyncing;
  bool get isUploading => _isUploading;
  bool get isDownloading => _isDownloading;
  int get pendingUploads => _pendingUploads;
  int get pendingDownloads => _pendingDownloads;
  String? get lastSyncTime => _lastSyncTime;
  String? get error => _error;
  List<SyncItem> get syncQueue => _syncQueue;

  final SyncService _syncService = SyncService();
  final LocalStorageService _localStorage = LocalStorageService();

  SyncProvider() {
    _initializeSync();
  }

  Future<void> _initializeSync() async {
    await _loadSyncStatus();
    await _countPendingItems();
  }

  Future<void> _loadSyncStatus() async {
    try {
      _lastSyncTime = await _localStorage.getLastSyncTime();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading sync status: $e');
    }
  }

  Future<void> _countPendingItems() async {
    try {
      _pendingUploads = await _localStorage.getPendingUploadCount();
      _pendingDownloads = await _localStorage.getPendingDownloadCount();
      notifyListeners();
    } catch (e) {
      debugPrint('Error counting pending items: $e');
    }
  }

  Future<void> syncAllData() async {
    if (_isSyncing) return;
    
    _setSyncing(true);
    _clearError();
    
    try {
      // First download any new data from server
      await _downloadNewData();
      
      // Then upload any pending local changes
      await _uploadPendingData();
      
      // Update sync timestamp
      await _localStorage.setLastSyncTime(DateTime.now().toIso8601String());
      _lastSyncTime = DateTime.now().toIso8601String();
      
      // Refresh counts
      await _countPendingItems();
      
    } catch (e) {
      _setError('Sync failed: ${e.toString()}');
    } finally {
      _setSyncing(false);
    }
  }

  Future<void> _downloadNewData() async {
    _setDownloading(true);
    
    try {
      final downloadCount = await _syncService.downloadNewData();
      _pendingDownloads = downloadCount;
      
      if (downloadCount > 0) {
        debugPrint('Downloaded $downloadCount new items');
      }
    } catch (e) {
      debugPrint('Error downloading data: $e');
      rethrow;
    } finally {
      _setDownloading(false);
    }
  }

  Future<void> _uploadPendingData() async {
    _setUploading(true);
    
    try {
      final uploadCount = await _syncService.uploadPendingData();
      _pendingUploads = uploadCount;
      
      if (uploadCount > 0) {
        debugPrint('Uploaded $uploadCount pending items');
      }
    } catch (e) {
      debugPrint('Error uploading data: $e');
      rethrow;
    } finally {
      _setUploading(false);
    }
  }

  Future<void> addToSyncQueue(SyncItem item) async {
    _syncQueue.add(item);
    await _localStorage.addToSyncQueue(item);
    await _countPendingItems();
    notifyListeners();
  }

  Future<void> removeFromSyncQueue(String itemId) async {
    _syncQueue.removeWhere((item) => item.id == itemId);
    await _localStorage.removeFromSyncQueue(itemId);
    await _countPendingItems();
    notifyListeners();
  }

  Future<void> forceUpload() async {
    if (_isUploading) return;
    
    _setUploading(true);
    _clearError();
    
    try {
      await _uploadPendingData();
    } catch (e) {
      _setError('Force upload failed: ${e.toString()}');
    } finally {
      _setUploading(false);
    }
  }

  Future<void> forceDownload() async {
    if (_isDownloading) return;
    
    _setDownloading(true);
    _clearError();
    
    try {
      await _downloadNewData();
    } catch (e) {
      _setError('Force download failed: ${e.toString()}');
    } finally {
      _setDownloading(false);
    }
  }

  Future<void> clearSyncQueue() async {
    try {
      await _localStorage.clearSyncQueue();
      _syncQueue.clear();
      _pendingUploads = 0;
      _pendingDownloads = 0;
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing sync queue: $e');
    }
  }

  Future<void> refreshSyncStatus() async {
    await _loadSyncStatus();
    await _countPendingItems();
  }

  void _setSyncing(bool syncing) {
    _isSyncing = syncing;
    notifyListeners();
  }

  void _setUploading(bool uploading) {
    _isUploading = uploading;
    notifyListeners();
  }

  void _setDownloading(bool downloading) {
    _isDownloading = downloading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}

class SyncItem {
  final String id;
  final String type;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final SyncAction action;

  SyncItem({
    required this.id,
    required this.type,
    required this.data,
    required this.timestamp,
    required this.action,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'action': action.toString(),
    };
  }

  factory SyncItem.fromJson(Map<String, dynamic> json) {
    return SyncItem(
      id: json['id'],
      type: json['type'],
      data: json['data'],
      timestamp: DateTime.parse(json['timestamp']),
      action: SyncAction.values.firstWhere(
        (e) => e.toString() == json['action'],
        orElse: () => SyncAction.create,
      ),
    );
  }
}

enum SyncAction { create, update, delete } 