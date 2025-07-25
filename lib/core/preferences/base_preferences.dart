import 'package:flutter/material.dart';

abstract class BasePreferences {
  /// String değer kaydetme
  Future<bool> setString(String key, String value);

  /// String değer okuma
  Future<String?> getString(String key);

  /// Int değer kaydetme
  Future<bool> setInt(String key, int value);

  /// Int değer okuma
  Future<int?> getInt(String key);

  /// Double değer kaydetme
  Future<bool> setDouble(String key, double value);

  /// Double değer okuma
  Future<double?> getDouble(String key);

  /// Bool değer kaydetme
  Future<bool> setBool(String key, bool value);

  /// Bool değer okuma
  Future<bool?> getBool(String key);

  /// String listesi kaydetme
  Future<bool> setStringList(String key, List<String> value);

  /// String listesi okuma
  Future<List<String>?> getStringList(String key);

  /// Belirtilen anahtarı silme
  Future<bool> remove(String key);

  /// Tüm verileri silme
  Future<bool> clear();

  /// Belirtilen anahtarın varlığını kontrol etme
  Future<bool> containsKey(String key);

  /// Hata durumlarını loglama
  @protected
  void logError(String message, Object error, [StackTrace? st]);
}
