import 'package:flutter/foundation.dart';
import '../services/sqlmanage.dart';
import 'dart:math';

class DataProvider with ChangeNotifier {
  final DatabaseManager _dbManager = DatabaseManager();
  final Map<String, List<Map<String, dynamic>>> _data = {
    'users': [],
    'products': [],
    'orders': [],
  };
  final Map<String, List<Map<String, dynamic>>> _tempData = {
    'users': [],
    'products': [],
    'orders': [],
  };

  List<Map<String, dynamic>> getEntries(String modelType) =>
      [...(_data[modelType] ?? []), ...(_tempData[modelType] ?? [])];

  List<Map<String, dynamic>> getTemporaryEntries(String modelType) =>
      List.from(_tempData[modelType] ?? []);

  List<Map<String, dynamic>> getPersistedEntries(String modelType) =>
      List.from(_data[modelType] ?? []);

  Future<void> loadData(String modelType) async {
    final model = _dbManager.createModel(modelType);
    if (model == null) return;

    final entries = await _dbManager.getEntries(model);
    _data[modelType] = entries;
    notifyListeners();
  }

  Future<void> loadRelatedData(String modelType) async {
    if (modelType == 'orders') {
      await loadData('users');
      await loadData('products');
    }
    await loadData(modelType);
  }

  void addTemporaryEntry(String modelType, Map<String, dynamic> entry) {
    // Get the next available ID
    final nextId = _getNextAvailableId(modelType);
    entry['id'] = nextId;
    _tempData[modelType]?.add(entry);
    notifyListeners();
  }

  int _getNextAvailableId(String modelType) {
    final persistedEntries = _data[modelType] ?? [];
    final tempEntries = _tempData[modelType] ?? [];
    final allEntries = [...persistedEntries, ...tempEntries];

    if (allEntries.isEmpty) return 1;

    final maxId = allEntries
        .map((e) => int.tryParse(e['id']?.toString() ?? '0') ?? 0)
        .reduce((max, id) => id > max ? id : max);

    return maxId + 1;
  }

  Future<void> persistTemporaryEntries(String modelType) async {
    final model = _dbManager.createModel(modelType);
    if (model == null) return;

    for (var entry in _tempData[modelType] ?? []) {
      await _dbManager.insertEntry(model, entry);
    }
    _tempData[modelType]?.clear();
    await loadData(modelType);
  }

  Future<void> saveEntry(String modelType, Map<String, dynamic> entry) async {
    final model = _dbManager.createModel(modelType);
    if (model == null) return;

    await _dbManager.insertEntry(model, entry);
    await loadData(modelType);
  }

  Future<void> deleteEntry(String modelType, int index) async {
    final entries = _data[modelType];
    if (entries == null || index >= entries.length) return;

    final model = _dbManager.createModel(modelType);
    if (model == null) return;

    await _dbManager.deleteEntry(model, entries[index]['id']);
    await loadData(modelType);
  }

  void deleteTemporaryEntry(String modelType, int index) {
    _tempData[modelType]?.removeAt(index);
    notifyListeners();
  }

  void updateTemporaryEntry(
      String modelType, int index, Map<String, dynamic> entry) {
    if ((_tempData[modelType]?.length ?? 0) > index) {
      _tempData[modelType]![index] = entry;
      notifyListeners();
    }
  }

  Future<String> validateOrderReferences(Map<String, dynamic> order) async {
    final userId = order['user_id']?.toString();
    final productId = order['product_id']?.toString();

    if (userId == null || productId == null) {
      return 'Invalid order data';
    }

    final userExists = await _checkEntityExists('users', userId);
    final productExists = await _checkEntityExists('products', productId);

    if (!userExists && !productExists) {
      return 'Invalid user and product IDs';
    } else if (!userExists) {
      return 'Invalid user ID';
    } else if (!productExists) {
      return 'Invalid product ID';
    }

    final user = await _getEntityById('users', userId);
    final product = await _getEntityById('products', productId);
    return 'User: ${user['fname']} ${user['lname']}, Product: ${product['name']}';
  }

  Future<bool> _checkEntityExists(String modelType, String id) async {
    final model = _dbManager.createModel(modelType);
    if (model == null) return false;

    final entries = await _dbManager.getEntries(model);
    return entries.any((e) => e['id']?.toString() == id);
  }

  Future<Map<String, dynamic>> _getEntityById(
      String modelType, String id) async {
    final model = _dbManager.createModel(modelType);
    if (model == null) return {};

    final entries = await _dbManager.getEntries(model);
    return entries.firstWhere(
      (e) => e['id']?.toString() == id,
      orElse: () => {},
    );
  }

  Future<String> getEntitySuggestions(String modelType, String query) async {
    if (query.isEmpty) return '';

    // Get both persisted and temporary entries
    final persistedEntries =
        await _dbManager.getEntries(_dbManager.createModel(modelType)!);
    final tempEntries = _tempData[modelType] ?? [];
    final allEntries = [...persistedEntries, ...tempEntries];

    final matches = allEntries.where((entry) {
      final id = entry['id']?.toString() ?? '';
      if (modelType == 'users') {
        final fname = entry['fname']?.toString().toLowerCase() ?? '';
        final lname = entry['lname']?.toString().toLowerCase() ?? '';
        return id.startsWith(query) ||
            fname.contains(query.toLowerCase()) ||
            lname.contains(query.toLowerCase());
      } else {
        final name = entry['name']?.toString().toLowerCase() ?? '';
        return id.startsWith(query) || name.contains(query.toLowerCase());
      }
    }).toList();

    if (matches.isEmpty) return 'No matches found';

    return matches.map((e) {
      final isTemp = _isTemporary(modelType, e);
      if (modelType == 'users') {
        return '${e['id']} - ${e['fname']} ${e['lname']}${isTemp ? ' (temporary)' : ''}';
      } else {
        return '${e['id']} - ${e['name']}${isTemp ? ' (temporary)' : ''}';
      }
    }).join('\n');
  }

  bool _isTemporary(String modelType, Map<String, dynamic> entry) {
    return _tempData[modelType]
            ?.any((e) => e['id']?.toString() == entry['id']?.toString()) ??
        false;
  }

  Future<String> getOrderDetailsAsync(Map<String, dynamic> order) async {
    await ensureRelatedDataLoaded();

    final userId = order['user_id']?.toString();
    final productId = order['product_id']?.toString();
    final quantity = int.tryParse(order['quantity']?.toString() ?? '0') ?? 0;

    final user = _getEntityFromBothStorages('users', userId);
    final product = _getEntityFromBothStorages('products', productId);

    final userName =
        user.isNotEmpty ? '${user['fname']} ${user['lname']}' : 'Unknown';
    final productName = product['name'] ?? 'Unknown';
    final price = double.tryParse(product['price']?.toString() ?? '0') ?? 0.0;
    final total = price * quantity;

    return 'User: $userName\n'
        'Product: $productName\n'
        'QTY: $quantity\n'
        'Total: \$${total.toStringAsFixed(2)}';
  }

  String getOrderDetails(Map<String, dynamic> order) {
    final userId = order['user_id']?.toString();
    final productId = order['product_id']?.toString();
    final quantity = int.tryParse(order['quantity']?.toString() ?? '0') ?? 0;

    // Load data if not already loaded
    if (_data['users']?.isEmpty ?? true) {
      loadData('users'); // Note: This is async but we're in a sync method
    }
    if (_data['products']?.isEmpty ?? true) {
      loadData('products'); // Note: This is async but we're in a sync method
    }

    // Use cached data from both storages
    final user = _getEntityFromBothStorages('users', userId);
    final product = _getEntityFromBothStorages('products', productId);

    if (user.isEmpty || product.isEmpty) {
      return 'Loading...'; // Return loading state if data isn't ready
    }

    final userName =
        user.isNotEmpty ? '${user['fname']} ${user['lname']}' : 'Unknown';
    final productName = product['name'] ?? 'Unknown';
    final price = double.tryParse(product['price']?.toString() ?? '0') ?? 0.0;
    final total = price * quantity;

    return 'User: $userName\n'
        'Product: $productName\n'
        'QTY: $quantity\n'
        'Total: \$${total.toStringAsFixed(2)}';
  }

  Map<String, dynamic> _getEntityFromBothStorages(
      String modelType, String? id) {
    if (id == null) return {};

    // Check temporary data first, since it might override persisted data
    final tempEntity = _tempData[modelType]?.firstWhere(
      (e) => e['id'].toString() == id.toString(),
      orElse: () => {},
    );
    if (tempEntity?.isNotEmpty ?? false) {
      return Map<String, dynamic>.from(tempEntity!);
    }

    // Then check persisted data
    final persistedEntity = _data[modelType]?.firstWhere(
      (e) => e['id'].toString() == id.toString(),
      orElse: () => {},
    );

    return Map<String, dynamic>.from(persistedEntity ?? {});
  }

  Future<bool> validateOrderEntry(Map<String, dynamic> order) async {
    final userId = order['user_id']?.toString();
    final productId = order['product_id']?.toString();

    if (userId == null || productId == null) return false;

    await loadData('users');
    await loadData('products');

    final user = await _getEntityById('users', userId);
    final product = await _getEntityById('products', productId);

    return user.isNotEmpty && product.isNotEmpty;
  }

  Future<void> clearDatabase() async {
    await _dbManager.clearDatabase();
    // Create new empty lists instead of trying to clear existing ones
    _data.forEach((key, _) {
      _data[key] = [];
    });
    _tempData.forEach((key, _) {
      _tempData[key] = [];
    });
    notifyListeners();
  }

  Future<void> populateWithRandomData(String modelType, int count) async {
    if (modelType == 'orders') {
      // Ensure we have enough users and products
      if ((_data['users']?.length ?? 0) < 3 ||
          (_data['products']?.length ?? 0) < 3) {
        throw Exception(
            'Need at least 3 users and 3 products to populate orders');
      }
    }

    final model = _dbManager.createModel(modelType);
    if (model == null) return;

    final random = Random();
    final List<String> firstNames = [
      'John',
      'Jane',
      'Mike',
      'Sarah',
      'Tom',
      'Lisa'
    ];
    final List<String> lastNames = [
      'Smith',
      'Johnson',
      'Williams',
      'Brown',
      'Jones'
    ];
    final List<String> products = [
      'Laptop',
      'Phone',
      'Tablet',
      'Watch',
      'Headphones'
    ];

    for (var i = 0; i < count; i++) {
      Map<String, dynamic> entry = {};

      switch (modelType) {
        case 'users':
          entry = {
            'fname': firstNames[random.nextInt(firstNames.length)],
            'lname': lastNames[random.nextInt(lastNames.length)],
          };
          break;

        case 'products':
          entry = {
            'name':
                '${products[random.nextInt(products.length)]} ${random.nextInt(1000)}',
            'price':
                (random.nextInt(1000) + random.nextDouble()).toStringAsFixed(2),
          };
          break;

        case 'orders':
          // First check if we have users and products
          final users = getEntries('users');
          final products = getEntries('products');

          if (users.isEmpty || products.isEmpty) {
            throw Exception('Cannot create orders without users and products');
          }

          final user = users[random.nextInt(users.length)];
          final product = products[random.nextInt(products.length)];

          entry = {
            'user_id': user['id'],
            'product_id': product['id'],
            'quantity': random.nextInt(5) + 1,
            'status': ['pending', 'completed', 'cancelled'][random.nextInt(3)],
            'order_date': DateTime.now()
                .subtract(Duration(days: random.nextInt(30)))
                .toIso8601String(),
          };
          break;
      }

      if (entry.isNotEmpty) {
        await saveEntry(modelType, entry);
      }
    }

    await loadData(modelType);
  }

  Future<String> checkDatabaseConnection() async {
    for (var i = 0; i < 3; i++) {
      try {
        final isConnected = await _dbManager.checkConnection();
        if (isConnected) return 'Connection successful';
        await Future.delayed(const Duration(seconds: 1));
      } catch (e) {
        if (i == 2) return 'Connection failed after 3 attempts';
      }
    }
    return 'Connection failed after 3 attempts';
  }

  Future<void> ensureRelatedDataLoaded() async {
    // Load users and products if they're not already loaded
    if (_data['users']?.isEmpty ?? true) {
      await loadData('users');
    }
    if (_data['products']?.isEmpty ?? true) {
      await loadData('products');
    }
  }

  bool isDataLoaded(String modelType) {
    return _data[modelType]?.isNotEmpty ?? false;
  }

  Future<void> populateAllTables() async {
    // Check if we have minimum required entries
    await loadData('users');
    await loadData('products');

    if ((_data['users']?.length ?? 0) < 3 ||
        (_data['products']?.length ?? 0) < 3) {
      // Populate base tables first
      await populateWithRandomData('users', 5);
      await populateWithRandomData('products', 5);
    }

    // Now populate orders
    await populateWithRandomData('orders', 10);
  }

  // Add debug state
  bool _debugEnabled = false;
  bool get debugEnabled => _debugEnabled;
  set debugEnabled(bool value) {
    _debugEnabled = value;
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> getOrdersWithReference(
      String type, int id) async {
    final model = _dbManager.createModel('orders');
    if (model == null) return [];

    final allOrders = [
      ...(_data['orders'] ?? []),
      ...(_tempData['orders'] ?? [])
    ];
    return allOrders
        .where((order) => order['${type}_id'].toString() == id.toString())
        .map((order) =>
            Map<String, dynamic>.from(order)) // Convert to correct type
        .toList();
  }

  Future<bool> hasTemporaryEntries(String modelType) async {
    return (_tempData[modelType]?.isNotEmpty ?? false);
  }

  Future<bool> validateIds(Map<String, dynamic> order) async {
    final userId = order['user_id']?.toString();
    final productId = order['product_id']?.toString();

    if (userId == null || productId == null) return false;

    // Check both persisted and temporary data
    final allUsers = [...(_data['users'] ?? []), ...(_tempData['users'] ?? [])];
    final allProducts = [
      ...(_data['products'] ?? []),
      ...(_tempData['products'] ?? [])
    ];

    final userExists = allUsers.any((u) => u['id'].toString() == userId);
    final productExists =
        allProducts.any((p) => p['id'].toString() == productId);

    return userExists && productExists;
  }

  Future<void> saveAllTemporaryEntries(List<String> modelTypes) async {
    for (final modelType in modelTypes) {
      await persistTemporaryEntries(modelType);
    }
  }

  Future<Map<String, List<Map<String, dynamic>>>> getDependentOrders(
      String modelType, int id) async {
    final dependentOrders =
        await getOrdersWithReference(modelType.replaceAll('s', ''), id);

    Map<String, List<Map<String, dynamic>>> result = {
      'persisted': [],
      'temporary': []
    };

    for (var order in dependentOrders) {
      if (_data['orders']?.any((o) => o['id'] == order['id']) ?? false) {
        result['persisted']!.add(order);
      } else {
        result['temporary']!.add(order);
      }
    }

    return result;
  }
}
