import 'dart:async';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static DatabaseService get instance => _instance;
  
  DatabaseService._internal();
  
  static Database? _database;
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    // Initialize database factory for web/desktop
    if (kIsWeb) {
      // For web, we'll use a different approach
      throw UnsupportedError('SQLite is not supported on web. Use IndexedDB or localStorage instead.');
    } else {
      // For mobile/desktop, initialize FFI if needed
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
      
      String path = join(await getDatabasesPath(), 'avicast.db');
      
      return await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    }
  }
  
  Future<void> _onCreate(Database db, int version) async {
    // Create tables
    await _createTables(db);
  }
  
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle future database upgrades
    if (oldVersion < newVersion) {
      // Add migration logic here
    }
  }
  
  Future<void> _createTables(Database db) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        userId TEXT UNIQUE NOT NULL,
        name TEXT,
        email TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
    
    // Sites table
    await db.execute('''
      CREATE TABLE sites (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        latitude REAL,
        longitude REAL,
        address TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
    
    // Bird counts table
    await db.execute('''
      CREATE TABLE bird_counts (
        id TEXT PRIMARY KEY,
        siteId TEXT NOT NULL,
        birdName TEXT NOT NULL,
        count INTEGER NOT NULL,
        observerName TEXT,
        latitude REAL,
        longitude REAL,
        timestamp TEXT NOT NULL,
        notes TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (siteId) REFERENCES sites (id) ON DELETE CASCADE
      )
    ''');
    
    // Notes table
    await db.execute('''
      CREATE TABLE notes (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT,
        type TEXT NOT NULL,
        filePath TEXT,
        latitude REAL,
        longitude REAL,
        timestamp TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
    
    // Photos table
    await db.execute('''
      CREATE TABLE photos (
        id TEXT PRIMARY KEY,
        noteId TEXT,
        filePath TEXT NOT NULL,
        latitude REAL,
        longitude REAL,
        timestamp TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (noteId) REFERENCES notes (id) ON DELETE CASCADE
      )
    ''');
  }
  
  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
} 