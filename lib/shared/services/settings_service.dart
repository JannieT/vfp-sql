import 'dart:convert';

import 'package:sales_importer/env.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  SettingsService._(this.store);

  static SettingsService? _instance;

  final SharedPreferences store;

  static Future<SettingsService> instance() async {
    if (_instance == null) {
      final prefs = await SharedPreferences.getInstance();
      _instance = SettingsService._(prefs);
    }
    return _instance!;
  }

  Map<String, dynamic> get settings {
    final values = store.getString('settings');
    if (values == null) return env;
    return jsonDecode(values);
  }

  String? setting(Setting key) {
    final map = settings;
    return map[key.name];
  }

  Future<void> saveSettings(Map<String, dynamic> values) async {
    await store.setString('settings', jsonEncode(values));
  }

  Future<String> settingsRendered() async {
    final map = settings;
    final rendered = const JsonEncoder.withIndent('  ').convert(map);
    return rendered;
  }
}
