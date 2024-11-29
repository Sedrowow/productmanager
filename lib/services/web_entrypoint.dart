import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

Future<void> main() async {
  usePathUrlStrategy();
  databaseFactory = databaseFactoryFfiWeb;
  // Initialize SQLite for web
  await databaseFactoryFfiWeb.setDatabasesPath('.');
}
