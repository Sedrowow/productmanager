import '../services/sqlmanage.dart';

class MainController {
  final DatabaseManager _dbManager = DatabaseManager();

  Future<bool> checkDatabaseConnection() async {
    return await _dbManager.checkDatabaseConnection();
  }
}
