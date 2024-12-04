import 'dart:async';
import 'package:flutter/material.dart';
import '../services/sqlmanage.dart';

class TableData {
  final List<DataColumn> columns;
  final List<DataRow> rows;

  TableData({required this.columns, required this.rows});
}

class TablesController {
  final DatabaseManager _dbManager = DatabaseManager();
  String? selectedTable;

  final _tablesController = StreamController<List<String>>.broadcast();
  final _tableDataController = StreamController<TableData>.broadcast();

  Stream<List<String>> get tablesStream => _tablesController.stream;
  Stream<TableData> get tableDataStream => _tableDataController.stream;

  TablesController() {
    _loadTables();
  }

  void _loadTables() async {
    final tables = await _dbManager.getTables();
    _tablesController.add(tables);
  }

  void selectTable(String? tableName) async {
    if (tableName == null) return;
    selectedTable = tableName;

    final data = await _dbManager.getTableData(tableName);
    final columns = await _dbManager.getTableColumns(tableName);

    _tableDataController.add(TableData(
      columns: columns.map((col) => DataColumn(label: Text(col))).toList(),
      rows: _convertToDataRows(data, columns),
    ));
  }

  List<DataRow> _convertToDataRows(
      List<Map<String, dynamic>> data, List<String> columns) {
    return data.map((row) {
      return DataRow(
        cells: columns
            .map((col) => DataCell(Text(row[col]?.toString() ?? 'null')))
            .toList(),
      );
    }).toList();
  }

  void dispose() {
    _tablesController.close();
    _tableDataController.close();
  }
}
