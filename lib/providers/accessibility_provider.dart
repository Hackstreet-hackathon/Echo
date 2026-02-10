import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/storage_keys.dart';
import '../data/models/accessibility_settings_model.dart';
import '../providers/providers.dart';
import '../services/storage/preferences_service.dart';

final accessibilitySettingsProvider =
    StateNotifierProvider<AccessibilitySettingsNotifier, AccessibilitySettingsModel>(
  (ref) {
    final prefs = ref.watch(preferencesServiceProvider);
    final stored = prefs.getString(StorageKeys.accessibilitySettings);
    AccessibilitySettingsModel settings = const AccessibilitySettingsModel();
    if (stored != null) {
      try {
        settings =
            AccessibilitySettingsModel.fromJson(
                jsonDecode(stored) as Map<String, dynamic>);
      } catch (_) {}
    }
    return AccessibilitySettingsNotifier(prefs, settings);
  },
);

class AccessibilitySettingsNotifier
    extends StateNotifier<AccessibilitySettingsModel> {
  AccessibilitySettingsNotifier(this._prefs, super.initialState);

  final PreferencesService _prefs;

  void _persist() {
    _prefs.setString(
        StorageKeys.accessibilitySettings, jsonEncode(state.toJson()));
  }

  void update(AccessibilitySettingsModel settings) {
    state = settings;
    _persist();
  }

  void setLargeTextMode(bool value) {
    state = state.copyWith(largeTextMode: value);
    _persist();
  }

  void setHighContrastMode(bool value) {
    state = state.copyWith(highContrastMode: value);
    _persist();
  }

  void setVoicePlaybackEnabled(bool value) {
    state = state.copyWith(voicePlaybackEnabled: value);
    _persist();
  }

  void setHapticFeedbackEnabled(bool value) {
    state = state.copyWith(hapticFeedbackEnabled: value);
    _persist();
  }
}
