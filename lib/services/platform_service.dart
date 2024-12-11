import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class PlatformService {
  static Future<void> initializePlatform() async {
    if (kIsWeb) {
      // Web platform
      databaseFactory = databaseFactoryFfiWeb;
    } else {
      // Desktop/Mobile platforms
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }
}
