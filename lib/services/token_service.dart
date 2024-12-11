import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

class TokenService {
  static final _key = Key.fromSecureRandom(32);
  static final _iv = IV.fromSecureRandom(16);
  static final _encrypter = Encrypter(AES(_key));

  // This is just a simple example of token obfuscation
  // Replace YOUR_ENCRYPTED_TOKEN with your actual encrypted token
  static const String _encryptedToken =
      'v1xpMWI5aqG7TJigYcjqriy9OEUluXz6ttRO5hA+c8dltqez9T/f4b6g6dvDDz69ncowx4eO20ha+4CxQ758wBeJNb0nXWDp+kV+goitk1DkftazXYfyeHPCsAUPJhTv';

  static String getDecryptedToken() {
    try {
      // Add some runtime transformation to make it harder to extract token
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final salt =
          sha256.convert(utf8.encode(timestamp.substring(0, 5))).toString();

      final encrypted = Encrypted.fromBase64(_encryptedToken);
      final decrypted = _encrypter.decrypt(encrypted, iv: _iv);

      // Add additional runtime transformation
      final keyParts = decrypted.split('').toList();
      keyParts.removeWhere((char) => salt.contains(char));

      return keyParts.join('');
    } catch (e) {
      return '';
    }
  }

  // Use this method to generate your encrypted token (run once)
  static String encryptToken(String token) {
    final encrypted = _encrypter.encrypt(token, iv: _iv);
    return encrypted.base64;
  }
}
