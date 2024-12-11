import 'package:flutter/foundation.dart';
import 'package:productmanager/services/token_service.dart';

void main() {
  const String token =
      'your token here'; // Replace with your token to test encryption
  final encrypted = TokenService.encryptToken(token);
  if (kDebugMode) {
    print('Encrypted token: $encrypted');
  }
}
