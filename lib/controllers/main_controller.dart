import 'dart:async';
import 'package:flutter/material.dart';
import '../services/sqlmanage.dart';
import '../screens/tables_screen.dart';

class MainController {
  final DatabaseManager _dbManager = DatabaseManager();
  final _connectionController = StreamController<bool>.broadcast();

  Stream<bool> get connectionStream => _connectionController.stream;

  MainController() {
    checkConnection();
  }

  Future<void> checkConnection() async {
    final isConnected = await _dbManager.checkConnection();
    _connectionController.add(isConnected);
  }

  void navigateToTables(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TablesScreen(),
      ),
    );
  }

  void dispose() {
    _connectionController.close();
  }
}
