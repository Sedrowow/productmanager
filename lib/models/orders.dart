import 'base.dart';

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
