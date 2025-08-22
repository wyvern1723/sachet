import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageUtil {
  // 私有构造函数
  SecureStorageUtil._();

  // 单例实例
  static final SecureStorageUtil _instance = SecureStorageUtil._();

  // 工厂构造函数返回单例
  factory SecureStorageUtil() => _instance;

  // FlutterSecureStorage 实例
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  Future<void> save({required String key, required String? value}) async {
    await _secureStorage.write(key: key, value: value);
  }

  Future<String?> read({required String key}) async {
    return await _secureStorage.read(key: key);
  }

  Future<void> delete({required String key}) async {
    await _secureStorage.delete(key: key);
  }

  Future<void> deleteAll() async {
    await _secureStorage.deleteAll();
  }
}
