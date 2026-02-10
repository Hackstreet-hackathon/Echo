import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/storage_keys.dart';
import '../providers/providers.dart';
import '../services/storage/preferences_service.dart';

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final prefs = ref.watch(preferencesServiceProvider);
  final stored = prefs.getString(StorageKeys.themeMode);
  ThemeMode mode = ThemeMode.dark;
  if (stored == 'light') mode = ThemeMode.light;
  if (stored == 'system') mode = ThemeMode.system;
  return ThemeModeNotifier(prefs, mode);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(this._prefs, super.initialState);

  final PreferencesService _prefs;

  void setThemeMode(ThemeMode mode) {
    state = mode;
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    _prefs.setString(StorageKeys.themeMode, value);
  }
}
