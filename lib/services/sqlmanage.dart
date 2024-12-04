import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/base.dart';
import '../models/users.dart';
import '../models/products.dart';
import '../models/orders.dart';

class DatabaseManager {
  static final DatabaseManager _instance = DatabaseManager._internal();
  static Database? _database;

  factory DatabaseManager() => _instance;
  DatabaseManager._internal();

  final List<BaseTable> _models = [
    User(fname: '', lname: ''),
    Product(name: '', price: 0.0),
    Order(userId: 0, productId: 0, quantity: 0),
  ];

  String _generateCreateTableQuery(BaseTable model) {
    final Map<String, dynamic> sampleData = model.toMap();
    final List<String> columns = [];

    // Add ID column as primary key
    columns.add('id INTEGER PRIMARY KEY AUTOINCREMENT');

    // Generate columns based on model data
    sampleData.forEach((key, value) {
      if (key != 'id') {
        String type = '';
        if (value is String) {
          type = 'TEXT';
        } else if (value is int) {
          type = 'INTEGER';
        } else if (value is double) {
          type = 'REAL';
        }

        String constraint = 'NOT NULL';
        if (key == 'email') constraint += ' UNIQUE';

        columns.add('$key $type $constraint');
      }
    });

    // Add foreign key constraints for Order table
    if (model is Order) {
      columns.add('FOREIGN KEY (user_id) REFERENCES users (id)');
      columns.add('FOREIGN KEY (product_id) REFERENCES products (id)');
    }

    return '''
      CREATE TABLE IF NOT EXISTS ${model.tableName} (
        ${columns.join(',\n        ')}
      )
    ''';
  }

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
    for (var model in _models) {
      final query = _generateCreateTableQuery(model);
      await db.execute(query);
    }
  }

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
