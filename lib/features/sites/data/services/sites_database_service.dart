import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Site {
  final String id;
  final String name;
  final DateTime createdAt;
  final List<BirdCount> birdCounts;

  Site({
    required this.id,
    required this.name,
    required this.createdAt,
    this.birdCounts = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'birdCounts': birdCounts.map((count) => count.toJson()).toList(),
    };
  }

  factory Site.fromJson(Map<String, dynamic> json) {
    return Site(
      id: json['id'],
      name: json['name'],
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
  final String observerName;

  BirdCount({
    required this.birdName,
    required this.birdFamily,
    required this.birdScientificName,
    required this.birdStatus,
    required this.count,
    required this.timestamp,
    required this.observerName,
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

  // Get all sites
  Future<List<Site>> getAllSites() async {
    final prefs = await SharedPreferences.getInstance();
    final sitesJson = prefs.getStringList(_sitesKey) ?? [];
    
    return sitesJson
        .map((json) => Site.fromJson(jsonDecode(json)))
        .toList();
  }

  // Add new site
  Future<void> addSite(Site site) async {
    final prefs = await SharedPreferences.getInstance();
    final sites = await getAllSites();
    sites.add(site);
    
    final sitesJson = sites
        .map((site) => jsonEncode(site.toJson()))
        .toList();
    
    await prefs.setStringList(_sitesKey, sitesJson);
  }

  // Update site
  Future<void> updateSite(Site updatedSite) async {
    final prefs = await SharedPreferences.getInstance();
    final sites = await getAllSites();
    
    final index = sites.indexWhere((site) => site.id == updatedSite.id);
    if (index != -1) {
      sites[index] = updatedSite;
      
      final sitesJson = sites
          .map((site) => jsonEncode(site.toJson()))
          .toList();
      
      await prefs.setStringList(_sitesKey, sitesJson);
    }
  }

  // Delete site
  Future<void> deleteSite(String siteId) async {
    final prefs = await SharedPreferences.getInstance();
    final sites = await getAllSites();
    
    sites.removeWhere((site) => site.id == siteId);
    
    final sitesJson = sites
        .map((site) => jsonEncode(site.toJson()))
        .toList();
    
    await prefs.setStringList(_sitesKey, sitesJson);
  }

  // Add bird count to a site
  Future<void> addBirdCount(String siteId, BirdCount count) async {
    final sites = await getAllSites();
    final siteIndex = sites.indexWhere((site) => site.id == siteId);
    
    if (siteIndex != -1) {
      final updatedSite = Site(
        id: sites[siteIndex].id,
        name: sites[siteIndex].name,
        createdAt: sites[siteIndex].createdAt,
        birdCounts: [...sites[siteIndex].birdCounts, count],
      );
      
      sites[siteIndex] = updatedSite;
      
      final prefs = await SharedPreferences.getInstance();
      final sitesJson = sites
          .map((site) => jsonEncode(site.toJson()))
          .toList();
      
      await prefs.setStringList(_sitesKey, sitesJson);
    }
  }

  // Get bird counts for a specific site
  Future<List<BirdCount>> getBirdCountsForSite(String siteId) async {
    final sites = await getAllSites();
    final site = sites.firstWhere((site) => site.id == siteId);
    return site.birdCounts;
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