import 'package:shared_preferences/shared_preferences.dart';

/// Yerel depolama servisi
class StorageService {
  StorageService._();

  static SharedPreferences? _prefs;

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('StorageService henüz başlatılmadı. initialize() çağrılmalı.');
    }
    return _prefs!;
  }

  // ── String ──
  static Future<bool> setString(String key, String value) =>
      prefs.setString(key, value);
  static String? getString(String key) => prefs.getString(key);

  // ── Bool ──
  static Future<bool> setBool(String key, bool value) =>
      prefs.setBool(key, value);
  static bool? getBool(String key) => prefs.getBool(key);

  // ── Int ──
  static Future<bool> setInt(String key, int value) =>
      prefs.setInt(key, value);
  static int? getInt(String key) => prefs.getInt(key);

  // ── Double ──
  static Future<bool> setDouble(String key, double value) =>
      prefs.setDouble(key, value);
  static double? getDouble(String key) => prefs.getDouble(key);

  // ── Silme ──
  static Future<bool> remove(String key) => prefs.remove(key);
  static Future<bool> clear() => prefs.clear();

  // ── Özel Anahtarlar ──
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyActiveVehicleId = 'active_vehicle_id';

  static bool get isOnboardingComplete =>
      getBool(keyOnboardingComplete) ?? false;

  static Future<void> setOnboardingComplete() =>
      setBool(keyOnboardingComplete, true);

  static String? get activeVehicleId => getString(keyActiveVehicleId);

  static Future<void> setActiveVehicleId(String id) =>
      setString(keyActiveVehicleId, id);
}
