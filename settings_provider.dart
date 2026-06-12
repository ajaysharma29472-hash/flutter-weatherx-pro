import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class SettingsProvider extends ChangeNotifier {
  String _units = AppConstants.metricUnits;
  ThemeMode _themeMode = ThemeMode.dark;
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;
  String _apiKey = '';
  bool _isLoaded = false;

  String get units => _units;
  ThemeMode get themeMode => _themeMode;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get locationEnabled => _locationEnabled;
  String get apiKey => _apiKey;
  bool get isLoaded => _isLoaded;
  bool get isMetric => _units == AppConstants.metricUnits;

  Future<void> load() async {
    if (_isLoaded) return;
    final prefs = await SharedPreferences.getInstance();
    _units = prefs.getString(AppConstants.unitsPref) ?? AppConstants.metricUnits;
    _notificationsEnabled = prefs.getBool(AppConstants.notifPref) ?? true;
    _locationEnabled = prefs.getBool('location_enabled') ?? true;
    _apiKey = prefs.getString(AppConstants.apiKeyPref) ?? '';
    final themeStr = prefs.getString(AppConstants.themePref) ?? 'dark';
    _themeMode = themeStr == 'light' ? ThemeMode.light : ThemeMode.dark;
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> setUnits(String units) async {
    _units = units;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.unitsPref, units);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        AppConstants.themePref, mode == ThemeMode.light ? 'light' : 'dark');
    notifyListeners();
  }

  Future<void> setNotifications(bool enabled) async {
    _notificationsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.notifPref, enabled);
    notifyListeners();
  }

  Future<void> setLocation(bool enabled) async {
    _locationEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('location_enabled', enabled);
    notifyListeners();
  }

  Future<void> setApiKey(String key) async {
    _apiKey = key;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.apiKeyPref, key);
    notifyListeners();
  }
}
