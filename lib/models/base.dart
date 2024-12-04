abstract class BaseTable {
  String get tableName;
  Map<String, dynamic> toMap();

  static BaseTable fromMap(Map<String, dynamic> map) {
    throw UnimplementedError('Subclasses must override fromMap');
  }
}
