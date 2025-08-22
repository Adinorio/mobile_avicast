import '../database_service.dart';
import '../models/site_model.dart';

class SitesRepository {
  final DatabaseService _databaseService = DatabaseService.instance;

  // Create a new site
  Future<String> createSite(SiteModel site) async {
    final db = await _databaseService.database;
    await db.insert('sites', site.toMap());
    return site.id;
  }

  // Get all sites
  Future<List<SiteModel>> getAllSites() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query('sites', orderBy: 'createdAt DESC');
    
    return List.generate(maps.length, (i) {
      return SiteModel.fromMap(maps[i]);
    });
  }

  // Get site by ID
  Future<SiteModel?> getSiteById(String id) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sites',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return SiteModel.fromMap(maps.first);
    }
    return null;
  }

  // Update site
  Future<int> updateSite(SiteModel site) async {
    final db = await _databaseService.database;
    return await db.update(
      'sites',
      site.toMap(),
      where: 'id = ?',
      whereArgs: [site.id],
    );
  }

  // Delete site
  Future<int> deleteSite(String id) async {
    final db = await _databaseService.database;
    return await db.delete(
      'sites',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Search sites by name
  Future<List<SiteModel>> searchSites(String query) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sites',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'createdAt DESC',
    );
    
    return List.generate(maps.length, (i) {
      return SiteModel.fromMap(maps[i]);
    });
  }
} 