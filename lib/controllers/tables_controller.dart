import '../services/sqlmanage.dart';

class TablesController {
  final DatabaseManager _dbManager = DatabaseManager();
  String? selectedTable;
  List<Map<String, dynamic>>? currentTableData;
  List<Map<String, dynamic>>? currentColumnInfo;

  Future<List<String>> getTables() async {
    final db = await _dbManager.database;
    final List<Map<String, dynamic>> tables = await db.query(
      'sqlite_master',
      where: 'type = ?',
      whereArgs: ['table'],
    );
    return tables.map((table) => table['name'].toString()).toList();
  }

  Future<void> selectTable(String tableName) async {
    selectedTable = tableName;
    await _loadTableData();
    await _loadColumnInfo();
  }

  Future<void> _loadTableData() async {
    if (selectedTable == null) return;
    final db = await _dbManager.database;
    currentTableData = await db.query(selectedTable!);
  }

  Future<void> _loadColumnInfo() async {
    if (selectedTable == null) return;
    final db = await _dbManager.database;
    currentColumnInfo =
        await db.rawQuery("PRAGMA table_info('$selectedTable')");
  }
}
