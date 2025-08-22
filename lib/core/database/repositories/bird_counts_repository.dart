import '../database_service.dart';
import '../models/bird_count_model.dart';

class BirdCountsRepository {
  final DatabaseService _databaseService = DatabaseService.instance;

  // Create a new bird count
  Future<String> createBirdCount(BirdCountModel birdCount) async {
    final db = await _databaseService.database;
    await db.insert('bird_counts', birdCount.toMap());
    return birdCount.id;
  }

  // Get all bird counts
  Future<List<BirdCountModel>> getAllBirdCounts() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query('bird_counts', orderBy: 'timestamp DESC');
    
    return List.generate(maps.length, (i) {
      return BirdCountModel.fromMap(maps[i]);
    });
  }

  // Get bird counts by site
  Future<List<BirdCountModel>> getBirdCountsBySite(String siteId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bird_counts',
      where: 'siteId = ?',
      whereArgs: [siteId],
      orderBy: 'timestamp DESC',
    );
    
    return List.generate(maps.length, (i) {
      return BirdCountModel.fromMap(maps[i]);
    });
  }

  // Get bird count by ID
  Future<BirdCountModel?> getBirdCountById(String id) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bird_counts',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return BirdCountModel.fromMap(maps.first);
    }
    return null;
  }

  // Update bird count
  Future<int> updateBirdCount(BirdCountModel birdCount) async {
    final db = await _databaseService.database;
    return await db.update(
      'bird_counts',
      birdCount.toMap(),
      where: 'id = ?',
      whereArgs: [birdCount.id],
    );
  }

  // Delete bird count
  Future<int> deleteBirdCount(String id) async {
    final db = await _databaseService.database;
    return await db.delete(
      'bird_counts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get bird counts by date range
  Future<List<BirdCountModel>> getBirdCountsByDateRange(DateTime startDate, DateTime endDate) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bird_counts',
      where: 'timestamp BETWEEN ? AND ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'timestamp DESC',
    );
    
    return List.generate(maps.length, (i) {
      return BirdCountModel.fromMap(maps[i]);
    });
  }

  // Get total count for a specific bird at a specific site
  Future<int> getTotalBirdCount(String siteId, String birdName) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT SUM(count) as total FROM bird_counts WHERE siteId = ? AND birdName = ?',
      [siteId, birdName],
    );
    
    if (maps.isNotEmpty && maps.first['total'] != null) {
      return maps.first['total'] as int;
    }
    return 0;
  }
} 