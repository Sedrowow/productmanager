import 'base.dart';

class User extends BaseTable {
  String fname;
  String lname;

  User({required this.fname, required this.lname});

  @override
  String get tableName => 'users';

  @override
  Map<String, dynamic> toMap() => {
        'fname': fname,
        'lname': lname,
      };

  @override
  BaseTable clone() => User(fname: fname, lname: lname);
}
