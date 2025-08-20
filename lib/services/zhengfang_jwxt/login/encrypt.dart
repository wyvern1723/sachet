import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/asymmetric/pkcs1.dart';
import 'package:pointycastle/asymmetric/rsa.dart';
import 'package:pointycastle/pointycastle.dart';

class RSAEncryptor {
  /// 将Base64字符串转换为十六进制字符串
  static String _b64ToHex(String base64Str) {
    return base64
        .decode(base64Str)
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
  }

  /// 使用RSA公钥加密密码
  static String encryptPassword(
      String password, String modulusB64, String exponentB64) {
    try {
      // 1. 将Base64格式的模数和指数转换为十六进制
      final modulusHex = _b64ToHex(modulusB64);
      final exponentHex = _b64ToHex(exponentB64);

      // 2. 将十六进制字符串转换为BigInt
      final modulus = BigInt.parse(modulusHex, radix: 16);
      final exponent = BigInt.parse(exponentHex, radix: 16);

      // 3. 创建RSA公钥对象
      final publicKey = RSAPublicKey(modulus, exponent);

      // 4. 创建加密器（使用PKCS1编码）
      final cipher = PKCS1Encoding(RSAEngine())
        ..init(true, PublicKeyParameter<RSAPublicKey>(publicKey));

      // 5. 加密密码（UTF-8编码）
      final passwordBytes = utf8.encode(password);
      final encryptedBytes = cipher.process(Uint8List.fromList(passwordBytes));

      // 6. 将加密结果转换为Base64
      return base64.encode(encryptedBytes);
    } catch (e) {
      throw Exception('RSA加密失败: $e');
    }
  }
}

bool verifyEncryption(String password, String encryptedBase64,
    RSAPublicKey publicKey, RSAPrivateKey privateKey) {
  // 解密
  final decryptCipher = PKCS1Encoding(RSAEngine())
    ..init(false, PrivateKeyParameter<RSAPrivateKey>(privateKey));
  final encryptedBytes = base64.decode(encryptedBase64);
  final decryptedBytes = decryptCipher.process(encryptedBytes);
  final decryptedPassword = utf8.decode(decryptedBytes);
  // 比较解密结果与原始密码
  return decryptedPassword == password;
}
