abstract class BaseTable {
  String get tableName;
  Map<String, dynamic> toMap();
  BaseTable clone(); // Add this abstract method

  static BaseTable fromMap(Map<String, dynamic> map) {
    throw UnimplementedError('Subclasses must override fromMap');
  }
}
