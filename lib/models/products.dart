import 'base.dart';

class Product extends BaseTable {
  String name;
  double price;

  Product({required this.name, required this.price});

  @override
  String get tableName => 'products';

  @override
  Map<String, dynamic> toMap() => {
        'name': name,
        'price': price,
      };

  @override
  BaseTable clone() => Product(name: name, price: price);
}
