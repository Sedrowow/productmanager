import 'package:encrypt/encrypt.dart';
import 'dart:convert';

class TokenService {
  // Use fixed key and IV for consistency
  static final _key = Key(
      base64Decode('buLbD7SqWURgqeP2BtrEe47dx7tnRfRhzuWMewl/A70=')); // 32 bytes
  static final _iv = IV(base64Decode('AxXbBQpzT/29LrWDzpRKtw==')); // 16 bytes
  static final _encrypter = Encrypter(AES(_key));

  static const String _encryptedToken =
      'IGCBNbxf++XUIK7dCKAPvdsMUkgLm1A2mhFfaUxsuOooki1VCUjuA1/y7lR9UvuJ';

  // Helper method to generate new key/IV (run once)
  static void generateNewKeyAndIV() {
    final key = Key.fromSecureRandom(32);
    final iv = IV.fromSecureRandom(16);
    print('Key (Base64): ${base64Encode(key.bytes)}');
    print('IV (Base64): ${base64Encode(iv.bytes)}');
  }

  // Helper method to encrypt a token with the fixed key/IV
  static String encryptNewToken(String token) {
    final encrypted = _encrypter.encrypt(token, iv: _iv);
    print('Encrypted token: ${encrypted.base64}');
    return encrypted.base64;
  }

  static String getGitHubToken() {
    try {
      final encrypted = Encrypted.fromBase64(_encryptedToken);
      return _encrypter.decrypt(encrypted, iv: _iv);
    } catch (e) {
      print('Error decrypting token: $e');
      return '';
    }
  }
}
