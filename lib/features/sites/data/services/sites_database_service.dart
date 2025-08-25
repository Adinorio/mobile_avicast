import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/user_context_service.dart';

class Site {
  final String id;
  final String name;
  final String? description;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  final List<BirdCount> birdCounts;

  Site({
    required this.id,
    required this.name,
    this.description,
    this.latitude,
    this.longitude,
    required this.createdAt,
    this.birdCounts = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt.toIso8601String(),
      'birdCounts': birdCounts.map((count) => count.toJson()).toList(),
    };
  }

  factory Site.fromJson(Map<String, dynamic> json) {
    return Site(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      createdAt: DateTime.parse(json['createdAt']),
      birdCounts: (json['birdCounts'] as List?)
          ?.map((count) => BirdCount.fromJson(count))
          .toList() ?? [],
    );
  }
}

class BirdCount {
  final String birdName;
  final String birdFamily;
  final String birdScientificName;
  final String birdStatus;
  final int count;
  final DateTime timestamp;
  final String? observerName;

  BirdCount({
    required this.birdName,
    required this.birdFamily,
    required this.birdScientificName,
    required this.birdStatus,
    required this.count,
    required this.timestamp,
    this.observerName,
  });

  Map<String, dynamic> toJson() {
    return {
      'birdName': birdName,
      'birdFamily': birdFamily,
      'birdScientificName': birdScientificName,
      'birdStatus': birdStatus,
      'count': count,
      'timestamp': timestamp.toIso8601String(),
      'observerName': observerName,
    };
  }

  factory BirdCount.fromJson(Map<String, dynamic> json) {
    return BirdCount(
      birdName: json['birdName'],
      birdFamily: json['birdFamily'],
      birdScientificName: json['birdScientificName'],
      birdStatus: json['birdStatus'],
      count: json['count'],
      timestamp: DateTime.parse(json['timestamp']),
      observerName: json['observerName'],
    );
  }
}

class SitesDatabaseService {
  static const String _sitesKey = 'counting_sites';
  static const String _countsKey = 'bird_counts';

  static final SitesDatabaseService _instance = SitesDatabaseService._internal();
  factory SitesDatabaseService() => _instance;
  SitesDatabaseService._internal();

  static SitesDatabaseService get instance => _instance;

  Future<String> get _sitesKeyForUser async {
    final userId = await UserContextService.instance.getCurrentUserId();
    if (userId == null) throw Exception('No user logged in');
    return '${_sitesKey}_$userId';
  }

  Future<String> get _countsKeyForUser async {
    final userId = await UserContextService.instance.getCurrentUserId();
    if (userId == null) throw Exception('No user logged in');
    return '${_countsKey}_$userId';
  }

  // Get all sites for current user
  Future<List<Site>> getAllSites() async {
    final prefs = await SharedPreferences.getInstance();
    final sitesKey = await _sitesKeyForUser;
    final sitesJson = prefs.getStringList(sitesKey) ?? [];
    
    return sitesJson
        .map((json) => Site.fromJson(jsonDecode(json)))
        .toList();
  }

  // Add new site for current user
  Future<void> addSite(Site site) async {
    final prefs = await SharedPreferences.getInstance();
    final sitesKey = await _sitesKeyForUser;
    final sites = await getAllSites();
    sites.add(site);
    
    final sitesJson = sites
        .map((site) => jsonEncode(site.toJson()))
        .toList();
    
    await prefs.setStringList(sitesKey, sitesJson);
  }

  // Update site for current user
  Future<void> updateSite(Site updatedSite) async {
    final prefs = await SharedPreferences.getInstance();
    final sitesKey = await _sitesKeyForUser;
    final sites = await getAllSites();
    
    final index = sites.indexWhere((site) => site.id == updatedSite.id);
    if (index != -1) {
      sites[index] = updatedSite;
      
      final sitesJson = sites
          .map((site) => jsonEncode(site.toJson()))
          .toList();
      
      await prefs.setStringList(sitesKey, sitesJson);
    }
  }

  // Delete site for current user
  Future<void> deleteSite(String siteId) async {
    final prefs = await SharedPreferences.getInstance();
    final sitesKey = await _sitesKeyForUser;
    final sites = await getAllSites();
    
    sites.removeWhere((site) => site.id == siteId);
    
    final sitesJson = sites
        .map((site) => jsonEncode(site.toJson()))
        .toList();
    
    await prefs.setStringList(sitesKey, sitesJson);
  }

  // Add bird count to a site for current user
  Future<void> addBirdCount(BirdCount count, String siteName) async {
    final sites = await getAllSites();
    
    // Find existing site or create new one
    Site? existingSite;
    int siteIndex = -1;
    
    for (int i = 0; i < sites.length; i++) {
      if (sites[i].name == siteName) {
        existingSite = sites[i];
        siteIndex = i;
        break;
      }
    }
    
    if (existingSite == null) {
      // Create new site if it doesn't exist
      final newSite = Site(
        id: generateSiteId(),
        name: siteName,
        description: 'Bird counting site',
        latitude: null,
        longitude: null,
        createdAt: DateTime.now(),
        birdCounts: [count],
      );
      sites.add(newSite);
    } else {
      // Update existing site with new bird count
      final updatedSite = Site(
        id: existingSite.id,
        name: existingSite.name,
        description: existingSite.description,
        latitude: existingSite.latitude,
        longitude: existingSite.longitude,
        createdAt: existingSite.createdAt,
        birdCounts: [...existingSite.birdCounts, count],
      );
      sites[siteIndex] = updatedSite;
    }
    
    // Save updated sites
    final prefs = await SharedPreferences.getInstance();
    final sitesKey = await _sitesKeyForUser;
    final sitesJson = sites
        .map((site) => jsonEncode(site.toJson()))
        .toList();
    
    await prefs.setStringList(sitesKey, sitesJson);
  }

  // Get bird counts for a specific site for current user
  Future<List<BirdCount>> getBirdCountsForSite(String siteName) async {
    final sites = await getAllSites();
    try {
      final site = sites.firstWhere((site) => site.name == siteName);
      return site.birdCounts;
    } catch (e) {
      // Return empty list if site not found
      return [];
    }
  }

  // Clear all data for current user
  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final sitesKey = await _sitesKeyForUser;
    final countsKey = await _countsKeyForUser;
    
    await prefs.remove(sitesKey);
    await prefs.remove(countsKey);
  }

  // Generate unique ID for new sites
  String generateSiteId() {
    final now = DateTime.now();
    final year = now.year.toString().substring(2);
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final random = (DateTime.now().millisecondsSinceEpoch % 1000).toString().padLeft(3, '0');
    
    return '$year-$month$day-$random';
  }
} 