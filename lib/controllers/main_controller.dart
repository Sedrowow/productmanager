import 'package:flutter/material.dart';
import '../services/sqlmanage.dart';
import '../screens/tables_screen.dart';

class MainController {
  final DatabaseManager _dbManager = DatabaseManager();
  bool isConnected = false;

  Future<void> checkConnection() async {
    isConnected = await _dbManager.checkDatabaseConnection();
  }

  void navigateToTables(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TablesScreen(),
      ),
    );
  }
}
