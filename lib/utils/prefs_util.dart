import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PrefsUtil {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs => _prefs!;

  static String? getString(String key) => _prefs?.getString(key);
  static Future<bool> setString(String key, String value) => _prefs!.setString(key, value);

  static bool getBool(String key, {bool defaultValue = false}) => _prefs?.getBool(key) ?? defaultValue;
  static Future<bool> setBool(String key, bool value) => _prefs!.setBool(key, value);

  static bool contains(String key) => _prefs?.containsKey(key) ?? false;
  static Future<bool> remove(String key) => _prefs!.remove(key);

  static T? fromJson<T>(String key, T Function(Map<String, dynamic>) fromJsonFunc) {
    final str = getString(key);
    if (str == null) return null;
    try {
      return fromJsonFunc(json.decode(str));
    } catch (_) {
      return null;
    }
  }

  static Future<bool> setJson(String key, Map<String, dynamic> json) {
    return setString(key, jsonEncode(json));
  }

  static void clearKeysStartWith(String prefix) {
    final keys = _prefs?.getKeys().where((k) => k.startsWith(prefix)).toList() ?? [];
    for (final key in keys) {
      _prefs?.remove(key);
    }
  }
}
