import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/base_table.dart';
import '../models/users_table.dart';
import '../models/products_table.dart';
import '../models/orders_table.dart';

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
    String path;

    if (kIsWeb) {
      path = 'management.db';
    } else {
      path = join(await getDatabasesPath(), 'management.db');
      // Check if database exists
      bool exists = await databaseExists(path);
      if (!exists) {
        try {
          await Directory(dirname(path)).create(recursive: true);
        } catch (_) {}
      }
    }

    // Open/create database
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  final List<BaseTable> _tables = [
    User(name: '', email: ''),
    Product(name: '', price: 0),
    Order(userId: 0, productId: 0, quantity: 0),
  ];

  Future<void> _createTables(Database db, int version) async {
    for (var table in _tables) {
      await db.execute(table.createTableQuery);
    }
  }

  Future<List<String>> getTables() async {
    return _tables.map((table) => table.tableName).toList();
  }

  Future<List<Map<String, dynamic>>> getTableData(String tableName) async {
    final db = await database;
    return await db.query(tableName);
  }

  // Add other database operations as needed

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
}
