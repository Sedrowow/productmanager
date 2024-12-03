import 'package:flutter/material.dart';
import '../controllers/tables_controller.dart';

class TablesScreen extends StatefulWidget {
  const TablesScreen({super.key});

  @override
  State<TablesScreen> createState() => _TablesScreenState();
}

class _TablesScreenState extends State<TablesScreen> {
  final TablesController _controller = TablesController();

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
                value: _controller.selectedTable,
                hint: const Text('Select a table'),
                items: snapshot.data!.map((String table) {
                  return DropdownMenuItem<String>(
                    value: table,
                    child: Text(table),
                  );
                }).toList(),
                onChanged: (String? newValue) async {
                  if (newValue != null) {
                    await _controller.onTableSelected(newValue);
                    setState(() {});
                  }
                },
              );
            },
          ),
          if (_controller.currentTableData != null &&
              _controller.currentColumnInfo != null)
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: DataTable(
                    columns: _controller.getColumns(),
                    rows: _controller.getRows(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
