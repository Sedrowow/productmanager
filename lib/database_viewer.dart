import 'package:flutter/material.dart';
import 'sqlmanage.dart';

class DatabaseViewerScreen extends StatefulWidget {
  const DatabaseViewerScreen({super.key});

  @override
  State<DatabaseViewerScreen> createState() => _DatabaseViewerScreenState();
}

class _DatabaseViewerScreenState extends State<DatabaseViewerScreen> {
  final DatabaseManager _dbManager = DatabaseManager();
  String? _selectedTable;
  List<Map<String, dynamic>> _tableData = [];

  Future<void> _loadTableData(String tableName) async {
    final data = await _dbManager.getTableContent(tableName);
    setState(() {
      _selectedTable = tableName;
      _tableData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(_selectedTable ?? 'Database Viewer'),
      ),
      body: Row(
        children: [
          // Sidebar
          SizedBox(
            width: 200,
            child: Drawer(
              child: FutureBuilder<List<String>>(
                future: _dbManager.getTables(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return ListView(
                    children: snapshot.data!.map((table) {
                      return ListTile(
                        title: Text(table),
                        selected: _selectedTable == table,
                        onTap: () => _loadTableData(table),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ),
          // Data view
          Expanded(
            child: _selectedTable == null
                ? const Center(
                    child: Text('Select a table from the sidebar'),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: _tableData.isEmpty
                          ? const Center(
                              child: Text('No data in this table'),
                            )
                          : DataTable(
                              columns: _tableData.first.keys
                                  .map((key) => DataColumn(label: Text(key)))
                                  .toList(),
                              rows: _tableData
                                  .map(
                                    (row) => DataRow(
                                      cells: row.values
                                          .map((value) => DataCell(Text(
                                              value?.toString() ?? 'null')))
                                          .toList(),
                                    ),
                                  )
                                  .toList(),
                            ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
