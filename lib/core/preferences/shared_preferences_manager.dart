import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as dev;
import 'base_preferences.dart';
import 'dart:convert';

typedef JsonMap = Map<String, dynamic>;

extension SharedPreferencesJsonExt on SharedPreferences {
  Future<bool> setJson(String key, JsonMap map) => setString(key, jsonEncode(map));

  JsonMap? getJson(String key) {
    final raw = getString(key);
    return raw == null ? null : jsonDecode(raw) as JsonMap;
  }
}

class SharedPreferencesManager implements BasePreferences {
  SharedPreferencesManager(this._prefs, {required this.isUserLoggedIn});

  final SharedPreferences _prefs;
  final Future<bool> Function() isUserLoggedIn; //for next version [V3]

  /* ---------- BasePreferences implementasyonu ---------- */

  @override
  Future<bool> setString(String key, String value) => _wrap(() => _prefs.setString(key, value));

  @override
  Future<String?> getString(String key) => Future.value(_prefs.getString(key));

  @override
  Future<bool> setInt(String key, int value) => _wrap(() => _prefs.setInt(key, value));

  @override
  Future<int?> getInt(String key) => Future.value(_prefs.getInt(key));

  @override
  Future<bool> setDouble(String key, double value) => _wrap(() => _prefs.setDouble(key, value));

  @override
  Future<double?> getDouble(String key) => Future.value(_prefs.getDouble(key));

  @override
  Future<bool> setBool(String key, bool value) => _wrap(() => _prefs.setBool(key, value));

  @override
  Future<bool?> getBool(String key) => Future.value(_prefs.getBool(key));

  @override
  Future<bool> setStringList(String key, List<String> value) => _wrap(() => _prefs.setStringList(key, value));

  @override
  Future<List<String>?> getStringList(String key) => Future.value(_prefs.getStringList(key));

  @override
  Future<bool> remove(String key) => _wrap(() => _prefs.remove(key));

  @override
  Future<bool> clear() => _wrap(_prefs.clear);

  @override
  Future<bool> containsKey(String key) => Future.value(_prefs.containsKey(key));

  /* ---------- Yardımcılar ---------- */

  @override
  void logError(String msg, Object error, [StackTrace? st]) => dev.log('SharedPrefs ❌ $msg', level: 1000, error: error, stackTrace: st);

  Future<T> _wrap<T>(Future<T> Function() fn) async {
    try {
      return await fn();
    } catch (e, st) {
      logError('Operation failed', e, st);
      rethrow;
    }
  }
}
