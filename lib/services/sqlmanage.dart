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

  factory DatabaseManager() => _instance;
  DatabaseManager._internal();

  Future<Database> get database async {
    return _database ??= await _initDatabase();
  }

  Future<Database> _initDatabase() async {
    final path = kIsWeb
        ? 'management.db'
        : join(await getDatabasesPath(), 'management.db');

    if (!kIsWeb) {
      final dbFolder = Directory(dirname(path));
      if (!await dbFolder.exists()) {
        await dbFolder.create(recursive: true);
      }
    }

    return await openDatabase(path, version: 1, onCreate: _createTables);
  }

  Future<void> _createTables(Database db, int version) async {
    for (var table in _tables) {
      await db.execute(table.createTableQuery);
    }
  }

  final List<BaseTable> _tables = [
    User(name: '', email: ''),
    Product(name: '', price: 0),
    Order(userId: 0, productId: 0, quantity: 0),
  ];

  Future<List<String>> getTables() async {
    final db = await database;
    final tables = await db.query(
      'sqlite_master',
      where: 'type = ?',
      whereArgs: ['table'],
    );
    return tables.map((t) => t['name'] as String).toList();
  }

  Future<List<String>> getTableColumns(String tableName) async {
    final db = await database;
    final columns = await db.rawQuery("PRAGMA table_info('$tableName')");
    return columns.map((c) => c['name'] as String).toList();
  }

  Future<List<Map<String, dynamic>>> getTableData(String tableName) async {
    final db = await database;
    return await db.query(tableName);
  }

  Future<bool> checkConnection() async {
    try {
      final db = await database;
      await db.query('sqlite_master');
      return true;
    } catch (_) {
      return false;
    }
  }
}
