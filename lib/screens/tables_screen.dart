import 'package:flutter/material.dart';
import '../controllers/tables_controller.dart';

class TablesScreen extends StatefulWidget {
  const TablesScreen({super.key});

  @override
  State<TablesScreen> createState() => _TablesScreenState();
}

class _TablesScreenState extends State<TablesScreen> {
  final TablesController _controller = TablesController();
  String? _selectedTable;
  List<Map<String, dynamic>>? _tableData;
  List<Map<String, dynamic>>? _columnInfo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Tables'),
      ),
      body: Column(
        children: [
          FutureBuilder<List<String>>(
            future: _controller.getTables(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }

              return DropdownButton<String>(
                value: _selectedTable,
                hint: const Text('Select a table'),
                items: snapshot.data!.map((String table) {
                  return DropdownMenuItem<String>(
                    value: table,
                    child: Text(table),
                  );
                }).toList(),
                onChanged: (String? newValue) async {
                  setState(() => _selectedTable = newValue);
                  if (newValue != null) {
                    _tableData = await _controller.getTableData(newValue);
                    _columnInfo = await _controller.getTableColumns(newValue);
                    setState(() {});
                  }
                },
              );
            },
          ),
          if (_tableData != null && _columnInfo != null)
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: DataTable(
                    columns: _columnInfo!
                        .map((col) => DataColumn(label: Text(col['name'])))
                        .toList(),
                    rows: _tableData!.map((row) {
                      return DataRow(
                        cells: _columnInfo!.map((col) {
                          return DataCell(
                            Text(row[col['name']]?.toString() ?? 'null'),
                          );
                        }).toList(),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
