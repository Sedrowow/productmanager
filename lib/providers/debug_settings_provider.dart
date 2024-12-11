import 'package:flutter/foundation.dart';

class DebugSettingsProvider with ChangeNotifier {
  bool _isDebugUnlocked = false;
  bool _showDebugLogs = false;
  final bool _isDevelopmentMode = kDebugMode; // Only true in debug builds

  bool get isDebugUnlocked => _isDebugUnlocked;
  bool get showDebugLogs => _showDebugLogs && _isDebugUnlocked;
  bool get isDevelopmentMode => _isDevelopmentMode;

  void setDebugUnlocked(bool value) {
    _isDebugUnlocked = value;
    notifyListeners();
  }

  void setShowDebugLogs(bool value) {
    _showDebugLogs = value;
    notifyListeners();
  }
}
