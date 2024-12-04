import 'base.dart';

class Product extends BaseTable {
  final int? id;
  final String name;
  final double price;

  Product({
    this.id,
    required this.name,
    required this.price,
  });

  @override
  String get tableName => 'products';

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
    };
  }

  static Product fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      price: map['price'],
    );
  }
}
