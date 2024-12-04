import 'package:flutter/material.dart';
import '../controllers/tables_controller.dart';

class TablesScreen extends StatelessWidget {
  const TablesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Tables'),
      ),
      body: TablesView(),
    );
  }
}

class TablesView extends StatelessWidget {
  final _controller = TablesController();

  TablesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StreamBuilder<List<String>>(
          stream: _controller.tablesStream,
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
              onChanged: _controller.selectTable,
            );
          },
        ),
        StreamBuilder<TableData>(
          stream: _controller.tableDataStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox();

            return Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: DataTable(
                    columns: snapshot.data!.columns,
                    rows: snapshot.data!.rows,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
