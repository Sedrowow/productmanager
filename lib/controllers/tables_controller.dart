import 'package:flutter/material.dart';

import '../services/sqlmanage.dart';

class TablesController {
  final DatabaseManager _dbManager = DatabaseManager();
  String? selectedTable;
  List<Map<String, dynamic>>? currentTableData;
  List<Map<String, dynamic>>? currentColumnInfo;
  List<String>? availableTables;

  Future<List<String>> getTables() async {
    if (availableTables != null) return availableTables!;

    final db = await _dbManager.database;
    final List<Map<String, dynamic>> tables = await db.query(
      'sqlite_master',
      where: 'type = ?',
      whereArgs: ['table'],
    );
    availableTables = tables.map((table) => table['name'].toString()).toList();
    return availableTables!;
  }

  Future<void> onTableSelected(String tableName) async {
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

  List<DataColumn> getColumns() {
    if (currentColumnInfo == null) return [];
    return currentColumnInfo!
        .map((col) => DataColumn(label: Text(col['name'])))
        .toList();
  }

  List<DataRow> getRows() {
    if (currentTableData == null || currentColumnInfo == null) return [];
    return currentTableData!.map((row) {
      return DataRow(
        cells: currentColumnInfo!.map((col) {
          return DataCell(
            Text(row[col['name']]?.toString() ?? 'null'),
          );
        }).toList(),
      );
    }).toList();
  }
}
