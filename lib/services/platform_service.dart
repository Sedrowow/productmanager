import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class PlatformService {
  static Future<void> initialize() async {
    if (kIsWeb) {
      // Web platform initialization
      databaseFactory = databaseFactoryFfiWeb;
      await databaseFactoryFfiWeb.setDatabasesPath('.');
    } else {
      // Desktop/Mobile platform initialization
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }
}
