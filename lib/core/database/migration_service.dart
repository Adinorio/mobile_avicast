import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'database_service.dart';
import 'web_storage_service.dart';
import 'repositories/sites_repository.dart';
import 'repositories/bird_counts_repository.dart';
import 'models/site_model.dart';
import 'models/bird_count_model.dart';
import '../../features/sites/data/services/sites_database_service.dart';

class MigrationService {
  final DatabaseService _databaseService = DatabaseService.instance;
  final WebStorageService _webStorageService = WebStorageService.instance;
  final SitesRepository _sitesRepository = GetIt.instance<SitesRepository>();
  final BirdCountsRepository _birdCountsRepository = GetIt.instance<BirdCountsRepository>();
  final SitesDatabaseService _oldSitesService = GetIt.instance<SitesDatabaseService>();
  
  final _uuid = Uuid();

  // Migrate existing data to the new database
  Future<void> migrateExistingData() async {
    try {
      // Ensure database is initialized
      await _databaseService.database;
      
      // Migrate sites data
      await _migrateSites();
      
      // Migrate bird counts data
      await _migrateBirdCounts();
      
      print('Data migration completed successfully!');
    } catch (e) {
      print('Error during data migration: $e');
      rethrow;
    }
  }

  // Migrate existing sites data
  Future<void> _migrateSites() async {
    try {
      // Get existing sites from old service
      final existingSites = await _oldSitesService.getAllSites();
      
      for (final site in existingSites) {
        // Check if site already exists in new database
        final existingSite = await _sitesRepository.searchSites(site.name);
        if (existingSite.isEmpty) {
          // Create new site in database
          final newSite = SiteModel(
            id: site.id,
            name: site.name,
            description: 'Migrated from existing data',
            createdAt: site.createdAt,
            updatedAt: DateTime.now(),
          );
          
          await _sitesRepository.createSite(newSite);
          print('Migrated site: ${site.name}');
        }
      }
    } catch (e) {
      print('Error migrating sites: $e');
    }
  }

  // Migrate existing bird counts data
  Future<void> _migrateBirdCounts() async {
    try {
      // Get existing sites with their bird counts
      final existingSites = await _oldSitesService.getAllSites();
      
      for (final site in existingSites) {
        for (final count in site.birdCounts) {
          // Check if count already exists in new database
          final existingCounts = await _birdCountsRepository.getAllBirdCounts();
          final exists = existingCounts.any((ec) => 
            ec.birdName == count.birdName && 
            ec.count == count.count &&
            ec.timestamp == count.timestamp
          );
          
          if (!exists) {
            // Create new bird count in database
            final newCount = BirdCountModel(
              id: _uuid.v4(),
              siteId: site.id,
              birdName: count.birdName,
              count: count.count,
              observerName: count.observerName,
              latitude: null, // Not available in old data
              longitude: null, // Not available in old data
              timestamp: count.timestamp,
              notes: null, // Not available in old data
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
            
            await _birdCountsRepository.createBirdCount(newCount);
            print('Migrated bird count: ${count.birdName} - ${count.count}');
          }
        }
      }
    } catch (e) {
      print('Error migrating bird counts: $e');
    }
  }

  // Check if migration is needed
  Future<bool> isMigrationNeeded() async {
    try {
      if (kIsWeb) {
        // For web, check web storage
        final sites = await _webStorageService.getSites();
        final birdCounts = await _webStorageService.getBirdCounts();
        return sites.isEmpty && birdCounts.isEmpty;
      } else {
        // For mobile/desktop, check SQLite database
        final db = await _databaseService.database;
        final sites = await db.query('sites');
        final birdCounts = await db.query('bird_counts');
        return sites.isEmpty && birdCounts.isEmpty;
      }
    } catch (e) {
      print('Error checking migration status: $e');
      return false;
    }
  }

  // Get migration status
  Future<Map<String, dynamic>> getMigrationStatus() async {
    try {
      if (kIsWeb) {
        // For web, get from web storage
        final sites = await _webStorageService.getSites();
        final birdCounts = await _webStorageService.getBirdCounts();
        
        return {
          'sitesCount': sites.length,
          'birdCountsCount': birdCounts.length,
          'databaseInitialized': true,
          'platform': 'web',
        };
      } else {
        // For mobile/desktop, get from SQLite database
        final db = await _databaseService.database;
        final sites = await db.query('sites');
        final birdCounts = await db.query('bird_counts');
        
        return {
          'sitesCount': sites.length,
          'birdCountsCount': birdCounts.length,
          'databaseInitialized': true,
          'platform': 'mobile/desktop',
        };
      }
    } catch (e) {
      return {
        'sitesCount': 0,
        'birdCountsCount': 0,
        'databaseInitialized': false,
        'platform': kIsWeb ? 'web' : 'mobile/desktop',
        'error': e.toString(),
      };
    }
  }
} 