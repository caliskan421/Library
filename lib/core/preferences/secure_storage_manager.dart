import 'dart:developer' as dev;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'base_preferences.dart';

/// Secure Storage kullanarak hassas verileri saklama işlemlerini yöneten sınıf.
///
/// Bu sınıf, [BasePreferences] arayüzünü implement ederek
/// Flutter Secure Storage üzerinden hassas veri saklama işlemlerini gerçekleştirir.
/// Token, şifre gibi hassas verilerin güvenli bir şekilde saklanması için kullanılır.
class SecureStorageManager implements BasePreferences {
  final FlutterSecureStorage _secureStorage;

  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyUserEmail = 'user_email';
  static const String keyUserName = 'user_name';

  SecureStorageManager(this._secureStorage);

  @override
  void logError(String msg, Object error, [StackTrace? st]) => dev.log('SharedPrefs ❌ $msg', level: 1000, error: error, stackTrace: st);

  @override
  Future<bool> setString(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
      return true;
    } catch (e) {
      logError('setString failed for key: $key', e);
      return false;
    }
  }

  @override
  Future<String?> getString(String key) async {
    try {
      return await _secureStorage.read(key: key);
    } catch (e) {
      logError('getString failed for key: $key', e);
      return null;
    }
  }

  @override
  Future<bool> setInt(String key, int value) async {
    try {
      await _secureStorage.write(key: key, value: value.toString());
      return true;
    } catch (e) {
      logError('setInt failed for key: $key', e);
      return false;
    }
  }

  @override
  Future<int?> getInt(String key) async {
    try {
      final value = await _secureStorage.read(key: key);
      if (value == null) return null;
      return int.tryParse(value);
    } catch (e) {
      logError('getInt failed for key: $key', e);
      return null;
    }
  }

  @override
  Future<bool> setDouble(String key, double value) async {
    try {
      await _secureStorage.write(key: key, value: value.toString());
      return true;
    } catch (e) {
      logError('setDouble failed for key: $key', e);
      return false;
    }
  }

  @override
  Future<double?> getDouble(String key) async {
    try {
      final value = await _secureStorage.read(key: key);
      if (value == null) return null;
      return double.tryParse(value);
    } catch (e) {
      logError('getDouble failed for key: $key', e);
      return null;
    }
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    try {
      await _secureStorage.write(key: key, value: value.toString());
      return true;
    } catch (e) {
      logError('setBool failed for key: $key', e);
      return false;
    }
  }

  @override
  Future<bool?> getBool(String key) async {
    try {
      final value = await _secureStorage.read(key: key);
      if (value == null) return null;
      return value.toLowerCase() == 'true';
    } catch (e) {
      logError('getBool failed for key: $key', e);
      return null;
    }
  }

  @override
  Future<bool> setStringList(String key, List<String> value) async {
    try {
      final String encodedValue = value.join('|');
      await _secureStorage.write(key: key, value: encodedValue);
      return true;
    } catch (e) {
      logError('setStringList failed for key: $key', e);
      return false;
    }
  }

  @override
  Future<List<String>?> getStringList(String key) async {
    try {
      final value = await _secureStorage.read(key: key);
      if (value == null) return null;
      return value.split('|');
    } catch (e) {
      logError('getStringList failed for key: $key', e);
      return null;
    }
  }

  @override
  Future<bool> remove(String key) async {
    try {
      await _secureStorage.delete(key: key);
      return true;
    } catch (e) {
      logError('remove failed for key: $key', e);
      return false;
    }
  }

  @override
  Future<bool> clear() async {
    try {
      await _secureStorage.deleteAll();
      return true;
    } catch (e) {
      logError('clear failed', e);
      return false;
    }
  }

  @override
  Future<bool> containsKey(String key) async {
    try {
      final value = await _secureStorage.read(key: key);
      return value != null;
    } catch (e) {
      logError('containsKey failed for key: $key', e);
      return false;
    }
  }

  // Uygulama özelinde kullanılacak yardımcı metodlar

  /// Access token'ı kaydet
  Future<bool> saveAccessToken(String token) {
    return setString(keyAccessToken, token);
  }

  /// Access token'ı getir
  Future<String?> getAccessToken() {
    return getString(keyAccessToken);
  }

  /// Refresh token'ı kaydet
  Future<bool> saveRefreshToken(String token) {
    return setString(keyRefreshToken, token);
  }

  /// Refresh token'ı getir
  Future<String?> getRefreshToken() {
    return getString(keyRefreshToken);
  }

  /// Kullanıcı e-posta adresini kaydet
  Future<bool> saveUserEmail(String email) {
    return setString(keyUserEmail, email);
  }

  /// Kullanıcı e-posta adresini getir
  Future<String?> getUserEmail() {
    return getString(keyUserEmail);
  }

  /// Kullanıcı adını kaydet
  Future<bool> saveUserName(String name) {
    return setString(keyUserName, name);
  }

  /// Kullanıcı adını getir
  Future<String?> getUserName() {
    return getString(keyUserName);
  }

  /// Tüm kullanıcı verilerini temizle (logout işlemi için)
  Future<bool> clearUserData() async {
    try {
      await remove(keyAccessToken);
      await remove(keyRefreshToken);
      await remove(keyUserId);
      await remove(keyUserEmail);
      await remove(keyUserName);
      return true;
    } catch (e) {
      logError('clearUserData failed', e);
      return false;
    }
  }

  /// Kullanıcının giriş yapmış olup olmadığını kontrol et
}
