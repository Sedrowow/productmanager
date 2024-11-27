import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:logger/logger.dart';

class DatabaseManager {
  static final DatabaseManager _instance = DatabaseManager._internal();
  static Database? _database;

  factory DatabaseManager() {
    return _instance;
  }

  DatabaseManager._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Get database path
    String path = join(await getDatabasesPath(), 'management.db');

    // Check if database exists
    bool exists = await databaseExists(path);

    if (!exists) {
      // create the database
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}
    }

    // Open/create database
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Create tables if they don't exist
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');
  }

  // Method to check database connection
  Future<bool> checkDatabaseConnection() async {
    try {
      final db = await database;
      await db.query('sqlite_master');
      return true;
    } catch (e) {
      return false;
    }
  }

  // Add this method at the end of DatabaseManager class
  Future<bool> forceCreateDatabase() async {
    try {
      String path = join(await getDatabasesPath(), 'management.db');

      // Ensure directory exists
      await Directory(dirname(path)).create(recursive: true);

      // Force create database and tables
      _database = await openDatabase(
        path,
        version: 1,
        onCreate: _createTables,
      );

      return await checkDatabaseConnection();
    } catch (e) {
      final logger = Logger();
      logger.e('Database creation error',
          error: e, stackTrace: StackTrace.current);
      return false;
    }
  }

  Future<List<String>> getTables() async {
    try {
      final db = await database;
      final tables = await db
          .query('sqlite_master', where: 'type = ?', whereArgs: ['table']);
      return tables.map((t) => t['name'] as String).toList()
        ..removeWhere((table) =>
            table == 'android_metadata' || table == 'sqlite_sequence');
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getTableContent(String tableName) async {
    try {
      final db = await database;
      return await db.query(tableName);
    } catch (e) {
      return [];
    }
  }
}
