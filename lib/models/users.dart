import 'base.dart';

class User extends BaseTable {
  final int? id;
  final String fname;
  final String lname;

  User({
    this.id,
    required this.fname,
    required this.lname,
  });

  @override
  String get tableName => 'users';

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstname': fname,
      'lastname': lname,
    };
  }

  static User fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      fname: map['firstname'],
      lname: map['lastname'],
    );
  }
}
