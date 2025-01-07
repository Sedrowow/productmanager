import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/base.dart';
import '../models/users.dart';
import '../models/products.dart';
import '../models/orders.dart';

class DatabaseManager {
  static final DatabaseManager _instance = DatabaseManager._internal();
  static Database? _database;
  static const String dbName = 'product_manager.db';

  factory DatabaseManager() => _instance;
  DatabaseManager._internal();

  final List<BaseTable> _models = [
    User(fname: '', lname: ''),
    Product(name: '', price: 0.0),
    Order(userId: 0, productId: 0, quantity: 0),
  ];

  List<String> getAvailableModels() {
    // Simply return the table names from our predefined models
    return _models.map((model) => model.tableName).toList();
  }

  BaseTable? createModel(String modelType) {
    try {
      return _models
          .firstWhere((model) => model.tableName == modelType)
          .clone();
    } catch (e) {
      return null;
    }
  }

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
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    for (var model in _models) {
      final query = _generateCreateTableQuery(model);
      await db.execute(query);
    }
  }

  Future<void> clearDatabase() async {
    final db = await database;
    // Get all table names
    final tables = ['users', 'products', 'orders'];

    // Drop all tables
    for (final table in tables) {
      await db.execute('DELETE FROM $table');
      // Reset the auto-increment counter
      await db.execute('DELETE FROM sqlite_sequence WHERE name = ?', [table]);
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

  Future<List<Map<String, dynamic>>> getEntries(BaseTable model) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(model.tableName);
    return result;
  }

  Future<int> insertEntry(BaseTable model, Map<String, dynamic> entry) async {
    final db = await database;
    return await db.insert(
      model.tableName,
      entry,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteEntry(BaseTable model, int id) async {
    final db = await database;

    // If deleting a user or product, check for dependent orders first
    if (model.tableName == 'users' || model.tableName == 'products') {
      final String fieldName =
          '${model.tableName.substring(0, model.tableName.length - 1)}_id';
      final dependentOrders = await db.query(
        'orders',
        where: '$fieldName = ?',
        whereArgs: [id],
      );

      if (dependentOrders.isNotEmpty) {
        // Delete dependent orders first
        await db.delete(
          'orders',
          where: '$fieldName = ?',
          whereArgs: [id],
        );
      }
    }

    return await db.delete(
      model.tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
