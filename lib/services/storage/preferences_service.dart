import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences wrapper for ECHO
class PreferencesService {
  PreferencesService._internal();
  static PreferencesService? _instance;
  static SharedPreferences? _prefs;

  factory PreferencesService() {
    _instance ??= PreferencesService._internal();
    return _instance!;
  }

  static Future<void> ensureInit() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<bool> setString(String key, String value) async {
    return _prefs?.setString(key, value) ?? Future.value(false);
  }

  String? getString(String key) {
    return _prefs?.getString(key);
  }

  Future<bool> setBool(String key, bool value) async {
    return _prefs?.setBool(key, value) ?? Future.value(false);
  }

  bool getBool(String key, {bool defaultValue = false}) {
    return _prefs?.getBool(key) ?? defaultValue;
  }

  Future<bool> setInt(String key, int value) async {
    return _prefs?.setInt(key, value) ?? Future.value(false);
  }

  int? getInt(String key) {
    return _prefs?.getInt(key);
  }

  Future<bool> remove(String key) async {
    return _prefs?.remove(key) ?? Future.value(false);
  }

  Future<bool> clear() async {
    return _prefs?.clear() ?? Future.value(false);
  }
}
