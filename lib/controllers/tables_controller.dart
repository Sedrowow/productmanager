import '../services/sqlmanage.dart';

class TablesController {
  final DatabaseManager _dbManager = DatabaseManager();

  Future<List<String>> getTables() async {
    final db = await _dbManager.database;
    final List<Map<String, dynamic>> tables = await db.query(
      'sqlite_master',
      where: 'type = ?',
      whereArgs: ['table'],
    );
    return tables.map((table) => table['name'].toString()).toList();
  }

  Future<List<Map<String, dynamic>>> getTableData(String tableName) async {
    final db = await _dbManager.database;
    return await db.query(tableName);
  }

  Future<List<Map<String, dynamic>>> getTableColumns(String tableName) async {
    final db = await _dbManager.database;
    final List<Map<String, dynamic>> result =
        await db.rawQuery("PRAGMA table_info('$tableName')");
    return result;
  }
}
