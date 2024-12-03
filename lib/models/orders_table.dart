import 'base_table.dart';

class Order extends BaseTable {
  final int? id;
  final int userId;
  final int productId;
  final int quantity;

  Order({
    this.id,
    required this.userId,
    required this.productId,
    required this.quantity,
  });

  @override
  String get tableName => 'orders';

  @override
  String get createTableQuery => '''
    CREATE TABLE IF NOT EXISTS orders (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      product_id INTEGER NOT NULL,
      quantity INTEGER NOT NULL,
      FOREIGN KEY (user_id) REFERENCES users (id),
      FOREIGN KEY (product_id) REFERENCES products (id)
    )
  ''';

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'quantity': quantity,
    };
  }

  static Order fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      userId: map['user_id'],
      productId: map['product_id'],
      quantity: map['quantity'],
    );
  }
}
