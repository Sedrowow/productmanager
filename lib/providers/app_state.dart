import 'package:flutter/foundation.dart';

class AppState with ChangeNotifier {
  final Map<String, List<Map<String, dynamic>>> _persistedData = {
    'users': [],
    'products': [],
    'orders': [],
  };

  List<Map<String, dynamic>> getEntriesForModel(String modelType) {
    return _persistedData[modelType] ?? [];
  }

  void saveEntriesForModel(
      String modelType, List<Map<String, dynamic>> entries) {
    _persistedData[modelType] = List.from(entries);
    notifyListeners();
  }
}
