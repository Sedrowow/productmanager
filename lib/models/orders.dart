import 'base.dart';

class Order extends BaseTable {
  int userId;
  int productId;
  int quantity;

  Order(
      {required this.userId, required this.productId, required this.quantity});

  @override
  String get tableName => 'orders';

  @override
  Map<String, dynamic> toMap() => {
        'user_id': userId,
        'product_id': productId,
        'quantity': quantity,
      };

  @override
  BaseTable clone() => Order(
        userId: userId,
        productId: productId,
        quantity: quantity,
      );
}
